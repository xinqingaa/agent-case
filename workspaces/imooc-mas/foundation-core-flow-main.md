# 核心链路：{{FLOW_NAME}}

## 阅读说明

- 产品价值：{{PRODUCT_VALUE}}
- 前置知识：{{PREREQUISITES}}
- 预计时间：{{TIME}}
- 当前把握：`尚未核对 / 已按源码核对 / 已实际跑过 / 仍有未知`

## 一句话说明

{{ONE_SENTENCE}}

## 触发与最终结果

| 项目 | 内容 |
|---|---|
| 参与者 | {{ACTOR}} |
| 触发方式 | {{TRIGGER}} |
| 输入 | {{INPUT}} |
| 输出 | {{OUTPUT}} |

## 端到端顺序图

```mermaid
sequenceDiagram
    actor User as {{ACTOR}}
    participant Entry as {{ENTRY}}
    participant Service as {{SERVICE}}
    participant Store as {{STORE}}
    User->>Entry: {{REQUEST}}
    Entry->>Service: {{CALL}}
    Service->>Store: {{DATA_OPERATION}}
    Store-->>Service: {{DATA_RESULT}}
    Service-->>Entry: {{SERVICE_RESULT}}
    Entry-->>User: {{RESPONSE}}
```

## 节点追踪

| 序号 | 阶段 | 定位 | 输入 | 决策或处理 | 输出与副作用 |
|---|---|---|---|---|---|
| 1 | {{STAGE}} | `{{PATH}}` | {{INPUT}} | {{LOGIC}} | {{OUTPUT}} |

## 状态变化与不变量

| 状态 | 变化前 | 触发条件 | 变化后 | 不变量 |
|---|---|---|---|---|
| {{STATE}} | {{BEFORE}} | {{CONDITION}} | {{AFTER}} | {{INVARIANT}} |

## 失败、重试和降级

| 故障点 | 触发条件 | 传播方式 | 用户结果 | 重试或降级 | 覆盖测试 |
|---|---|---|---|---|---|
| {{FAILURE_POINT}} | {{CONDITION}} | {{PROPAGATION}} | {{USER_RESULT}} | {{RECOVERY}} | {{TEST}} |

## 关键节点顺序

跟上这条链路时按这个顺序看模块，不是精读函数。

1. `{{PATH}}`：{{WHY_FIRST}}
2. `{{PATH}}`：{{WHY_NEXT}}

## 如何验证这条链路

```shell
{{VERIFICATION_COMMAND}}
```

预期结果：{{EXPECTED_RESULT}}

## 尚未回答的问题

{{UNKNOWNS}}

## 完成判定与下一步

- 完成判定：{{COMPLETION_CHECK}}
- 下一篇：{{NEXT_DOCUMENT}}
