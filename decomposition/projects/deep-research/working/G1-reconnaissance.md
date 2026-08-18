# G1 项目侦察记录

日期：2026-08-18  
授权：L1 完成，已进入 L3  
状态：静态侦察已完成

## 本阶段范围

已查看：目录轮廓、现有说明、清单/配置、入口、FastAPI、LangGraph、节点、检索、记忆、前端和测试的核心实现。

未查看：真实 `.env`、`memory.db` 内容、生成目录；未逐文件阅读不在核心调用链的前端模板和工具 stub。

未执行：安装、构建、启动、测试、数据库连接和外部 API 调用。

## 静态项目轮廓

```text
code/deep_research/
├── main.py                         # 文件存在，职责待源码确认
├── app/
│   ├── app_main.py                # 文件存在，职责待源码确认
│   ├── backend/{config,router,schemas,service}/
│   ├── mult_agents/{memory,rag}/
│   ├── data/
│   └── test/
├── front/agent_front/
│   ├── src/{assets,components}/
│   ├── package.json
│   └── vite.config.ts
├── output/
├── pyproject.toml
├── requirements.txt
├── config.json
└── .env.example
```

目录只证明这些边界存在，不证明目录名称准确反映当前职责。[V][E-ARCH-003]

## 可确认事实

1. Python 版本约束是 `>=3.10`。[V][E-BOOT-001]
2. 项目声明 LangGraph、FastAPI、LangChain、Milvus、PostgreSQL、Redis 和 DashScope 依赖。[V][E-ARCH-001]
3. 前端使用 Vue 3、TypeScript 和 Vite，开发端口静态配置为 5173。[V][E-ARCH-004][E-BOOT-004]
4. 前端代理 `/api` 和 `/health` 到本机 8000 端口。[V][E-BOOT-004]
5. 配置模板包含租户、用户、线程、迭代、记忆和多种存储后端设置。[V][E-BOOT-002]
6. 仓库存在真实 `.env`，但本次未读取。

## 现有文档提供的候选产品模型

现有文档把项目描述为面向企业深度研究的多 Agent 助手，候选主链路为：意图识别 → 任务规划 → Web/本地检索 → 证据审计 → 分析 → 必要时补搜 → 生成带引用报告。[I][E-PROD-001][E-PROD-002]

这条链路适合作为 L3 的第一条验证主线，但当前不能标记为实现事实。

## 优先审计分歧

1. 已确认只使用 POST SSE，旧 WebSocket 表述错误。
2. 已确认 Neo4j/MySQL/Flask/MCP 不在当前实现调用链。
3. 已确认 Bocha 是真实 Web 检索实现，`.env.example` 漏配置。
4. `requirements.txt` 与 `pyproject.toml` 的权威性仍需 L4 构建矩阵。
5. 文档中的性能、质量和准确率指标无评测证据，不可使用。
6. 发现密钥、运行时数据库、认证和租户隔离风险，已写入证据台账。

## L2/L3 建议阅读顺序

1. 两个入口文件，确认 CLI/Web 边界和初始化流程。
2. 配置加载模块，确定环境变量优先级和依赖矩阵。
3. 图构建、状态定义和节点注册，确认实际 Agent 与边。
4. 后端路由/service 和前端请求消费，确认 HTTP/SSE 产品链路。
5. RAG、记忆和工具边界，确认外部依赖与降级路径。
6. 测试源码，确认已有行为约束和明显缺口。

## 授权升级记录

根据用户最初“除非我同意让你阅读”和 2026-08-18 的明确同意，现已记录 L3：允许在 `code/deep_research` 内全局搜索并选择性读取实现与测试源码，继续排除 `.env`、缓存、生成文件和依赖目录。

运行、安装和外部服务仍保持禁止，除非后续单独授予 L4/L5。
