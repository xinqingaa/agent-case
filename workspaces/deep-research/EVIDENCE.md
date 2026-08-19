# Deep Research 证据台账

本页给 Agent 和校验脚本用，不是学习材料。采集日期 2026-08-19。全部为静态阅读，无 RUN 记录。

## 状态说明

- `[R]`：运行验证
- `[V]`：静态验证
- `[C]`：用户确认
- `[I]`：合理推断
- `[U]`：未知

## 证据记录

| ID | 类型 | 来源 | 位置或命令 | 支持的结论 | 状态 | 采集日期 |
|---|---|---|---|---|---|---|
| E-PROD-001 | source | `front/agent_front/src/App.vue` | `runResearch` POST `/api/v1/research/stream` | 主入口是网页流式提问 | `[V]` | 2026-08-19 |
| E-PROD-002 | source | `app/app_main.py` | `create_app` | HTTP 应用名为 DeepResearch Multi-Agent Assistant | `[V]` | 2026-08-19 |
| E-ARCH-001 | source | `app/mult_agents/graph.py` | `route_after_intent` / 边 | 直答与调研两分支，plan 后两路检索 | `[V]` | 2026-08-19 |
| E-ARCH-002 | source | `front/agent_front/vite.config.ts` | `server.proxy` | 开发时 `/api` `/health` 转到 8000 | `[V]` | 2026-08-19 |
| E-FLOW-001 | source | `app/backend/service/workflow_service.py` | `stream_events` / `_run_sync_with_events` | 图在线程中跑，节点进度变 SSE | `[V]` | 2026-08-19 |
| E-FLOW-002 | source | `app/mult_agents/nodes.py` | `intent_node` `detect_intent` | 规则+LLM 分流 | `[V]` | 2026-08-19 |
| E-FLOW-003 | source | `app/mult_agents/tools.py` | `bocha_web_search_records` | 无 BOCHA 密钥则空列表 | `[V]` | 2026-08-19 |
| E-DATA-001 | source | `app/mult_agents/state.py` | `ResearchState` | 任务级状态字段 | `[V]` | 2026-08-19 |
| E-DATA-002 | source | `app/backend/service/workflow_service.py` | 记忆 inject/persist | 执行前后记忆 | `[V]` | 2026-08-19 |
| E-BOOT-001 | source | `app/mult_agents/config.py` | `from_file` | 缺 DASHSCOPE_API_KEY 抛错 | `[V]` | 2026-08-19 |
| E-BOOT-002 | source | `.env.example` | 变量列表 | 样例未包含 BOCHA_API_KEY | `[V]` | 2026-08-19 |
| E-TEST-001 | source | `app/test/bocha_api_test.py` | 文件存在 | 几乎无自动化测试 | `[V]` | 2026-08-19 |
| E-RISK-001 | source | `app/mult_agents/main.py` | 与 nodes.py 并存的 node 函数 | 重复实现，图引用 nodes.py | `[V]` | 2026-08-19 |
| E-USER-001 | confirmation | 用户 | 未运行过；以源码为主；可公开联网 | 运行结论一律未验证 | `[C]` | 2026-08-19 |
| E-OPEN-001 | unknown | 推断 | LangGraph 并行汇合与 list 覆盖 | 未运行 | `[U]` | 2026-08-19 |

## 运行记录

无。本轮禁止安装、启动和跑测试。

## 用户确认

| ID | 确认内容 | 适用范围 | 日期 |
|---|---|---|---|
| E-USER-001 | 可以读源码；暂不可运行；可访问公开网页和 GitHub；本人未运行过，环境全不全未知 | 本工作区本轮 | 2026-08-19 |

## 推断与待验证项

| ID | 当前推断或问题 | 间接证据 | 验证方式 | 优先级 |
|---|---|---|---|---|
| E-OPEN-001 | plan 后两路检索是否总汇合；无 reducer 的 list 是否覆盖 | `graph.py` 双 add_edge | 获运行许可后打日志或单测 | P1 |
| E-OPEN-002 | 新建会话是否影响后端记忆 | 前端只重置 messages | 同 thread_id 再问一次 | P2 |
