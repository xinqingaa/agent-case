# MoocManus 源码学习路线

1. 先读 `foundation-project.md` 与 `foundation-journeys.md`，确认用户价值和入口。
2. 阅读 `api/app/interfaces/endpoints/`，把 HTTP、SSE、WebSocket 映射到应用服务。
3. 阅读 `domain/services/flows/` 和 `agents/`，理解 Planner → ReAct 的循环、停止条件和事件产出。
4. 阅读 `domain/services/tools/`，比较 MCP、A2A、浏览器、文件和 Shell 工具的统一边界。
5. 阅读 `domain/models/event.py`、`task.py`、`tool_result.py` 与 Redis message queue，追踪一次任务的状态。
6. 阅读 `infrastructure/external/` 和 repositories，理解外部依赖如何被适配。
7. 最后回到 `foundation-core-flow-main.md`，按一条会话链路核对入口、状态、工具、输出和失败。

完成标准：能够说明 Agent loop 每一轮的输入、决策、工具结果、下一轮条件和终止输出，并指出 UI、API、领域服务与基础设施的边界。
