# Empty Drill 证据台账

本页给 Agent 和校验脚本用，不是学习材料。

## 状态说明

- `[R]`：运行验证
- `[V]`：静态验证
- `[C]`：用户确认
- `[I]`：合理推断
- `[U]`：未知

## 证据记录

| ID | 类型 | 来源 | 位置或命令 | 支持的结论 | 状态 | 采集日期 |
|---|---|---|---|---|---|---|
| E-BOOT-001 | command | terminal | `{{COMMAND}}` | {{CLAIM}} | `[R]` | {{DATE}} |
| E-ARCH-001 | source | `{{PATH}}` | `{{SYMBOL_OR_LINES}}` | {{CLAIM}} | `[V]` | {{DATE}} |

## 运行记录

### RUN-001：{{RUN_NAME}}

- 工作目录：`{{WORKDIR}}`
- 前置条件：{{PREREQUISITES}}
- 命令：`{{COMMAND}}`
- 退出状态：{{EXIT_STATUS}}
- 成功或失败信号：{{SIGNAL}}
- 相关输出摘要：{{OUTPUT_SUMMARY}}
- 产生的副作用：{{SIDE_EFFECTS}}

## 用户确认

| ID | 确认内容 | 适用范围 | 日期 |
|---|---|---|---|
| E-USER-001 | {{CONFIRMATION}} | {{SCOPE}} | {{DATE}} |

## 推断与待验证项

| ID | 当前推断或问题 | 间接证据 | 验证方式 | 优先级 |
|---|---|---|---|---|
| E-OPEN-001 | {{QUESTION}} | `E-...` | {{VERIFICATION}} | P0/P1/P2 |
