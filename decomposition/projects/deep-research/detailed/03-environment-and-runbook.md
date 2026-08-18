# DeepResearch 环境与运行手册

## 当前状态

- 授权：L3 静态源码分析
- 已确认：入口、配置优先级、候选命令、健康信号和依赖降级
- 未确认：依赖能否安装、服务能否启动、页面和研究请求能否成功
- 禁止事项：未读取真实 `.env`，未安装依赖，未启动服务，未连接数据库或外部 API

下文命令均是待 L4 执行的候选步骤，不属于 `[R]` 运行证据。

## 环境约束

| 项目 | 静态约束 | 证据 | L4 要记录 |
|---|---|---|---|
| Python | `>=3.10` | `[V]` E-BOOT-001 | `python --version`、平台、虚拟环境 |
| Node.js | `^20.19.0` 或 `>=22.12.0` | `[V]` E-BOOT-003 | `node --version` |
| npm | 有 `package-lock.json` | `[V]` E-BOOT-003 | `npm --version`，优先 `npm ci` |
| Python 依赖源 | pyproject 与 requirements 不一致 | `[U]` E-OPEN-004 | 分别验证最小/完整安装 |

## 配置优先级

`AppConfig` 按环境变量 → `config.json` → 代码默认值解析；`DASHSCOPE_API_KEY` 为空直接抛错。FastAPI 自身的 host/port/CORS 由 `AppSettings` 从 `.env` 读取。[V][E-BOOT-006]

| 配置组 | 变量 | 必需性/作用 |
|---|---|---|
| 模型 | `DASHSCOPE_API_KEY`、`MODEL` | Key 是所有模式的硬要求；模型默认由配置决定 |
| Web 检索 | `BOCHA_API_KEY` | 深度研究的 Web 分支需要；模板当前遗漏 |
| 上下文 | `TENANT_ID`、`USER_ID`、`THREAD_ID` | CLI 默认值；Web 请求可覆盖 |
| 研究 | `MAX_ITERATIONS` | 补搜上限；API 允许 1..6 覆盖 |
| 记忆 | `ENABLE_MEMORY`、`SHORT_TERM_*`、`LONG_TERM_*` | 可关闭；控制后端、TTL、摘要和范围 |
| 检查点 | `CHECKPOINTER_BACKEND` | postgres/redis/memory/auto |
| 数据服务 | `POSTGRES_DSN`、`REDIS_URL` | 对应后端启用时需要 |
| Milvus | `ENABLE_MILVUS`、`MILVUS_*` | 本地知识检索/长期记忆向量能力 |
| Web 服务 | `HOST`、`PORT`、`CORS_ALLOW_ORIGINS`、`APP_ENV` | AppSettings 字段可由环境覆盖 |

`.env.example` 没有列出 `BOCHA_API_KEY` 及 Web 服务字段；`config.json` 默认开启记忆、PostgreSQL checkpointer 和 Milvus，却留空 DSN/host，实际会走不同降级或失败路径。[V][E-RISK-008]

## 候选最小运行模式

### 模式 A：CLI + 内存 + 无记忆

目标是先减少数据库副作用，但仍需要 DashScope 模型；深度问题还会尝试 Bocha/RAG，故应先用 direct 候选问题。

```shell
cd code/deep_research
python main.py --enable-memory false --checkpointer-backend memory --enable-milvus false --once-query "你好"
```

### 模式 B：FastAPI 后端

源码导入使用 `backend`/`mult_agents` 顶层包，因此工作目录或 `PYTHONPATH` 必须让 `app/` 在模块搜索路径。静态上更明确的候选方式是：

```shell
cd code/deep_research/app
python app_main.py
```

或：

```shell
cd code/deep_research
PYTHONPATH=app uvicorn app_main:app --host 127.0.0.1 --port 8000
```

这两种方式尚未实测；旧文档中的 `python -m app.app_main` / `uvicorn app.app_main:app` 可能因顶层导入路径失败，不能先当作正确命令。

### 模式 C：Vue 前端

