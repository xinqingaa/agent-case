# {{PROJECT_NAME}} 产品链路

## 阅读说明

- 前置知识：项目概览
- 阅读目标：从用户行为理解系统能力和代码分析主线
- 预计时间：`{{TIME}}`

## 用户与目标

| 用户或角色 | 目标 | 触发条件 | 期望结果 | 证据 |
|---|---|---|---|---|
| {{ACTOR}} | {{GOAL}} | {{TRIGGER}} | {{RESULT}} | `[V/C][E-...]` |

## 产品能力边界

### 系统负责

{{IN_SCOPE}}

### 系统不负责

{{OUT_OF_SCOPE}}

## 主产品链路

```mermaid
journey
    title {{JOURNEY_NAME}}
    section {{STAGE}}
      {{USER_ACTION}}: 5: 用户
      {{SYSTEM_FEEDBACK}}: 4: 系统
```

## 链路步骤

| 步骤 | 用户行为 | 系统行为 | 结果 | 对应核心链路 | 证据 |
|---|---|---|---|---|---|
| 1 | {{ACTION}} | {{BEHAVIOR}} | {{RESULT}} | `08-core-flow-...` | `[V][E-...]` |

## 异常和退出路径

| 场景 | 用户看到什么 | 系统如何处理 | 当前证据状态 |
|---|---|---|---|
| {{FAILURE}} | {{VISIBLE_RESULT}} | {{HANDLING}} | `[R/V/I/U]` |

## 从产品链路到代码

{{BRIDGE_TO_CODE}}

