# Empty Drill 接口与外部集成

## 阅读说明

- 前置知识：架构和核心链路
- 阅读目标：理解入站、出站、数据和密钥边界
- 预计时间：`{{TIME}}`
- 当前把握：`尚未核对 / 已按源码核对 / 已实际跑过 / 仍有未知`

## 集成地图

| 系统或接口 | 方向 | 协议 | 用途 | 认证 | 失败影响 |
|---|---|---|---|---|---|
| {{INTEGRATION}} | 入站 / 出站 | {{PROTOCOL}} | {{PURPOSE}} | {{AUTH}} | {{FAILURE_IMPACT}} |

## 入站接口

| 入口 | 输入 | 校验与授权 | 输出 | 错误 | 定位 |
|---|---|---|---|---|---|
| `{{INTERFACE}}` | {{INPUT}} | {{VALIDATION}} | {{OUTPUT}} | {{ERRORS}} | `{{PATH}}` |

## 出站调用

| 目标 | 调用位置 | 超时 | 重试 | 降级 | 幂等性 |
|---|---|---|---|---|---|
| {{TARGET}} | `{{PATH}}` | {{TIMEOUT}} | {{RETRY}} | {{FALLBACK}} | {{IDEMPOTENCY}} |

## 数据库、缓存和消息系统

{{INFRASTRUCTURE_INTEGRATIONS}}

## 配置与密钥边界

{{CONFIG_AND_SECRETS}}

## 本地替代和测试替身

{{LOCAL_SUBSTITUTES}}

## 完成判定与下一步

- 完成判定：{{COMPLETION_CHECK}}
- 下一篇：{{NEXT_DOCUMENT}}
