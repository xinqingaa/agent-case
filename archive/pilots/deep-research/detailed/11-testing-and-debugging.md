# DeepResearch 测试与调试

## 当前测试结论

仓库中只发现 `app/test/bocha_api_test.py`：它直接访问真实 Bocha API，没有自动断言、fixture、mock 或隔离配置，并硬编码疑似真实 Key。因此它是危险的手工连通性脚本，不构成可重复测试体系。[V][E-TEST-001][E-RISK-006]

尚未获得 L4，本篇没有任何 `[R]` 测试结果。

## 覆盖现状

| 层次 | 当前文件/框架 | 覆盖 | 运行状态 | 主要缺口 |
|---|---|---|---|---|
| 单元测试 | 未发现 | 无 | `[U]` | 规则、JSON fallback、ID/引用校验均未约束 |
| 节点测试 | 未发现 | 无 | `[U]` | 无固定 Agent 和检索响应 |
| API 测试 | 未发现 | 无 | `[U]` | schema、同步响应、SSE 顺序未测 |
| 前端测试 | 未发现 | 无 | `[U]` | SSE 分块、错误、Markdown 未测 |
| 端到端 | 未发现 | 无 | `[U]` | 页面到报告全链路未测 |
| 外部连通脚本 | `bocha_api_test.py` | 真实搜索调用 | 未执行 | 泄密、联网、无断言 |

## 核心链路覆盖矩阵

| 行为 | 正常路径测试 | 失败路径测试 | 当前状态 |
|---|---|---|---|
| 规则 + LLM 意图路由 | 固定 route 响应，验证 direct/multiagent | 非法 JSON/非法 route 回退 | 缺失 |
| 搜索计划约束 | 验证去重、grounding 和最多六条 | 空 outline、无关查询 | 缺失 |
| Web/Local 双路检索 | 固定两路 records，验证 ID 和合并 | 单侧/双侧为空、异常 | 缺失 |
| 证据池审计 | 只保留合法 ID，生成 source index | LLM 编造 ID、空池 | 缺失 |
| Reflect 循环 | 缺口触发第二轮，证据累积 | 达到上限强制写作 | 缺失 |
| Writer 引用 | 合法引用保留并追加列表 | 非法/重复/无引用 | 缺失 |
| SSE | status → phase* → route → final | error、分块跨边界、断连 | 缺失 |
| 记忆 | 执行前注入、执行后保存 | 各后端失败与隔离碰撞 | 缺失 |

## 推荐测试金字塔

### P0：纯函数单元测试

优先测试无需模型和数据库的函数：

- `detect_intent`
- `_load_json`、`_extract_json_block`
- `_derive_search_plan`、`_build_queries`
- `_assign_source_ids`、`_prune_evidence_to_allowed_sources`
- `_validate_and_fix_citations`、`_render_reference_list`
- `route_after_intent`、`should_continue_research`

完成标准：固定输入得到确定输出，覆盖空值、非法 JSON、重复来源、非法引用和迭代边界。

### P1：节点与图集成测试

用 Fake Agent 返回固定 messages，用 monkeypatch 替换 Bocha/RAG 函数；编译内存 checkpointer 图，分别覆盖 direct、一次研究、补搜和空证据。不能访问网络或真实数据库。

### P1：API/SSE 测试

使用 FastAPI 测试客户端并注入 Fake WorkflowService，验证 Pydantic 422、JSON response schema、SSE event type/顺序和 error 事件。特别构造一个 JSON 被拆成多个字节块的场景验证前端 buffer。

### P2：前端与端到端

前端测试 `runResearch` 的加载态、final、error 和分块解析。端到端只在本地 Fake 后端上先跑；真实模型/搜索作为显式 opt-in 的慢测试，必须限制预算和记录副作用。

## 调试地图

| 症状 | 首先观察 | 关键位置 | 下一步 |
|---|---|---|---|
| `/health` 正常但研究失败 | SSE error 和后端首个异常 | `WorkflowService::_ensure_initialized` | 检查 config path、DashScope Key 和导入 |
| 页面一直“处理中” | Network 响应是否继续收块 | `App.vue::runResearch`、worker thread | 查是否缺 `__done__`、final 或客户端断开 |
| 总走 direct | intent phase 与规则关键词 | `detect_intent`、`intent_node` | 记录规则初判和 LLM route |
| Web 证据为 0 | Key 是否配置、Bocha HTTP 日志 | `bocha_web_search_records` | 检查 30 秒超时、响应结构；勿输出 Key |
| Local 证据为 0 | RAG 初始化日志、collection | `init_rag_system`、`RAGSystem.search_records` | 检查 Milvus、Embedding、是否已入库 |
| 报告有来源但结论弱 | evidence pool/findings/claim map | Deep Dive、Analyze、Writer | 区分“ID 存在”和“语义支持” |
| 补搜不停或不补搜 | iteration/max/needs_more | `should_continue_research`、Reflect | 核对迭代加一时点和 fallback |
| 跨用户出现上下文 | thread ID、后端实际降级 | checkpointer/MemoryManager | 检查 namespace 和租户隔离 |
| 已生成结果却返回 error | 记忆写入日志 | `persist_turn` | 验证 Web 路径未隔离记忆异常 |

## 日志与可观测性

已有日志覆盖节点开始、输入预览、LLM 调用、检索数量、来源 trace、记忆注入和后端降级。[V][E-FLOW-003][E-FLOW-006][E-DATA-002]

主要问题：

- 没有 request/trace ID 贯穿前端、API、图和外部调用。
- 日志可能包含用户问题、记忆预览和报告片段，存在隐私风险。
- Bocha 日志输出 Key 前八位，不应保留。[V][E-RISK-009]
- 没有结构化延迟、token、成本、错误率和每节点重试指标。
- SSE 只向用户展示最近六条阶段消息，不等于完整审计记录。

## L4 执行顺序

获得授权后按低副作用到高副作用执行：

1. 记录 Python/Node/npm 版本。
2. 只做 Python 编译/导入检查与前端类型检查/构建。
3. 运行新增或现有的离线测试；当前危险 Bocha 脚本默认排除。
4. 以记忆关闭、外部检索关闭的最小配置启动后端并验 `/health`。
5. 用 Fake/受控请求验证 direct 和 SSE。
6. 外部 API、Milvus 和数据库验证分别申请明确副作用范围；涉及数据读取则进入 L5。

## 调试完成标准

一个问题只有在“复现输入、环境、节点、实际值、预期值和修复后测试”都记录后才算定位；不能用一次正常响应代替回归测试。
