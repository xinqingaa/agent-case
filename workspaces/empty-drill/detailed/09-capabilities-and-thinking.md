# Empty Drill 业务能力与思路

## 阅读说明

- 前置知识：产品链路和架构
- 阅读目标：理解这个项目能办成什么、关键如何判断、该用什么思路理解它
- 预计时间：`{{TIME}}`
- 当前把握：`尚未核对 / 已按源码核对 / 已实际跑过 / 仍有未知`

## 一句话

{{ONE_SENTENCE}}

## 能力地图

| 能力 | 为谁解决什么 | 系统负责到哪 | 不负责什么 | 前端参与到哪 |
|---|---|---|---|---|
| {{CAPABILITY}} | {{USER_VALUE}} | {{SYSTEM_BOUNDARY}} | {{OUT_OF_SCOPE}} | {{FRONTEND_ROLE}} |

## 能力边界

### 能做

{{CAN_DO}}

### 故意不做或交给外部

{{WILL_NOT_DO}}

## 关键业务判断

| 场景 | 依据什么判断 | 系统怎么裁决 | 用户看到什么 | 判断错会怎样 |
|---|---|---|---|---|
| {{SCENE}} | {{CRITERIA}} | {{DECISION}} | {{USER_RESULT}} | {{IF_WRONG}} |

## 默认思路

处理这类问题时，系统默认怎么走。这是思路，不是函数调用图。

```mermaid
flowchart TD
    Trigger[{{TRIGGER}}] --> Judge[{{JUDGEMENT}}]
    Judge --> Act[{{ACTION}}]
    Act --> Result[{{RESULT}}]
```

{{THINKING_MODEL}}

## 前端参与边界

| 环节 | 前端做什么 | 决策在哪一侧 | 前端不该假定什么 |
|---|---|---|---|
| {{STAGE}} | {{FRONTEND_WORK}} | {{DECISION_SIDE}} | {{DO_NOT_ASSUME}} |

## 常见想错的方式

| 容易怎么理解 | 实际是怎样 | 为什么会错 |
|---|---|---|
| {{MISREAD}} | {{ACTUAL}} | {{WHY}} |

## 和相邻文档的关系

- 产品定位见 `01-project-and-product.md`
- 用户步骤见 `02-product-journeys.md`
- 概念和数据见 `07-domain-and-data.md`
- 一条路径怎么跑见 `08-core-flow-main.md`

## 尚未确定

{{UNKNOWNS}}

## 完成判定与下一步

- 完成判定：{{COMPLETION_CHECK}}
- 下一篇：{{NEXT_DOCUMENT}}
