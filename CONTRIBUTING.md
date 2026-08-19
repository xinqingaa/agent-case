# 参与建设

当前仓库处于实验阶段。修改应优先提升规则的可执行性、证据质量和学习效果，不以增加文档数量为目标。

## 修改入口

- 改拆解规则：`docs/specifications/`
- 改使用说明：`docs/guides/`
- 改模板：`templates/project-decomposition/`
- 改 Agent 工作流：`.agents/skills/project-learning-decomposer/`（其他 Agent 发现目录必须是指向此处的软链）
- 改机械检查：`scripts/` 和 `tests/`

## 变更要求

1. 先说明要解决的普遍问题，避免把单个项目特例写成全局规则。
2. 规范变化必须同步检查模板、Skill、Schema、校验器和路线图。
3. 影响授权、安全、证据或验收语义的决定应新增或更新 ADR。
4. 不使用真实项目源码测试通用模板；优先使用 `tests/fixtures/`。
5. 不在规范建设任务中顺带修复或重构 `sources/` 中的项目。

## 验证

```shell
./tests/test-scripts.sh
./scripts/check-repository.sh
```

提交前确认活跃文档没有引用已废弃的 `decomposition/` 或 `code/` 路径。
