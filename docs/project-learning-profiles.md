# 项目学习目标档案

版本：0.3.0

每个项目在开始拆解前先声明学习目标。目标档案决定生成哪些平铺文档和验收哪些学习结果；它不降低事实、证据、授权和安全要求。

## 档案字段

| 字段 | `required` | `optional` | `excluded` |
|---|---|---|---|
| `source_study` | 必须形成源码学习路线 | 可以形成 | 不生成 |
| `runtime_onboarding` | 必须实际运行或记录阻断原因 | 仅写候选运行手册 | 不做运行任务 |
| `minimal_replication` | 必须实现最小价值闭环 | 可以提供练习 | 不做复刻 |
| `extension_development` | 必须完成至少一个扩展任务 | 提供建议任务 | 不做二次开发 |

`cross_project_comparison` 在拥有至少两个完成事实底座的项目后再启用。比较文档不得反过来成为单个项目的事实源。

## 当前三个项目的目标

### deep-research

```yaml
source_study: required
runtime_onboarding: optional
minimal_replication: excluded
extension_development: excluded
cross_project_comparison: planned
```

重点是读懂产品链路、LangGraph 编排、检索与记忆边界、SSE 事件和失败降级。验收重点是能解释一条端到端链路并完成定位练习，不要求复刻或二开。

### cloud_agent

```yaml
source_study: required
runtime_onboarding: required
minimal_replication: excluded
extension_development: excluded
cross_project_comparison: planned
```

重点是源码结构和实际运行方式。验收必须包含真实启动或明确的授权/环境阻断记录，但不要求从零重建或修改其核心实现。

### imooc-mas

```yaml
source_study: required
runtime_onboarding: required
minimal_replication: required
extension_development: required
cross_project_comparison: planned
```

这是高级试点。除事实底座和源码学习外，还必须提炼最小可复刻闭环，并完成至少一个工具、路由、状态、模型或工作流扩展任务。扩展任务需要说明影响面、验证方式和与原实现的差异。

## 完成判定

项目只有在其档案声明的目标全部通过验收后，才能标记为 `accepted`。被排除的路线不构成未完成项；未声明的路线也不能作为完成承诺。
