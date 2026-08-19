# Deep Research 接口与外部集成

## 阅读说明

- 前置知识：架构和核心链路
- 阅读目标：入站合同、出站依赖、密钥边界
- 预计时间：8 分钟
- 当前把握：已按源码核对 / 还没跑过

## 集成地图

| 系统或接口 | 方向 | 协议 | 用途 | 认证 | 失败影响 |
|---|---|---|---|---|---|
| `/api/v1/research/stream` | 入站 | HTTP SSE | 主产品 | 无 | 页面无结果 |
| `/api/v1/research/run` | 入站 | HTTP JSON | 一次性终稿 | 无 | 调用方无结果 |
| `/health` | 入站 | HTTP JSON | 探活 | 无 | 探活失败 |
| DashScope | 出站 | 厂商 SDK | LLM | `DASHSCOPE_API_KEY` | 初始化或节点失败 |
| 博查 `https://api.bocha.cn/v1/web-search` | 出站 | HTTP JSON | 网页检索 | `BOCHA_API_KEY` Bearer | 空证据 |
| Milvus | 出站 | gRPC/HTTP | 向量检索 | 本机连接 | 空本地证据 |
| Postgres / Redis | 出站 | 各自协议 | 记忆与断点 | DSN/URL | 降级 |

## 入站接口

| 入口 | 输入 | 校验与授权 | 输出 | 错误 | 定位 |
|---|---|---|---|---|---|
| `POST /api/v1/research/stream` | ResearchRequest | query 最短 1 字符；无用户鉴权 | `text/event-stream` | 异常变 error 事件 | `research_router.py` |
| `POST /api/v1/research/run` | 同上 | 同上 | ResearchResponse.final | HTTP 错误 | 同上 |
| `GET /health` | 无 | 无 | `{status, service}` | 进程挂了才失败 | `health_router.py` |

SSE 事件 JSON 字段：`type` 为 `status` | `phase` | `route` | `final` | `error`；phase 可带 `node`。

## 出站调用

| 目标 | 调用位置 | 超时 | 重试 | 降级 | 幂等性 |
|---|---|---|---|---|---|
| 博查 web-search | `tools.py` | 30s | 无 | 返回 [] | 每次任务重新搜 |
| 通义 | LangChain agent.invoke | 未见项目级超时封装 | 无 | 抛错到 SSE | 非幂等 |
| Milvus search | `rag/core.py` | 连接失败打日志 | 无 | 空结果 | 读 |

## 数据库、缓存和消息系统

没有消息队列。Checkpointer 和 MemoryManager 共用 Postgres/Redis 思路，具体表结构未在本轮展开。存在 `app/data/memory.db`，内容未读。

## 配置与密钥边界

环境变量覆盖 `config.json`。前端不持有模型密钥。不要把真实 `.env` 贴进工作区。

## 本地替代和测试替身

未见 mock 服务器。缺密钥时网页检索和部分记忆会静默变空或关闭，容易误判为「链路成功」。

## 完成判定与下一步

- 完成判定：能列出三条入站和四个出站，以及缺密钥时的表现。
- 下一篇：`11-testing-and-debugging.md`
