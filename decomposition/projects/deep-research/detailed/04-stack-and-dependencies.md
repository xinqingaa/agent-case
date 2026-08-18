# DeepResearch 技术栈与依赖

## 技术栈总览

| 层 | 技术 | 静态约束 | 实际职责 | 证据 |
|---|---|---|---|---|
| 语言 | Python | `>=3.10` | API、图、节点、检索、记忆、CLI | `[V]` E-BOOT-001 |
| 前端 | Vue 3 + TypeScript | Vue `^3.5.30`、TS `~5.9.3` | 单页研究工作台 | `[V]` E-ARCH-004 |
| 构建 | Vite 7 | `^7.3.1` | 开发服务、代理和前端构建 | `[V]` E-BOOT-003、E-BOOT-004 |
| API | FastAPI + Uvicorn | pyproject 未锁版本 | JSON、SSE、健康检查 | `[V]` E-ARCH-006、E-FLOW-002 |
| 编排 | LangGraph | pyproject 未锁版本 | 状态图、条件边、checkpointer | `[V]` E-FLOW-004 |
| LLM | LangChain Agent + ChatTongyi | 未锁模型 SDK 版本 | 八个角色化 Qwen 调用 | `[V]` E-ARCH-009 |
| Web 检索 | Python urllib + Bocha | 标准库 + 外部 API | HTTPS 搜索记录 | `[V]` E-FLOW-008 |
| 本地 RAG | DashScope Embedding + Milvus | 未锁核心版本 | 文档相似度检索 | `[V]` E-FLOW-006 |
| 状态/记忆 | PostgreSQL、Redis、SQLite、内存 | 配置选择 | 图检查点和跨轮次上下文 | `[V]` E-DATA-002、E-DATA-003 |

## 关键依赖与调用位置

| 依赖 | 直接使用位置 | 解决的问题 | 失效影响 |
|---|---|---|---|
| `langgraph` | `graph.py`、`main.py` | 图编排与内存 saver | 核心流程不可构建 |
| `langgraph-checkpoint-postgres/redis` | `build_checkpointer` 动态/直接导入 | 持久图状态 | 退内存 |
| `fastapi` | `app_main.py`、router、schema | Web API | Web 入口不可用，CLI仍可能可用 |
| `langchain-community` | ChatTongyi、Embedding | Qwen 模型与向量 | 推理/RAG不可用 |
| `langchain-milvus` / community fallback | RAG、MemoryManager | Milvus vector store | Local/向量记忆降级 |
| `pymilvus` | `rag/core.py` | collection 检查和连接 | Local检索为空 |
| `psycopg` | MemoryManager | 结构化短/长期记忆 | 退 SQLite/内存 |
| `redis` | MemoryManager | 短期记忆 | 退内存 |
| `pydantic-settings` | backend settings | `.env` Web 配置 | Web 配置加载失败 |
| `python-dotenv` | CLI/AppConfig | 项目 `.env` | 只能依赖进程环境/config |

## 两套 Python 依赖声明

`pyproject.toml` 声明较小的核心集合但不锁版本；`requirements.txt` 是大范围精确快照，额外包含 Flask、MCP、SSE Starlette、Pandas、SQLAlchemy 等当前实现未引用项。[V][E-ARCH-001][E-ARCH-002][E-ARCH-010]

静态结论：

- 当前 SSE 由 FastAPI `StreamingResponse` 实现，未使用 `sse-starlette`。
- 当前 Agent 使用 LangChain `create_agent`，但 tools 列表为空。
- Flask、MCP、Neo4j/MySQL 客户端未进入当前源码链。
- 只有 L4 分别安装/构建后，才能判定哪套声明足够以及版本兼容性。

## 运行依赖与可选依赖

| 类型 | 依赖 | 判断 |
|---|---|---|
| 硬依赖 | Python、LangGraph/LangChain、DashScope Key | 图和 Agent 构建需要 |
| Web 入口 | FastAPI、Uvicorn | CLI 可不需要 Web 进程，但当前包可能整体安装 |
| 前端 | Node/npm/Vue/Vite | 只使用 API/CLI 时可不启动 |
| Web 证据 | Bocha Key | 缺失时 Web 分支为空 |
| Local 证据 | Milvus + Embedding | 不可用时 Local 分支为空 |
| 持久 checkpointer | PostgreSQL 或 Redis Stack | 可退进程内存 |
| 跨轮次记忆 | PostgreSQL/Redis/SQLite/Milvus 组合 | 可关闭或降级 |

## 版本与兼容风险

| 约束 | 风险 | 验证方式 |
|---|---|---|
| Python `>=3.10` 无上限 | 新版 Python 可能与二进制/SDK 不兼容 | 选择两个受支持版本构建 |
| pyproject 不锁依赖 | 最新 LangGraph/LangChain API 可能变化 | 干净安装 + 导入/图测试 |
| requirements 可能过时/过宽 | 冲突、安装慢、攻击面增大 | 对照实际 imports 生成最小集合 |
| Redis saver 要 RediSearch | 普通 Redis 运行时降级 | Redis 与 Redis Stack 矩阵 |
| Milvus 两个包路径 fallback | 类/API 行为可能不同 | 分别记录实际 backend 与检索测试 |
| Node engines 很具体 | 老 Node 无法安装/构建 | 使用 20.19+ 或 22.12+ |

## 技术选型评价

- LangGraph 符合显式阶段和补搜循环，但多角色模型调用会增加成本与延迟。
- FastAPI + Vue 足以形成清晰教学用全栈链路；SSE 阶段流实现简单，但取消/背压治理不足。
- Bocha/Milvus 双源结构有学习价值；当前相关性评测和入库流程不成熟。
- 多后端记忆展示了工程取舍，但自动降级改变隔离语义，不适合直接照搬到生产。

## 初学者补课顺序

1. FastAPI schema、依赖注入和 StreamingResponse。
2. LangGraph StateGraph、条件边和 reducer。
3. LLM 结构化输出、fallback 与 Prompt 边界。
4. Embedding、Milvus 和 source metadata。
5. PostgreSQL/Redis/SQLite 的持久化与隔离。
6. Vue `fetch` 流读取和响应式 UI。
