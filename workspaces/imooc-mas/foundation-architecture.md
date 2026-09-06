# MoocManus 架构与协作

系统入口由 Nginx 汇聚到 Next.js UI 和 FastAPI API。API 按 application、domain、infrastructure、interfaces 分层：接口层接收会话/文件请求，应用服务编排用例，领域层包含 Agent、Flow、Tool 和模型，基础设施层连接 Redis、PostgreSQL、COS、Docker、Playwright、搜索和 LLM。

Agent 运行的主要抽象是 `AgentTaskRunner`、`domain/services/agents/` 与 `domain/services/flows/`。规划 Agent 与 ReAct Agent 由 Flow 组合；工具位于 `domain/services/tools/`，包括 browser、file、MCP、message、search、shell 和 A2A。模型、事件、计划、工具结果等领域对象位于 `domain/models/`。

运行时方向为：HTTP/WS → session service → agent task runner → flow → agent/tool → message queue 与持久化 → SSE/WS/UI。Redis 同时承担消息流和任务协作，PostgreSQL 保存会话/文件等关系数据，COS 保存文件对象，沙箱隔离浏览器和命令操作。

这是基于分层架构的 Agent 工作流系统；“多 Agent”不能简单理解为每个 Agent 都拥有独立服务，实际协作由 Flow 和工具注册决定。
