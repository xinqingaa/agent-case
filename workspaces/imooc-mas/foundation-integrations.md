# MoocManus 外部接口与集成

| 边界 | 适配接口 | 实现 | 失败影响 |
|---|---|---|---|
| LLM | `domain/external/llm.py` | `infrastructure/external/llm/openai_llm.py` | 无法规划、执行或总结 |
| 数据库 | repositories/UoW | SQLAlchemy + asyncpg/PostgreSQL | 会话和事件无法持久化 |
| 消息队列 | `external/message_queue.py` | Redis stream | 流式任务协作和事件读取受影响 |
| 文件存储 | `external/file_storage.py` | COS | 上传、下载和截图 URL 受影响 |
| 沙箱 | `external/sandbox.py` | Docker sandbox | Shell、浏览器文件同步不可用 |
| 浏览器 | `external/browser.py` | Playwright | 浏览器工具不可用 |
| MCP/A2A | `MCPTool` / `A2ATool` | 配置驱动远程工具/Agent | 对应工具调用失败 |
| 网关 | Nginx | `nginx/conf.d/default.conf` | UI/API 路由不可达 |

外部接口通过领域抽象隔离，Flow 和 Agent 不直接依赖具体数据库或 HTTP 客户端。配置来自 `.env`、`config.yaml` 与应用设置；真实密钥不得写入学习文档。运行时需分别验证健康检查、连接性、鉴权和错误传播。
