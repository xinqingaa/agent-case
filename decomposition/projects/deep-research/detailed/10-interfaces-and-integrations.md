# DeepResearch 接口与外部集成

## 集成地图

| 系统或接口 | 方向 | 协议 | 用途 | 认证 | 失败影响 | 证据 |
|---|---|---|---|---|---|---|
| Vue → FastAPI | 入站 | HTTP JSON / SSE | 发起研究、接收阶段和结果 | 无 | 页面显示请求失败 | `[V]` E-FLOW-001、E-FLOW-002 |
| CLI → 工作流 | 入站 | 本地函数/终端 | 单次或循环问答 | 本机权限 | 进程异常退出 | `[V]` E-ARCH-007 |
| DashScope Qwen | 出站 | SDK/HTTPS `[I]` | 八个角色推理、Embedding、摘要 | API Key | 初始化或节点失败 | `[V]` E-ARCH-001、E-ARCH-009 |
| Bocha Search | 出站 | HTTPS POST | Web 证据 | Bearer Key | 返回空 Web 证据 | `[V]` E-FLOW-008 |
| Milvus 知识库 | 出站 | Milvus 客户端 | 本地文档相似检索 | 源码未配置认证 | 返回空 Local 证据 | `[V]` E-FLOW-006 |
| PostgreSQL | 出站 | psycopg / saver | 检查点、短期/长期记忆 | DSN | 降级 Redis/SQLite/内存 | `[V]` E-DATA-002、E-DATA-003 |
| Redis/Redis Stack | 出站 | Redis 协议 | 短期记忆或检查点 | URL | 降级进程内存 | `[V]` E-DATA-002、E-DATA-003 |
| SQLite | 本地 | 文件数据库 | 长期记忆降级 | 文件权限 | 记忆不可用/异常 | `[V]` E-RISK-003 |

## 入站 HTTP 接口

| 接口 | 输入 | 校验与授权 | 输出 | 错误 | 实现 |
|---|---|---|---|---|---|
| `GET /health` | 无 | 无 | `{status:"ok", service:...}` | 标准 5xx | `health_router.py::health` |
| `POST /api/v1/research/run` | `ResearchRequest` | query/ID 非空，iteration 1..6；无认证 | `ResearchResponse` JSON | 异常由 FastAPI 处理 | `research_router.py::run_research` |
| `POST /api/v1/research/stream` | 同上 | 同上；无认证 | `text/event-stream` | 图异常包装为 error 事件 | `research_router.py::stream_research` |

`/health` 不初始化 `WorkflowService`，因此返回 ok 不代表模型、Bocha、Milvus、PostgreSQL 或 Redis 健康。[V][E-ARCH-006][E-FLOW-003]

## SSE 事件契约

| type | 主要字段 | 产生位置 | 前端行为 |
|---|---|---|---|
| `status` | `message` | Router | 加入进度 |
| `phase` | `node/message` | `_run_sync_with_events` | 显示节点阶段，最多留六条 |
| `route` | `message` | worker 完成后 | 显示走哪条链路 |
| `final` | 身份键、query、final | worker 完成后 | 移除状态，显示报告 |
| `error` | `message` | worker 捕获异常 | 显示失败文本 |

协议使用 POST 响应体的字节流，由前端 `fetch` + `ReadableStream` 解析；不是浏览器原生 `EventSource`，也不是 WebSocket。[V][E-FLOW-001][E-FLOW-002]

## 出站调用细节

| 目标 | 调用位置 | 超时 | 重试 | 降级 | 幂等性/副作用 |
|---|---|---|---|---|---|
| Bocha | `tools.py::bocha_web_search_records` | 30 秒 | 无 | 任意错误返回 `[]` | 只读搜索，但计费/配额 `[I]` |
| Qwen Chat | `build_agent` 和各节点 `agent.invoke` | 源码未显式设置 | 无 | JSON 节点有内容 fallback；调用异常无 fallback | 可能计费，输出不确定 |
| DashScope Embedding | `RAGSystem`、MemoryManager | 源码未显式设置 | 无 | RAG/记忆初始化捕获部分错误 | 可能计费 |
| Milvus 知识检索 | `RAGSystem.search_records` | 未设置 | 无 | wrapper 返回空列表 | 研究链路只读；入库另有写操作 |
| PostgreSQL | MemoryManager/checkpointer | 未设置 | 无 | 多级降级 | 初始化可建表，持久化会写入 |
| Redis | MemoryManager/checkpointer | 未设置 | 两种 URL 格式尝试 | 内存 | 记忆和 checkpoint 写入 |

## 数据库、缓存和集合

| 组件 | 数据 | 关键隔离 | 备注 |
|---|---|---|---|
| LangGraph PostgreSQL/Redis saver | 图状态 | 当前仅 thread ID | saver 自建结构，L5 前不读数据 |
| `short_term_messages` | 对话消息 | tenant/user/thread | MemoryManager 可建表 |
| `short_term_summaries` | 滚动摘要 | tenant/user/thread | 超阈值压缩 |
| `memory_entries` | 事实、任务等 | tenant/user，可含 thread | JSONB 内容 |
| `user_profiles` | 用户画像 | tenant/user | upsert |
| SQLite `memories` | 降级长期记忆 | user/namespace | 无 tenant 列 |
| Milvus 知识集合 | 本地文档 chunk | collection + metadata source | 默认集合配置与记忆集合可能复用 |
| Milvus 记忆集合 | 长期记忆向量 | 查询后按 tenant/user 元数据过滤 | 先过召回再在 Python 过滤 |

## 配置与密钥边界

`AppConfig` 的优先级是环境变量 → `config.json` → 默认值。`DASHSCOPE_API_KEY` 缺失会直接阻断初始化；`BOCHA_API_KEY` 由 `tools.py` 直接读取，但 `.env.example` 当前遗漏该变量。[V][E-FLOW-008][E-RISK-008]

安全要求：

- 不在文档、日志、测试或 `config.json` 写真实 Key。
- 当前 Bocha 日志输出 Key 前八位，应删除或完全脱敏。[V][E-RISK-009]
- Git 跟踪测试中已有疑似真实 Key，必须轮换并清理历史。[V][E-RISK-006]
- DSN、Redis URL 可能含口令，运行证据只能记录脱敏形式。

## 本地替代和测试替身

当前主链路没有依赖注入式的模型、搜索或存储接口，测试替换较困难。可行改进是给 `WorkflowService` 注入 graph factory、memory factory 和检索函数，并用固定 Agent 响应验证路由、证据 ID 和 SSE 事件；不要用真实 Bocha 脚本代替自动化集成测试。

## 未进入当前实现的依赖

全局搜索未发现 Neo4j、MySQL、Flask、MCP、WebSocket 调用。它们可能属于旧依赖或旧文档，不应加入当前最小运行架构。[V][E-ARCH-010]
