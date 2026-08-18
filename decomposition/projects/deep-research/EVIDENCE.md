# DeepResearch 证据台账

## 状态说明

- `[R]`：运行验证
- `[V]`：静态验证
- `[C]`：用户确认
- `[I]`：合理推断
- `[U]`：未知

当前阶段为 L3 静态源码分析，尚无 `[R]` 运行证据。

## 证据记录

| ID | 类型 | 来源 | 位置或配置项 | 支持的结论 | 状态 | 采集日期 |
|---|---|---|---|---|---|---|
| E-USER-001 | user | 当前对话 | 用户明确回复“开始 我同意” | 允许对 `code/deep_research` 进行 L3 全局搜索和选择性源码/测试阅读；不包含运行、安装或数据读取 | `[C]` | 2026-08-18 |
| E-BOOT-001 | config | `code/deep_research/pyproject.toml` | `project.requires-python` | Python 版本要求为 `>=3.10` | `[V]` | 2026-08-18 |
| E-BOOT-002 | config | `code/deep_research/.env.example` | 全部变量名，不含真实值 | 项目声明模型、租户、会话、记忆、PostgreSQL、Redis、Milvus 等配置入口 | `[V]` | 2026-08-18 |
| E-BOOT-003 | config | `code/deep_research/front/agent_front/package.json` | `engines.node`、`scripts` | 前端要求 Node `^20.19.0` 或 `>=22.12.0`，候选命令包括 `npm run dev` 和 `npm run build` | `[V]` | 2026-08-18 |
| E-BOOT-004 | config | `code/deep_research/front/agent_front/vite.config.ts` | `server` | 前端候选端口为 5173，`/api` 和 `/health` 代理到 `127.0.0.1:8000` | `[V]` | 2026-08-18 |
| E-BOOT-005 | docs | `docs/deep_research/deep_research_setup.md` | “启动”章节 | 文档给出 Python、依赖安装、Milvus/PostgreSQL、后端和前端启动候选步骤，但尚未执行 | `[I]` | 2026-08-18 |
| E-BOOT-006 | source | `app/mult_agents/config.py`、`app/backend/config/settings.py`、`config.json` | `AppConfig.from_file`、`AppSettings` | 运行配置按环境变量→config→默认值解析；DashScope Key 为硬要求，Web 配置单独由 BaseSettings 读取 | `[V]` | 2026-08-18 |
| E-ARCH-001 | manifest | `code/deep_research/pyproject.toml` | `project.dependencies` | 项目声明 LangGraph、FastAPI、LangChain、Milvus、PostgreSQL、Redis、DashScope 等核心依赖 | `[V]` | 2026-08-18 |
| E-ARCH-002 | manifest | `code/deep_research/requirements.txt` | 完整锁定列表 | 依赖清单包含 FastAPI、Flask、SSE、MCP、LangGraph 和多种存储客户端，范围大于 `pyproject.toml` | `[V]` | 2026-08-18 |
| E-ARCH-003 | directory | `code/deep_research/` | 四层目录轮廓 | 项目包含后端、智能体、记忆、RAG、测试、数据、Vue 前端和输出目录 | `[V]` | 2026-08-18 |
| E-ARCH-004 | config | `code/deep_research/front/agent_front/package.json` | dependencies/devDependencies | 前端为 Vue 3、TypeScript 和 Vite 工具链 | `[V]` | 2026-08-18 |
| E-ARCH-005 | config | `code/deep_research/front/agent_front/tsconfig.app.json` | compilerOptions | 前端启用未检查索引访问保护并配置 `@/*` 路径别名 | `[V]` | 2026-08-18 |
| E-PROD-001 | docs | `docs/deep_research/deep_research_overview.md` | 项目亮点 | 现有说明将项目定位为多 Agent 深度研究助手，并声明双源检索、证据审计、补搜、记忆和 Web/CLI 能力；需源码和运行确认 | `[I]` | 2026-08-18 |
| E-PROD-002 | docs | `docs/deep_research/deep_research_core_breakdown.md` | 背景、定位、架构和运行章节 | 现有拆解描述投资研究、技术调研、竞品分析等场景及八类 Agent；当前仅作为候选产品模型 | `[I]` | 2026-08-18 |
| E-VCS-001 | git | repository history | `e763b98a...` / 2026-06-15 | `code/deep_research` 最近可见提交主题为“feat: 项目整理” | `[V]` | 2026-08-18 |
| E-ARCH-006 | source | `code/deep_research/app/app_main.py` | `create_app`、模块级 `app` | Web 入口创建 FastAPI、启用 CORS 并注册健康与研究路由 | `[V]` | 2026-08-18 |
| E-ARCH-007 | source | `code/deep_research/main.py` | `_bootstrap`、`main` | 根入口负责加载 `.env` 并转交 `mult_agents.main.main`，是 CLI 入口 | `[V]` | 2026-08-18 |
| E-ARCH-008 | source | `code/deep_research/app/mult_agents/graph.py` | `build_app` | 当前 LangGraph 使用 `nodes.py` 中的节点；`mult_agents/main.py` 顶部同名节点未被当前图引用 | `[V]` | 2026-08-18 |
| E-ARCH-009 | source | `code/deep_research/app/mult_agents/main.py` | `build_agents` | 构造八个 LLM Agent，所有 Agent 的 tools 列表为空，检索由节点函数直接调用 | `[V]` | 2026-08-18 |
| E-ARCH-010 | source-search | `code/deep_research` | Neo4j/MySQL/Flask/MCP/WebSocket 引用搜索 | 当前实现源码未发现 Neo4j、MySQL、Flask、MCP 或 WebSocket 调用；相关依赖/文档可能过时 | `[V]` | 2026-08-18 |
| E-FLOW-001 | source | `code/deep_research/front/agent_front/src/App.vue` | `runResearch` | 前端 POST `/api/v1/research/stream`，逐块解析 `data:` SSE 事件并渲染阶段和最终结果 | `[V]` | 2026-08-18 |
| E-FLOW-002 | source | `code/deep_research/app/backend/router/research_router.py` | `stream_research`、`run_research` | 后端提供同步 JSON 与 SSE 两种研究接口，SSE 类型为 `text/event-stream` | `[V]` | 2026-08-18 |
| E-FLOW-003 | source | `code/deep_research/app/backend/service/workflow_service.py` | `_ensure_initialized`、`_run_sync_with_events`、`stream_events` | 服务懒初始化配置/记忆/Agent/图，并把图节点更新桥接为异步事件流 | `[V]` | 2026-08-18 |
| E-FLOW-004 | source | `code/deep_research/app/mult_agents/graph.py` | `route_after_intent`、`should_continue_research`、`build_app` | 图先意图分流；复杂问题进入计划、双路检索、证据审计、分析、可选补搜和写作 | `[V]` | 2026-08-18 |
| E-FLOW-005 | source | `code/deep_research/app/mult_agents/nodes.py` | `detect_intent`、`intent_node`、`plan_node` | 意图由规则初判加 LLM JSON 复核；规划结果被约束为最多六个与原问题相关的搜索词 | `[V]` | 2026-08-18 |
| E-FLOW-006 | source | `code/deep_research/app/mult_agents/nodes.py` | `web_search_node`、`local_rag_node`、`deep_dive_node` | Web/本地检索生成受控 source ID，LLM 结果会裁剪到真实输入来源，再形成证据池和来源索引 | `[V]` | 2026-08-18 |
| E-FLOW-007 | source | `code/deep_research/app/mult_agents/nodes.py` | `analyze_node`、`reflect_node`、`write_node` | 分析判断缺口；Reflect 增加迭代并生成补搜；Writer 只允许合法来源 ID 并追加参考资料 | `[V]` | 2026-08-18 |
| E-FLOW-008 | source | `code/deep_research/app/mult_agents/tools.py` | `bocha_web_search_records` | 网络检索直接调用 Bocha HTTPS API；缺少 `BOCHA_API_KEY` 时返回空证据 | `[V]` | 2026-08-18 |
| E-DATA-001 | source | `code/deep_research/app/mult_agents/state.py` | `ResearchState`、`create_initial_state` | 共享状态覆盖查询、计划、证据、分析、引用、追踪、最终稿和迭代计数 | `[V]` | 2026-08-18 |
| E-DATA-002 | source | `code/deep_research/app/mult_agents/memory/manager.py` | `build_personalized_prompt_context`、`persist_turn` | 每轮前可注入画像/摘要/相关记忆，每轮后保存短期消息并按关键词提取长期事实或偏好 | `[V]` | 2026-08-18 |
| E-DATA-003 | source | `code/deep_research/app/mult_agents/main.py` | `build_checkpointer` | 检查点按 PostgreSQL → Redis → 内存降级，实际调用只传 `thread_id` | `[V]` | 2026-08-18 |
| E-TEST-001 | source | `code/deep_research/app/test/bocha_api_test.py` | 全文件 | 唯一发现的测试文件是直接调用真实 Bocha API 的手工脚本，没有自动断言或隔离 | `[V]` | 2026-08-18 |
| E-RISK-001 | source | `code/deep_research/app/backend/router/research_router.py`、`App.vue` | 请求模型与输入控件 | API 无认证/授权，客户端可直接提交 tenant/user/thread 标识，存在身份冒用和成本滥用风险 | `[V]` | 2026-08-18 |
| E-RISK-002 | source | `code/deep_research/app/backend/service/workflow_service.py` | LangGraph configurable | checkpointer 命名空间只使用 `thread_id`，相同 thread ID 可能跨用户/租户共享图状态 | `[V]` | 2026-08-18 |
| E-RISK-003 | source | `memory/short_term.py`、`memory/long_term.py`、`memory/manager.py` | 内存/SQLite 降级路径 | 内存短期记忆仅以 thread ID 为键，SQLite 长期记忆不含 tenant 列，降级时租户隔离不完整 | `[V]` | 2026-08-18 |
| E-RISK-004 | source | `code/deep_research/app/mult_agents/rag/ingest.py` | imports、`INPUT_PATH` | 导入脚本含旧包路径和开发者绝对路径，当前仓库下不能作为通用入库命令 | `[V]` | 2026-08-18 |
| E-RISK-005 | source | `code/deep_research/app/mult_agents/nodes.py` | `_filter_web_records`、`_filter_local_records` 与检索节点 | 定义了相关性过滤函数，但当前检索节点只调用最小非空过滤，文档所述规则过滤并未接入主链路 | `[V]` | 2026-08-18 |
| E-RISK-006 | source+git | `code/deep_research/app/test/bocha_api_test.py` | `main` | Git 跟踪文件中硬编码疑似真实 API Key；应立即轮换并清理历史，不应对外验证 | `[V]` | 2026-08-18 |
| E-RISK-007 | file+git | `code/deep_research/app/data/memory.db` | 40 KB Git 跟踪文件，内容未读取 | 仓库提交了运行时记忆数据库，存在携带用户或会话数据的潜在泄露风险 | `[I]` | 2026-08-18 |
| E-RISK-008 | config+source | `.env.example`、`config.json`、`tools.py`、`settings.py` | 配置键对照 | 环境模板遗漏实际 Web 检索所需的 `BOCHA_API_KEY` 及 Web 服务字段；默认配置开启多个外部后端但连接值为空 | `[V]` | 2026-08-18 |
| E-RISK-009 | source | `app/mult_agents/tools.py`、`memory/manager.py`、`nodes.py` | 检索和上下文日志 | 日志会输出 Bocha Key 前缀以及用户问题/记忆内容预览，存在敏感信息进入日志的风险 | `[V]` | 2026-08-18 |

