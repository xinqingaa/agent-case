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
| E-RUN-001 | command | terminal | 未执行；尚未启动容器 | 运行基线仍未知 | [U] | 2026-09-06 |

## 推断与待验证

| ID | 问题 | 验证方式 |
|---|---|---|
| E-OPEN-001 | 本地完整启动是否需要 Docker daemon、数据库、Redis 和有效模型配置 | 获准后执行 `docker compose config`、构建和健康检查 |
| E-OPEN-002 | SSE 事件在前端是否完整呈现所有工具内容 | 启动 UI/API 后发送测试会话并观察事件 |
| E-OPEN-003 | Planner 更新计划后是否可能重复或跳过步骤 | 使用假模型测试 Flow 状态转换 |
