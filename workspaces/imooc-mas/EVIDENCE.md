# MoocManus / IMooc MAS 证据台账

## 证据状态

- `[V]` 静态核对源码；`[R]` 实际运行；`[C]` 用户确认；`[I]` 推断；`[U]` 未知。

| ID | 类型 | 来源 | 位置 | 支持的结论 | 状态 | 日期 |
|---|---|---|---|---|---|---|
| E-PROD-001 | source | 源码 | `mooc-manus/README.md` | 产品由 UI、API、sandbox、Nginx 和基础设施组成，可私有化部署 | [V] | 2026-09-06 |
| E-API-001 | source | 源码 | `api/app/interfaces/endpoints/session_routes.py:chat` | 会话聊天通过 SSE 返回 Agent 事件 | [V] | 2026-09-06 |
| E-FLOW-001 | source | 源码 | `api/app/domain/services/flows/planner_react.py:invoke` | Flow 按规划、执行、更新、总结状态推进 | [V] | 2026-09-06 |
| E-AGENT-001 | source | 源码 | `api/app/domain/services/agents/planner.py` | Planner 生成和更新结构化 Plan | [V] | 2026-09-06 |
| E-AGENT-002 | source | 源码 | `api/app/domain/services/agents/react.py` | ReAct 执行步骤、处理工具事件并汇总结果 | [V] | 2026-09-06 |
| E-TOOL-001 | source | 源码 | `api/app/domain/services/flows/planner_react.py:tools` | 默认工具包含文件、Shell、浏览器、搜索、消息、MCP、A2A | [V] | 2026-09-06 |
| E-EVENT-001 | source | 源码 | `api/app/domain/models/event.py` | 事件类型含 plan/title/step/message/tool/wait/error/done | [V] | 2026-09-06 |
| E-INFRA-001 | source | 源码 | `api/app/infrastructure/`、`docker-compose.yml` | Redis、PostgreSQL、COS、Docker sandbox、Playwright 和 LLM 是外部边界 | [V] | 2026-09-06 |
| E-TEST-001 | command | 原实现行为实验 | `verify_source.py`，RUN-001 | 10 个原领域层/扩展行为测试通过；假模型和内存 UoW | [R] | 2026-09-06 |
| E-TEST-002 | command | 独立复刻实验 | `verify_replica.py`，RUN-002 | 8 个复刻行为测试通过；不证明原系统部署成功 | [R] | 2026-09-06 |
| E-STATE-001 | source + command | 原 ReAct | `react.py:execute_step`；RUN-001 | 失败事件后 step.status 被无条件改为 completed | [R] | 2026-09-06 |
| E-STATE-002 | source + command | 原 BaseAgent | `base.py:invoke`；RUN-001 | max_iterations=1 的实验同时得到 error 和最终 message | [R] | 2026-09-06 |
| E-PARAM-001 | source + command | 原 BaseTool | `tools/base.py:invoke`；RUN-001 | 过滤多余字段但没有 JSON Schema 类型验证；直接查询未知工具返回 ValueError 对象 | [R] | 2026-09-06 |
| E-MEMORY-001 | source + command | Memory | `models/memory.py:compact`；RUN-001 | 只移除指定浏览器结果和 reasoning_content，不做模型摘要 | [R] | 2026-09-06 |
| E-TASK-001 | source | RedisStreamTask | `infrastructure/external/task/redis_stream_task.py` | 任务注册在本进程字典，通过 asyncio.create_task 执行，Redis 只提供消息流 | [V] | 2026-09-06 |
| E-STORE-001 | source | SessionModel / Runner | `infrastructure/models/session.py`；`agent_task_runner.py:_put_and_add_event` | 事件/记忆等是 JSONB；先队列后写库，不是跨存储原子提交 | [V] | 2026-09-06 |
| E-BOOT-001 | source | API lifespan | `api/app/main.py:lifespan` | 启动自动执行 Alembic upgrade head 并初始化 Redis/Postgres/COS | [V] | 2026-09-06 |
| E-ENV-001 | command | 本机工具检查 | RUN-003 | PATH 未找到 Docker，不能开始完整容器部署 | [R] | 2026-09-06 |
| E-DIAGRAM-001 | command + review | 双层循环图 | RUN-004 | Fireworks 结构检查通过；Chrome 完整与缩小渲染检查 | [R] | 2026-09-06 |

