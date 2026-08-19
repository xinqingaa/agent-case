# Codebase Learning Decomposer

本仓库用于把现有代码仓库转化为可验证、可学习、可复习的项目学习资料。它当前处于实验阶段，优先建设拆解规范、授权边界、证据体系、文档契约和可重复执行工具；真实项目拆解必须逐项目授权。

## 核心原则

1. 先理解用户、产品场景和端到端协作，再解释架构；源码是核实材料，不是读者课文。
2. 重要结论必须能追溯到源码、配置、测试、运行结果或用户确认。
3. Agent 必须区分已跑过、已核对源码、用户确认、推断和未知；学习文档用白话写这些把握，不把标记系统教给读者。
4. `sources/` 是只读输入；拆解产物只写入 `workspaces/`。
5. 未授权时不读取源码、不安装依赖、不启动服务、不访问数据或外部系统。
6. 详细版是事实源；简洁版只能从已验收的详细版派生。

## 仓库结构

| 路径 | 作用 | 状态 |
|---|---|---|
| [`docs/`](docs/README.md) | 当前有效的项目规范、架构、指南和路线图 | 事实源 |
| [`.agents/skills/`](.agents/skills/project-learning-decomposer/SKILL.md) | 项目拆解 Skill 正文 | 执行层 |
| [`.cursor/skills/`](.cursor/skills/project-learning-decomposer) | Cursor 发现路径，软链到正文 | 发现层 |
| [`.claude/skills/`](.claude/skills/project-learning-decomposer) | Claude Code 发现路径，软链到正文 | 发现层 |
| [`templates/`](templates/project-decomposition/project.yaml) | 新拆解工作区的文档模板 | 模板层 |
| [`schemas/`](schemas/project.schema.json) | 项目元数据的机器可读约束 | 约束层 |
| [`scripts/`](scripts/) | 初始化、工作区校验和仓库检查 | 工具层 |
| [`tests/`](tests/) | 工具和规则的测试场景 | 验证层 |
| [`sources/`](sources/README.md) | 等待授权后分析的源码输入 | 默认只读 |
| [`workspaces/`](workspaces/README.md) | 新体系生成的项目拆解工作区 | 活跃产物 |
| [`archive/`](archive/README.md) | 旧拆解、旧图片和冻结试点 | 仅供参考 |

## 当前阶段

当前目标是 0.2 已冻结，空项目 G0 已完成。真实项目拆解必须逐项目授权。历史上的 `deep-research` 试点已冻结到 `archive/pilots/`，不能作为新体系已经验收的证明。

## 快速开始

初始化一个工作区不会读取源项目：

```shell
./scripts/init-project.sh <project-id> <project-name> <source-path>
./scripts/validate-project.sh workspaces/<project-id> --structure-only
```

开始任何源码分析前，先阅读：

1. [`AGENTS.md`](AGENTS.md)
2. [`docs/specifications/authorization.md`](docs/specifications/authorization.md)
3. [`docs/specifications/decomposition-workflow.md`](docs/specifications/decomposition-workflow.md)
4. 目标工作区中的 `project.yaml`

项目建设路线见 [`docs/roadmap.md`](docs/roadmap.md)，参与修改见 [`CONTRIBUTING.md`](CONTRIBUTING.md)。
