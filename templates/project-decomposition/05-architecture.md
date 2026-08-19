# {{PROJECT_NAME}} 架构

## 阅读说明

- 前置知识：产品链路、技术栈
- 阅读目标：理解系统边界、稳定模块和运行时协作
- 预计时间：`{{TIME}}`
- 验证状态：`[R/V/I/U]`

## 架构结论摘要

{{ARCHITECTURE_SUMMARY}}

## 系统上下文

```mermaid
flowchart LR
    User[{{USER}}] --> System[{{SYSTEM}}]
    System --> External[{{EXTERNAL_SYSTEM}}]
```

| 节点 | 职责 | 边界 | 证据 |
|---|---|---|---|
| {{NODE}} | {{RESPONSIBILITY}} | {{BOUNDARY}} | `[V/I][E-...]` |

## 模块关系

```mermaid
flowchart TB
    Entry[入口层] --> Application[应用逻辑]
    Application --> Data[数据与集成]
```

## 运行时视图

{{RUNTIME_VIEW}}

## 数据与控制流

{{DATA_AND_CONTROL_FLOW}}

## 部署视图

{{DEPLOYMENT_VIEW}}

## 架构模式判断

| 候选模式 | 支持证据 | 反向证据 | 结论 |
|---|---|---|---|
| {{PATTERN}} | `[E-...]` | `[E-...]` | `[V/I/U] {{CONCLUSION}}` |

## 关键设计决策

| 决策 | 解决的问题 | 当前收益 | 代价 | 证据状态 |
|---|---|---|---|---|
| {{DECISION}} | {{PROBLEM}} | {{BENEFIT}} | {{COST}} | `[V/I/C]` |

## 不确定项

{{UNKNOWNS}}

## 完成判定与下一步

- 完成判定：{{COMPLETION_CHECK}}
- 下一篇：{{NEXT_DOCUMENT}}