## 范围与快照

本轮用户明确允许源码读取、依赖安装、本机启动和测试、公开网络访问。授权范围见 project.yaml；既有真实配置和个人数据仍排除。本页路径中 `api/` 相对 `sources/imooc-mas/mooc-manus/`。README 是产品说明候选证据，不用于证明部署或 Agent 行为已经成功。

未查看 Git 历史；关键实现 SHA-256：

| 相对 API app 目录的文件 | SHA-256 |
|---|---|
| domain/services/agents/base.py | 82cd9d2077678a71328fb432fa378e3b8fcf71820348cb54444b6143d57a0a2d |
| domain/services/agents/react.py | f940443334af94e8cb908e646452c2ff7c74e42d3795b2fe41468d40b8ff7fb4 |
| domain/services/agents/planner.py | 39f4b93acabe484dc666b7f81e979ffdb2bace8eafca7f14ea60f874807a73a3 |
| domain/services/flows/planner_react.py | 38ea3fcaa01757cc7828ce417ef7ab9d6b2dd7cb9a00dcaa5f1db854a46dd36e |
| domain/services/tools/base.py | 47582d5d8cacc9667daee8d4f74f59b42768ec7aabfe9106ab95d416dcc0ab0b |

## 运行记录

### RUN-001：原领域层与工具扩展

- 工作目录：本仓库根目录。
- 命令：`uv run --no-project --python 3.12 --with pydantic==2.11.9 python -B workspaces/imooc-mas/verify_source.py`。
- 环境：uv 准备 CPython 3.12.10、Pydantic 2.11.9；安装在 uv 管理环境，不写入 sources。
- 结果：退出码 0，10 tests，OK；测试直接导入原 BaseAgent、PlannerAgent、ReActAgent、BaseTool、Memory。
- 边界：模型为确定性队列，存储为内存 UoW，不导入 app.main 或运行配置，不连接 Redis/Postgres/COS/LLM。
- 副作用：下载 Python 与 Pydantic 及其依赖，创建 uv 缓存；`-B` 禁止写 Python 字节码。
- 解读：有些断言专门确认原缺陷存在，因此“测试通过”不是“原项目无缺陷”。

### RUN-002：独立复刻

- 工作目录：本仓库根目录。
- 命令：`python3 -B workspaces/imooc-mas/verify_replica.py`。
- 结果：退出码 0，8 tests，OK。
- 数据：脚本中的固定文本和合成计划；纯内存，无网络和文件数据读取。
- 覆盖：正常链路、无效参数、工具失败恢复、内外预算、等待与非法计划。
- 局限：不是原项目完整测试，不验证真实模型生成质量、持久化恢复或 UI。

### RUN-003：完整部署前置检查

- 命令：`command -v docker`。
- 结果：无路径，退出码 1；本轮未启动 Docker 容器。
- 源码补充：API lifespan 会执行数据库迁移。后续必须使用隔离测试配置与新建测试存储，不能复用未知数据库。

### RUN-004：图形检查

- 输入：`agent-loops.svg`，使用用户指定的 editorial-system-diagrams 技能。
- 命令：该技能 `scripts/fireworks_bridge.py check-svg workspaces/imooc-mas/agent-loops.svg`。
- 结果：退出码 0，XML、marker、collision、geometry、composition 全部 ok。
- 后端：已存在 Fireworks 1.2.0，无需新增安装。
- PNG 导出器缺少 renderer，Quick Look 预览有裁切；转用本地 Chrome/Playwright 检查原 SVG 的完整与缩小渲染，不把裁切预览作为交付图。

## 推断与待验证

| ID | 问题 | 验证方式 |
|---|---|---|
| E-OPEN-001 | 完整部署尚未完成，当前缺少 Docker；真实模型/COS 凭据未配置 | 隔离环境补齐服务并验证健康检查与任务链路 |
| E-OPEN-002 | SSE 事件在前端是否完整呈现所有工具内容 | 启动 UI/API 后发送测试会话并观察事件 |
| E-OPEN-003 | Planner 更新计划后是否可能重复或跳过步骤 | 使用假模型测试 Flow 状态转换 |