```shell
cd code/deep_research/front/agent_front
npm ci
npm run type-check
npm run build
npm run dev
```

开发服务静态配置为 `0.0.0.0:5173`，`/api` 和 `/health` 代理到 `127.0.0.1:8000`。[V][E-BOOT-004]

## 成功信号

| 层次 | 候选检查 | 预期信号 | 限制 |
|---|---|---|---|
| Python 导入 | 编译/导入入口 | 无 traceback | 不证明外部依赖可用 |
| 后端进程 | `GET http://127.0.0.1:8000/health` | `status=ok` | 不初始化研究资源 |
| API schema | 提交空 query | 422 | 只证明参数校验 |
| Direct | 受控问题到 `/run` | JSON final 非空 | 会调用真实模型 |
| SSE | 受控问题到 `/stream` | status、phase、route、final 顺序 | 最终正文不是 token 流 |
| 前端 | 打开 5173 | 页面可交互，无 console error | 还需 Network 检查 |
| 前端构建 | `npm run build` | type-check 和 Vite 均退出 0 | 记录版本/告警 |

## 外部依赖矩阵

| 服务 | 强制程度 | 关闭/失败后行为 | 副作用 |
|---|---|---|---|
| DashScope Chat | 硬要求 | 配置加载或节点失败 | 外部请求、费用 |
| Bocha | Web 分支可选 | 返回空 Web 证据 | 外部请求、费用/配额 |
| Milvus 知识库 | Local 分支可降级 | 返回空 Local 证据 | 检索只读；初始化/入库另有写 |
| PostgreSQL | 配置相关 | checkpointer 可退 Redis/内存；记忆可退 SQLite | 初始化可能建表，运行会写 |
| Redis Stack | 配置相关 | 退内存；普通 Redis 可能缺 RediSearch | 记忆/checkpoint 写入 |
| SQLite | 长期记忆降级 | 文件不可用则 MemoryManager 可能禁用 | 建表和写本地文件 |

Neo4j、MySQL、Flask、MCP 和 WebSocket 不属于当前最小运行链路。[V][E-ARCH-010]

## 常见故障（静态推演）

| 症状 | 可能原因 | 诊断 | 恢复 | 状态 |
|---|---|---|---|---|
| 健康正常、首个研究失败 | 懒初始化才读取模型/存储 | 看 `_ensure_initialized` 异常 | 修配置后重启进程 | `[V/I]` |
| `No module named backend` | 工作目录/PYTHONPATH 错 | 检查 `sys.path` 和启动方式 | 从 `app/` 启动或设 `PYTHONPATH=app` | `[I]` |
| Web 证据 0 | `BOCHA_API_KEY` 缺失/请求失败 | 看是否配置，不打印前缀 | 配置 Key 或接受单源 | `[V]` |
| Local 证据 0 | Milvus/Embedding/collection 未就绪 | 查 RAG 初始化和 collection | 启服务并入库，或关闭能力 | `[V/I]` |
| Redis checkpointer 降级 | 非 Redis Stack | 查 `FT._LIST` 错误 | 使用 Redis Stack 或内存 | `[V]` |
| 报告完成后 SSE error | `persist_turn` 失败 | 查记忆写入异常 | 修后端；代码应隔离该异常 | `[V/I]` |

## L4 验证计划

1. 建立隔离环境并记录版本，不覆盖用户全局环境。
2. 先验证 `pyproject.toml` 最小安装，再比较 requirements；不直接假定后者权威。
3. 执行 Python 编译/导入和前端 type-check/build。
4. 以记忆关闭、内存 checkpointer 启动，验证 `/health` 和 schema。
5. 用户确认外部调用预算后验证 direct；Web/Milvus/数据库分别扩大范围。
6. 记录每条命令的工作目录、退出码、成功信号、副作用和脱敏输出。

## 仍然阻塞

L4 未授权，因此本篇不能提供“从零已跑通”的结论。L5 也未授权，不能读取已有数据库、队列或外部存储内容。