## 用户确认

| ID | 确认内容 | 适用范围 | 日期 |
|---|---|---|---|
| E-USER-001 | 同意开始完整项目拆解并允许读取源码；当前记录为 L3 | `code/deep_research` 的全局搜索和选择性源码/测试阅读 | 2026-08-18 |

## 推断、冲突与待验证项

| ID | 当前问题 | 间接证据 | 验证方式 | 优先级 |
|---|---|---|---|---|
| E-OPEN-001 | 实际主入口是根 `main.py`、`app/app_main.py` 还是二者分别承载 CLI/Web | E-ARCH-003、E-PROD-001 | L2/L3 阅读入口和调用点 | P0 |
| E-OPEN-002 | 实际流式协议是 SSE、WebSocket，还是仅 SSE | 说明文档同时出现 SSE 与 WebSocket；requirements 含 `sse-starlette` | L2/L3 阅读路由、服务和前端消费代码；L4 浏览器验证 | P0 |
| E-OPEN-003 | Neo4j 和 MySQL 是否属于本项目必需依赖 | 环境文档包含部署步骤，但 `.env.example`、`pyproject.toml` 未声明相应配置或客户端 | L3 全局搜索引用；L4 最小依赖启动 | P1 |
| E-OPEN-004 | `requirements.txt` 与 `pyproject.toml` 哪一个是权威依赖源，Flask 是否仍在使用 | E-ARCH-001、E-ARCH-002 | L3 搜索导入与启动方式；L4 构建验证 | P0 |
| E-OPEN-005 | Bocha 搜索是否实际启用以及密钥从哪里配置 | 现有文档提及 Bocha，但 `.env.example` 无 `BOCHA_API_KEY` | L3 阅读工具和配置加载代码 | P0 |
| E-OPEN-006 | PostgreSQL、Redis、Milvus 哪些是强依赖，哪些有内存或禁用降级 | `.env.example` 提供多个 backend 和 enable 开关 | L3 阅读配置分支；L4 逐级启动矩阵 | P0 |
| E-OPEN-007 | 文档中的质量、准确率、时延和提升比例是否有可复现评测 | 现有拆解包含多组指标，尚未发现评测清单或运行记录 | L3 查找评测数据/脚本；若存在则 L4 复现 | P0 |
| E-OPEN-008 | 八个 Agent、反思补搜和引用校验是否与当前实现一致 | E-PROD-001、E-PROD-002 | L3 追踪 graph/state/nodes/prompts 和测试 | P0 |
| E-OPEN-009 | 浏览器断开或取消后，后台研究线程是否继续调用模型/搜索 | E-FLOW-001、E-FLOW-003 | L4 以 Fake 外部调用做断连/取消测试 | P1 |

