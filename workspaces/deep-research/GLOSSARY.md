# Deep Research 术语表

| 术语 | 在本项目中的含义 | 首次出现文档 | 定位 |
|---|---|---|---|
| DeepResearch | 产品名，聊天式研究工作台 | `01-project-and-product.md` | 前端文案、FastAPI title |
| intent / 意图分流 | 只在 `direct` 与 `multiagent` 之间选择 | `09-capabilities-and-thinking.md` | `nodes.py` `detect_intent` / `intent_node` |
| SSE | 后端按节点推 JSON 事件，不是 token 流 | `02-product-journeys.md` | `research_router.py` |
| 博查 | 网页检索供应商 | `10-interfaces-and-integrations.md` | `tools.py` |
| Evidence Judge | `deep_dive` 节点的对外名称 | `08-core-flow-main.md` | `WorkflowService._node_message` |
| thread_id | 图 checkpointer 与前端会话键 | `07-domain-and-data.md` | 请求 JSON |
| memory_context | 本轮注入 prompt 的跨会话记忆文本 | `08-core-flow-main.md` | `WorkflowService` |
| final | 给用户看的最终正文 | `08-core-flow-main.md` | ResearchState / SSE |
