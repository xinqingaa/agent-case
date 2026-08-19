# Deep Research 拆解草案

授权：可读源码；可查公开网页和 GitHub；不可安装/启动/跑测试；不调用项目的通义/博查接口；不看 Git 历史；不改源码。

侦察：`working/recon.md`  
学习文档：`detailed/`，从 `00-learning-guide.md` 进入。

## 当前结论（静态）

主线是网页提问 → FastAPI SSE → LangGraph：简单问题直答，复杂问题规划后双源检索、裁判、可能补搜、写报告。前端不跑 Agent。

未运行。`config.json` 里通义密钥为空；博查密钥未出现在 `.env.example`。

## 仍请你确认方向

1. 学习主线是否就按「页面提问 → 意图分流 → 直答或调研报告」？
2. CLI 是否只要一笔带过？
3. 记忆 / Postgres / Milvus 默认只写在链路上的位置，不展开运维，是否够？
