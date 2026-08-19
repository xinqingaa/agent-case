# Deep Research 测试与调试

## 阅读说明

- 前置知识：核心链路和业务思路
- 阅读目标：知道出问题先看哪一侧，以及源码里几乎没有自动测试
- 预计时间：10 分钟
- 当前把握：已按源码核对 / 还没跑过

## 测试体系

| 层次 | 框架 | 位置 | 覆盖目标 | 运行命令 |
|---|---|---|---|---|
| 手工脚本 | urllib | `app/test/bocha_api_test.py` | 真调用博查 | 未跑；需要 `BOCHA_API_KEY` |
| 单元 / 集成 | 无 | — | — | 无 |

## 核心链路覆盖

| 核心链路 | 正常路径 | 失败路径 | 外部依赖处理 | 主要缺口 |
|---|---|---|---|---|
| 流式研究 | 无测试 | 无测试 | 密钥缺失靠日志和空列表 | 整条 HTTP+图都没有断言 |

## 测试数据与隔离

未见 fixture 或 mock。博查脚本对真实网络发请求。

## 调试地图

先判断问题在哪一侧：界面、接口、数据、模型调用还是外部工具。

| 症状 | 首先观察 | 关键日志、trace 或断点 | 关联模块 | 下一步 |
|---|---|---|---|---|
| 页面立刻失败 | 浏览器网络面板里 `/api/v1/research/stream` 状态码 | Vite 是否把 `/api` 转到 8000 | `vite.config.ts`、`App.vue` | 后端没起或 CORS/代理 |
| 一直「处理中」没有 final | SSE 有没有 `error`/`final` | `WorkflowService` 线程异常 | `workflow_service.py` | 初始化配置失败或图卡住 |
| 走了调研但没有来源 | 后端是否警告未配置 BOCHA | `[bocha_web_search]` 日志 | `tools.py` | 密钥或博查接口 |
| 直答/调研和预期相反 | 问题是否命中关键词 | `[intent] 路由:` 日志 | `nodes.py` `detect_intent` | 词表过宽 |
| 像没记忆 | 三个 ID 是否稳定 | MemoryManager 初始化失败日志 | `main.py` `build_memory_manager` | 存储没起或已降级 |
| 本地库没内容 | Milvus 连接日志 | `rag/core.py` | 没入库或没服务 | `ingest.py` 不在本轮运行范围 |

## 前端参与调试到哪一层

| 现象 | 前端能确认什么 | 需要后端或运行时确认什么 |
|---|---|---|
| 点发送没请求 | 控制台是否抛错、loading 是否卡住 | — |
| 有请求但 4xx/5xx | 响应 body 文本 | FastAPI 异常和配置 |
| 有 SSE 进度无终稿 | 事件类型是否出现 error | 图是否写出 `final` |
| 终稿格式乱 | 是否超出浅 Markdown 子集 | write 节点是否输出了 JSON |

## AI-native 调试

- 进度来自节点名，不是 token：`intent`、`direct_answer`、`plan`、`web_search`、`local_rag`、`deep_dive`、`analyze`、`reflect`、`write`。
- 后端 `logging` 格式含时间、级别、消息；节点有彩色前缀，可用 `NO_COLOR` 关掉。
- `WorkflowService._node_message` 把节点名译成给前端看的中文。
- 不要打开 `.env` 或把密钥打进文档。日志里博查会打印 key 是否存在以及前缀，排查时注意不要复制真实值。

## 日志与可观测性

没有独立 tracing 平台。可观测性 = Python logging + SSE 事件 + 浏览器网络面板。

## 已执行结果

| 命令或场景 | 环境 | 结果 | 失败摘要 |
|---|---|---|---|
| 无 | 未运行 | 未执行 | 本轮不允许启动或跑测试 |

## 测试和调试缺口

没有针对分流、空检索降级、SSE 事件形状的自动化测试。运行行为全部待你另批本机许可后再验证。

## 完成判定与下一步

- 完成判定：能按症状选择先查代理、密钥、意图日志还是记忆降级。
- 下一篇：`12-quality-risks-and-tradeoffs.md`
