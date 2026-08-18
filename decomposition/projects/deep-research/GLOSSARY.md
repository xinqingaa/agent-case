# DeepResearch 术语表

| 术语 | 初学者解释 | 本项目中的具体含义 | 首次文档 | 证据 |
|---|---|---|---|---|
| Agent | 带角色提示词调用模型的执行单元 | 八个 `create_agent` 对象，工具列表为空 | `01-project-and-product.md` | `[V]` E-ARCH-009 |
| LangGraph | 用状态、节点和边描述工作流的框架 | 编排 direct 与研究/补搜路径 | `02-product-journeys.md` | `[V]` E-FLOW-004 |
| ResearchState | 节点共享的数据字典 | 保存请求、计划、证据、分析、输出和迭代 | `05-architecture.md` | `[V]` E-DATA-001 |
| Node | 图中的一个处理阶段 | Intent、Plan、Web、Local、Judge 等九个节点 | `02-product-journeys.md` | `[V]` E-FLOW-004 |
| Conditional Edge | 根据状态选择下一节点的边 | 意图分流和 Analyze 后是否补搜 | `05-architecture.md` | `[V]` E-FLOW-004 |
| Direct | 快速回答路径 | Intent 后直接调用 Direct Responder | `02-product-journeys.md` | `[V]` E-FLOW-005 |
| Multiagent | 完整研究路径 | 规划、双路检索、审计、分析、补搜/写作 | `02-product-journeys.md` | `[V]` E-FLOW-004 |
| Planner | 把问题拆成结构和查询的角色 | 生成 outline、子问题、搜索计划；也供 Reflect 复用 | `02-product-journeys.md` | `[V]` E-FLOW-005 |
| Reflect | 针对证据缺口规划补搜 | 图节点，复用 Planner Agent 并增加 iteration | `02-product-journeys.md` | `[V]` E-FLOW-007 |
| RAG | 检索资料再交给模型生成 | 本地文档经 Embedding 在 Milvus 相似检索 | `04-stack-and-dependencies.md` | `[V]` E-FLOW-006 |
| Embedding | 把文本映射成向量 | DashScope Embedding 用于知识/记忆检索 | `04-stack-and-dependencies.md` | `[V]` E-ARCH-001 |
| Milvus | 向量数据库 | 保存本地知识 chunk，也可索引长期记忆 | `05-architecture.md` | `[V]` E-FLOW-006、E-DATA-002 |
| Bocha | Web 搜索 API | `tools.py` 直接发 HTTPS POST 获取网页记录 | `01-project-and-product.md` | `[V]` E-FLOW-008 |
| Evidence | 可供报告引用的检索记录 | 带受控 source ID 的 Web/Local 记录 | `01-project-and-product.md` | `[V]` E-FLOW-006 |
| Evidence Pool | 合并审计后的证据集合 | Deep Dive 产出，Analyze 消费 | `07-domain-and-data.md` | `[V]` E-FLOW-006 |
| Finding | 研究结论及其来源映射 | Analyst 产出，Writer 用于写报告 | `07-domain-and-data.md` | `[V]` E-FLOW-007 |
| Source ID | 一次检索结果的受控编号 | 如 `WEB1_1-1`、`LOC1_1-1` | `07-domain-and-data.md` | `[V]` E-FLOW-006 |
| SSE | 服务端在一个 HTTP 响应中连续发文本事件 | POST 流中发送阶段和最终结果 | `02-product-journeys.md` | `[V]` E-FLOW-001、E-FLOW-002 |
| Checkpointer | 保存图执行状态的组件 | PostgreSQL/Redis/内存 saver，当前只传 thread ID | `05-architecture.md` | `[V]` E-DATA-003 |
| Short-term Memory | 当前会话附近的消息和摘要 | PostgreSQL/Redis/内存后端 | `01-project-and-product.md` | `[V]` E-DATA-002 |
| Long-term Memory | 跨会话保留的画像、事实或任务 | PostgreSQL/SQLite，Milvus 可增强检索 | `07-domain-and-data.md` | `[V]` E-DATA-002 |
| Fallback | 主解析/后端失败后的备用行为 | JSON 默认值、空证据、存储降级 | `08-core-flow-main.md` | `[V]` E-FLOW-005、E-FLOW-006、E-FLOW-007、E-FLOW-008、E-DATA-003 |
| Tenant | 多租户系统中的组织隔离标识 | 请求字段存在，但无可信认证且降级隔离不完整 | `01-project-and-product.md` | `[V]` E-RISK-001、E-RISK-002、E-RISK-003 |
| Trace | 用于解释一次执行的阶段/检索/记忆记录 | 状态中有 search trace，MemoryManager 有 last trace | `07-domain-and-data.md` | `[V]` E-FLOW-006、E-DATA-002 |
