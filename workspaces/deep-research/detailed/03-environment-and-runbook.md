# Deep Research 环境与运行手册

## 阅读说明

- 前置知识：项目概览
- 阅读目标：知道源码声称怎么启动，以及本轮为什么不能声称已经跑通
- 预计时间：8 分钟
- 当前把握：已按源码核对 / 还没跑过
- 破坏性说明：未执行任何安装、启动、迁移或外部调用

## 已核实环境

| 项目 | 版本或值 | 必需 | 验证命令 | 结果 |
|---|---|---|---|---|
| 操作系统 | 未知 | 是 | 未执行 | 还没跑过 |
| Python | 声明 `>=3.10` | 是 | 未执行 | 仅 `pyproject.toml` |
| Node | 声明 `^20.19 \|\| >=22.12` | 前端需要 | 未执行 | 仅 `package.json` |

## 外部依赖

| 服务 | 用途 | 本地或远程 | 是否必需 | 健康检查 | 副作用风险 |
|---|---|---|---|---|---|
| DashScope 通义 | 各节点 LLM | 远程 | 跑起来必需 | 无 | 会消耗额度 |
| 博查 Web Search | 网页检索 | 远程 `api.bocha.cn` | 调研要有网搜才需要 | 无 | 会消耗额度；未配置则空搜 |
| Postgres | 记忆 / checkpointer | 本地默认 DSN | 配置默认指向它，失败可降级 | 未验证 | 不在本轮迁移 |
| Redis | 可选 checkpointer | 本地 6379 | 视后端选择 | 未验证 | 无 |
| Milvus | RAG 与可选记忆向量 | 本地 19530 | `ENABLE_MILVUS` 默认 true | 未验证 | 无 |

## 环境变量

只记录变量名和示例格式，不记录真实密钥。

| 名称 | 用途 | 必需 | 示例格式 | 定位 |
|---|---|---|---|---|
| `DASHSCOPE_API_KEY` | 通义 | 运行必需 | 非空字符串 | `.env.example` / `config.json` `api_key` |
| `MODEL` | 模型名 | 否，有默认 | `qwen-plus` | `.env.example` |
| `BOCHA_API_KEY` | 网页检索 | 想搜网时必需 | 非空字符串 | **未写入 .env.example**，只在 `tools.py` |
| `POSTGRES_DSN` / `REDIS_URL` / `MILVUS_HOST` | 存储 | 视开关 | URL / 主机名 | `.env.example` |

当前仓库里的 `config.json` 中 `api_key`、`redis_url`、`postgres_dsn`、`milvus_host` 均为空字符串。

## 从零启动

以下全部是源码候选，**未执行**。

### 1. 准备

复制 `.env.example` 为 `.env`，填通义密钥；若要网页检索再自行增加 `BOCHA_API_KEY`。不要把填好的 `.env` 写进文档。

### 2. 安装依赖

Python：`requirements.txt` 或 `pyproject.toml` 所列。前端：`front/agent_front` 下 `npm install`。本轮未装。

### 3. 启动依赖和应用

需要本机 Postgres / Redis / Milvus 是否齐全未知。后端：`app/app_main.py` 使用 uvicorn，默认端口 8000。前端：`npm run dev`，端口 5173，代理 `/api` 到 8000。

### 4. 判断成功

| 检查 | 命令或操作 | 预期信号 | 实际结果 |
|---|---|---|---|
| 健康检查 | `GET /health` | `{ status: ok, service: deepresearch-backend }` | 未执行 |
| 打开聊天页 | 浏览器 5173 | 看到 DeepResearch 工作台 | 未执行 |

## 测试、构建和检查

| 目的 | 命令 | 结果 | 失败项 |
|---|---|---|---|
| 测试 | 无项目级测试命令 | 未执行 | 几乎无测试 |

## 常见故障

| 症状 | 原因 | 诊断步骤 | 恢复方式 | 已核实 |
|---|---|---|---|---|
| 启动即报缺 api_key | `AppConfig.from_file` | 看配置是否空 | 设环境变量，不要把密钥贴进仓库 | 已按源码核对 |
| 能答但不能搜网 | 未设 BOCHA | 看 `[bocha_web_search] 未配置` 日志 | 配置密钥或接受空检索 | 已按源码核对 |

## 尚未验证

整条安装与启动。用户确认未运行过，环境全不全未知。

## 完成判定与下一步

- 完成判定：知道缺哪些密钥、哪些基础设施，且不把候选命令当成已验证。
- 下一篇：`04-stack-and-dependencies.md`
