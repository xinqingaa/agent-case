# 文档中心

这里保存 Codebase Learning Decomposer 当前有效的项目文档。历史项目拆解已移入 `archive/`，不得与当前规范混用。

## 建议阅读顺序

1. [愿景与范围](vision-and-scope.md)
2. [仓库架构](architecture.md)
3. [拆解工作流](specifications/decomposition-workflow.md)
4. [授权模型](specifications/authorization.md)
5. [证据模型](specifications/evidence-model.md)
6. [详细文档契约](specifications/document-contract.md)
7. [验收规范](specifications/acceptance.md)
8. [建设路线图](roadmap.md)

## 文档层级

| 层级 | 目录 | 约束力 |
|---|---|---|
| 项目入口 | 根 `README.md`、`AGENTS.md` | 定义仓库用途和 Agent 底线 |
| 规范 | `docs/specifications/` | 当前拆解行为的事实源 |
| 指南 | `docs/guides/` | 解释如何应用规范 |
| 决策 | `docs/decisions/` | 记录重要设计选择及其后果 |
| 模板 | `templates/project-decomposition/` | 规范的可填写实现 |
| 历史 | `archive/` | 无规范效力，仅供参考 |

发生冲突时，授权和安全约束优先于工作流；规范优先于指南；活跃规范优先于归档资料。
