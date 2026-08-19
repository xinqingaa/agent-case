# Deep Research 技术栈与依赖

## 阅读说明

- 前置知识：环境候选
- 阅读目标：哪些技术真的参与协作，而不是清单扫描
- 预计时间：8 分钟
- 当前把握：已按源码核对 / 还没跑过

## 技术栈总览

| 层次 | 技术 | 版本约束 | 在项目中的职责 |
|---|---|---|---|
| 前端 | Vue 3 + Vite + TypeScript | package.json | 聊天工作台与 SSE |
| HTTP | FastAPI + Uvicorn | requirements 钉死 | API 与 CORS |
| 编排 | LangGraph 1.x | requirements | 研究图 |
| 模型 | langchain-community ChatTongyi + dashscope | requirements | 各角色生成 |
| 网页检索 | 博查 HTTP API | 无 SDK 钉死 | `urllib` POST |
| 向量 | pymilvus + langchain-milvus | requirements | 本地库 / 记忆向量 |
| 存储 | Postgres、Redis、可选 SQLite | requirements | 记忆与 checkpointer |

## 关键依赖

只记录会改变架构、运行方式或核心链路的依赖，不把 Vue 常用库展开成教程。

| 依赖 | 使用位置 | 解决的问题 | 可替代方案 | 影响范围 |
|---|---|---|---|---|
| langgraph | `graph.py` | 节点、条件边、并行边 | 自己写状态机 | 整个研究路径 |
| ChatTongyi | `main.py` `build_agent` | 通义聊天模型 | 换 LangChain 聊天模型 | 所有 LLM 节点 |
| fastapi | `app_main.py` | HTTP 与 SSE | Flask 也在 requirements 里但 HTTP 入口是 FastAPI | 网页对接 |
| pymilvus / langchain-milvus | `rag/core.py`、memory | 本地检索 | 关掉则本地库为空 | 调研质量 |
| psycopg / redis | memory、checkpointer | 会话状态 | InMemorySaver 等降级 | 记忆是否跨进程 |

`requirements.txt` 里还有 Flask、flask-cors、openai、mcp 等。当前 HTTP 入口和前端对接走的是 FastAPI，不以 Flask 为产品路径。

## 开发依赖与生产依赖

前端把 Vite、vue-tsc 放在 devDependencies。Python 未明显拆分 prod/dev。

## 版本与兼容性

| 约束 | 来源 | 不满足时的表现 | 已核实环境 |
|---|---|---|---|
| Python >=3.10 | pyproject.toml | 未验证 | 还没跑过 |
| Node 20.19+ 或 22.12+ | package.json engines | 未验证 | 还没跑过 |

## 技术选型结论

编排和模型层决定了「这是一套研究流水线」。前端只是工作台。清单里多出来的 Flask/MCP/OpenAI 客户端，没有在主链路上看到使用，当作可能残留，不要当成第二条产品架构。

## 本项目需要补的概念

1. LangGraph 状态图：节点产出写进共享 state，条件边决定下一跳；本项目用它做分流和补搜循环。
2. RAG：问题变成向量，去 Milvus 里找相近文本；本项目把它当「本地证据源」，不是单独产品。
3. Checkpointer：让图可以按 `thread_id` 记住图状态；失败则退回内存或告警。

## 完成判定与下一步

- 完成判定：能区分主链路技术和清单残留。
- 下一篇：`05-architecture.md`
