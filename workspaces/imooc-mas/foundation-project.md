# MoocManus 项目与产品

## 阅读目标
理解 MoocManus 为谁提供什么闭环，以及为什么它不是单一聊天接口。

MoocManus 是一个可私有化部署的通用 AI Agent 系统。用户通过 Web UI 创建会话、上传文件并发送任务；后端负责调度 Agent、工具、文件和沙箱，最终以事件流把进度和结果返回页面。

核心产品闭环是：会话输入 → Agent 规划/执行 → 工具或外部 Agent 调用 → 事件与结果持久化 → UI 展示。系统边界包含 Next.js UI、FastAPI API、PostgreSQL、Redis、COS 文件存储、Docker 沙箱和 Nginx 网关。源码依据：`sources/imooc-mas/mooc-manus/README.md`、`api/README.md`。

当前目标是完整理解、运行、复刻最小 Agent 闭环，并完成扩展任务；不把 README 的部署成功描述当作本机运行证据。