## 已由 L3 解决的问题

- E-OPEN-001：根 `main.py` 是 CLI 入口，`app/app_main.py` 是 Web 入口，两者共享 LangGraph 构建逻辑。[V][E-ARCH-006][E-ARCH-007]
- E-OPEN-002：当前前后端实现使用 SSE，不存在 WebSocket 调用。[V][E-FLOW-001][E-FLOW-002][E-ARCH-010]
- E-OPEN-003：当前实现未发现 Neo4j/MySQL 使用，可从本项目必需环境中移除，除非用户确认其外部用途。[V][E-ARCH-010]
- E-OPEN-005：Bocha 是当前 Web 检索实现，`BOCHA_API_KEY` 应加入环境模板。[V][E-FLOW-008]
- E-OPEN-006：PostgreSQL、Redis、Milvus 均有配置相关降级；DashScope 模型 Key 是硬要求，记忆可关闭，Web/Local 检索可分别退为空证据。[V][E-BOOT-006][E-DATA-002][E-DATA-003]
- E-OPEN-008：当前图具有八个独立 Agent 对象，Reflect 复用 Planner，完整复杂链路已由源码确认。[V][E-ARCH-009][E-FLOW-004]

## 当前证据限制

- 已选择性读取当前核心实现和测试源码，但没有穷举逐文件审计所有非核心代码。
- 未读取真实 `.env`。
- 未安装依赖、启动服务、执行测试或访问外部 API。
- 现有 `docs/deep_research` 中的代码片段和指标尚未与当前源码逐项核对。
