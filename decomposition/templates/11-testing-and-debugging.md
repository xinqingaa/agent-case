# {{PROJECT_NAME}} 测试与调试

## 测试体系

| 层次 | 框架 | 位置 | 覆盖目标 | 运行命令 | 证据 |
|---|---|---|---|---|---|
| 单元 / 集成 / 端到端 | {{FRAMEWORK}} | `{{PATH}}` | {{TARGET}} | `{{COMMAND}}` | `[V/R][E-...]` |

## 核心链路覆盖

| 核心链路 | 正常路径 | 失败路径 | 外部依赖处理 | 主要缺口 |
|---|---|---|---|---|
| {{FLOW}} | {{HAPPY_TEST}} | {{FAILURE_TEST}} | {{MOCK_OR_REAL}} | {{GAP}} |

## 测试数据与隔离

{{FIXTURES_AND_ISOLATION}}

## 调试地图

| 症状 | 首先观察 | 关键日志或断点 | 关联模块 | 下一步 |
|---|---|---|---|---|
| {{SYMPTOM}} | {{FIRST_CHECK}} | {{LOG_OR_BREAKPOINT}} | `{{PATH}}` | {{NEXT}} |

## 日志与可观测性

{{OBSERVABILITY}}

## 已执行结果

| 命令或场景 | 环境 | 结果 | 失败摘要 | 证据 |
|---|---|---|---|---|
| `{{COMMAND}}` | {{ENVIRONMENT}} | {{RESULT}} | {{FAILURE}} | `[R][E-...]` |

## 测试和调试缺口

{{GAPS}}

