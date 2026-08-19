# DeepResearch 学习练习

## 练习原则

Level 1/2 只读当前源码即可完成。Level 3/4 涉及修改和运行，必须在独立分支或临时副本中，并等待 L4；不要在当前原项目直接练习，不要使用真实 Key 或用户数据。

## Level 1：观察项目

### 练习 1：从产品动作定位代码

- 目标：从“用户发送问题”定位完整入口。
- 操作：依次找前端 fetch、FastAPI route、service 方法和 graph 调用。
- 完成标准：写出四个路径/符号和调用顺序，并说明同步 API 与 SSE API 的共同点。
- 验证：`rg -n "runResearch|stream_research|stream_events|_app.stream" code/deep_research`
- 参考：`08-core-flow-main.md`、E-FLOW-001、E-FLOW-002、E-FLOW-003、E-FLOW-004。

### 练习 2：画出真实 LangGraph

- 目标：只依据源码还原节点和边。
- 操作：阅读 `graph.py::build_app`、两个路由函数和 `should_continue_research`。
- 完成标准：图包含 START、九个节点、两个 END 路径和 Reflect 循环；标出八个 Agent 对象与九个节点的差异。
- 验证：与 `05-architecture.md` 的图逐边对照。

### 练习 3：区分四类持久状态

- 目标：区分 ResearchState、checkpointer、MemoryManager、本地知识库。
- 操作：为每类写出用途、生命周期、主键/隔离键和失败后果。
- 完成标准：不能把 Milvus 知识检索说成对话记忆，也不能把 checkpointer 说成最终报告数据库。
- 参考：`07-domain-and-data.md`、E-DATA-001、E-DATA-002、E-DATA-003。

## Level 2：解释代码

### 练习 4：追踪一个 source ID

- 需要阅读：`web_search_node`、`_assign_source_ids`、`_prune_evidence_to_allowed_sources`、`deep_dive_node`、`write_node`。
- 问题：`WEB2_3-4` 三段数字各表示什么？LLM 在哪几处被禁止新增 ID？非法引用如何处理？
- 完成标准：从 Bocha record 讲到最终参考资料，并指出合法 ID 不等于语义正确。

### 练习 5：推演补搜边界

- 需要阅读：`should_continue_research`、`analyze_node`、`reflect_node`、`_build_queries`。
- 给定：`iteration=1`、`max_iterations=2`、`needs_more_research=true`。
- 要回答：下一节点是什么？何时 iteration 加一？下一轮使用哪个计划？第二次 Analyze 后还会不会 Reflect？
- 判定：答案必须按实际比较顺序说明，而不是只说“最多两轮”。

### 练习 6：解释 SSE 不是 token 流

- 需要阅读：`_run_sync_with_events`、`stream_events`、`App.vue::runResearch`。
- 完成标准：指出 `stream_mode="updates"`、phase 事件、final 一次性返回和前端字节 buffer 四个证据。

### 练习 7：做一次风险评审

- 目标：为 API 身份、checkpoint 和记忆降级各写一条攻击/串用场景。
- 完成标准：每条包含前置条件、受影响数据、源码依据和可执行测试，不读取现有数据库内容。
- 参考：E-RISK-001、E-RISK-002、E-RISK-003。

## Level 3：局部修改（等待 L4）

### 练习 8：建立纯函数测试

- 目标：为意图、JSON fallback、source ID 和引用校验建立离线测试。
- 修改范围：新测试目录，不改生产行为。
- 不允许：网络、真实 Key、数据库、依赖全局状态。
- 验收：覆盖正常、空输入、非法 JSON、编造 ID、重复来源和迭代上限；测试可重复运行。

### 练习 9：接入相关性过滤

- 目标：让当前未使用的 `_filter_web_records/_filter_local_records` 进入检索链路。
- 约束：保留 raw/kept/rejected trace；不能只凭一次报告主观判断改善。
- 验收：用固定 records 比较修改前后召回、误删和统计字段；为官方域名例外写测试。
- 风险：启发式中文分词和 0.2 阈值可能误删相关来源。

### 练习 10：隔离记忆异常

- 目标：图已生成 final 时，记忆写入失败不覆盖主结果，同时产生可观察告警。
- 修改范围：`WorkflowService` 的执行收尾与测试。
- 不变量：成功时仍保存记忆；失败必须记录 tenant/user/thread 的脱敏 trace，不泄露正文。
- 验收：Fake MemoryManager 抛错时同步和 SSE 均返回 final，另有错误指标/日志。

## Level 4：跨模块扩展（等待 L4/L5 范围确认）

### 练习 11：统一上下文键

- 用户故事：不同 tenant/user 使用相同 thread ID 时，图状态和记忆完全隔离。
- 涉及：请求身份、WorkflowService、LangGraph configurable、各记忆后端、清理命令、测试。
- 设计约束：身份必须来自可信服务端；所有降级后端保持相同隔离语义。
- 验收：并发提交四组相同 thread ID，请求间无法看到彼此 state、消息、画像和任务。
- 建议步骤：定义不可变 `ContextKey` → 统一 namespace → 迁移/兼容 → fake 测试 → 后端矩阵测试。

### 练习 12：可取消研究任务

- 用户故事：用户离开页面或点击取消后，后台停止后续模型和搜索调用。
- 涉及：Vue AbortController、FastAPI 断连、WorkflowService worker、图取消/超时、外部调用。
- 验收：取消后不再产生新 phase/外部调用，任务状态明确，资源在限定时间内释放。

### 练习 13：建立引用质量评测

- 用户故事：发布前能量化“结论是否被来源支持”，而不只是编号存在。
- 数据：脱敏问题集、来源快照、人工 claim-source 标签。
- 指标：引用合法率、引用支持率、结论覆盖率、无来源 claim 比例；分别定义分母。
- 验收：固定版本可复现，报告包含环境、数据集版本、日期和置信区间/样本数。

## 自测清单

- [ ] 能从用户动作定位到入口和图。
- [ ] 能画出 direct 和补搜路径。
- [ ] 能解释关键状态、引用约束和失败降级。
- [ ] 能区分已验证事实、推断和未知。
- [ ] 能说明至少三个 P0/P1 风险及验证方法。
- [ ] 不引用旧文档中无评测支撑的数字。
