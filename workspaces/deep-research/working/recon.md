# 侦察摘要

许可：可读源码、可查公开网页；未运行、未装依赖、未调用项目外部接口。以下全部来自当前源码，不是运行结果。

## 这是什么

课程向的「DeepResearch」：用户提问后，系统按意图走 **快速直答** 或 **多智能体调研**（规划 → 网络检索 + 本地知识库 → 证据裁判 → 分析 → 可能补搜 → 写报告）。模型走通义千问（DashScope / ChatTongyi）。

没有仓库根 README。产品说明主要写在前端文案和后端服务名里。

## 两套入口

| 入口 | 定位 | 用户怎么碰到 |
|---|---|---|
| 网页聊天 | `front/agent_front/src/App.vue` | 输入问题，POST `/api/v1/research/stream`，用 SSE 看进度和终稿 |
| HTTP API | `app/app_main.py` | FastAPI：`/health`、`/api/v1/research/run`、`/api/v1/research/stream` |
| 命令行 | 仓库根 `main.py` → `app/mult_agents/main.py` | 同一套图，给终端用 |

前端 Vite 把 `/api` 和 `/health` 代理到 `127.0.0.1:8000`。前端只发请求、画聊天和进度，**不跑 Agent**。

## 主链路（建议作为第一条核心链路）

1. 用户在页面发送问题（可带 user / thread / tenant）。
2. 后端 `WorkflowService` 按需注入记忆，编译并执行 LangGraph。
3. `intent`：规则关键词初判 + LLM 输出 `direct` 或 `multiagent`。
4. **直答**：一个 responder，写出 `final` 结束。
5. **调研**：`plan` 后并行 `web_search`（博查）和 `local_rag`（Milvus），再 `deep_dive` → `analyze`；不够就 `reflect` 再搜，轮次到上限则 `write`。
6. 若开了记忆，回合结束后写入记忆。
7. 前端吃 SSE：`status` / `phase` / `route` / `final` / `error`。

图定义在 `app/mult_agents/graph.py`，节点在 `app/mult_agents/nodes.py`。HTTP 包装在 `app/backend/service/workflow_service.py`（图在线程里跑，事件丢回异步队列）。

## 前端参与到哪

负责：会话壳、推荐问题、流式进度、把 Markdown 终稿渲染出来、把失败显示成一条助手消息。

不负责：意图判断、检索、证据裁决、写报告、记忆存储。侧栏的 User / Thread / Tenant 只是记忆和 checkpointer 的键，前端不解释它们的后端含义。

`front/agent_front/README.md` 仍是 Vue 脚手架说明，和现在的聊天工作台不一致，不能当产品说明。

## 跑起来大概要什么（未验证）

源码显示依赖很重，且配置里关键项是空的：

- 通义：`DASHSCOPE_API_KEY`（`config.json` 的 `api_key` 目前为空，缺了会在加载配置时报错）
- 网页检索：`BOCHA_API_KEY`（**.env.example 里没有这一项**；未配置则网络检索直接空列表）
- 记忆 / 断点：Postgres、Redis（可降级；初始化失败会打日志并弱化）
- 本地知识库：Milvus + Embedding

未实际安装或启动，环境全不全不知道。

## 测试

几乎没有项目测试。只有 `app/test/bocha_api_test.py`，还依赖真实 `BOCHA_API_KEY`。

## 和旧拆解的关系

旧试点说的「简单问答 / 复杂双源检索 / 记忆」和当前图结构对得上。旧路径 `code/deep_research` 作废。旧结论不直接当事实。

## 建议先写的文档

`01` 产品、`02` 旅程、`05` 协作、`06` 地图、`08` 主链路、`09` 思路、`11` 调试。运行手册保持「还没跑过」。

## 请你看的方向问题

1. 学习主线是否就按「页面提问 → 意图分流 → 直答或调研报告」？
2. CLI 是否只要一笔带过？
3. 记忆 / Postgres / Milvus 要写到多深？默认只写它们在链路上的位置，不展开运维。
