# {{PROJECT_NAME}} 接口与外部集成

## 集成地图

| 系统或接口 | 方向 | 协议 | 用途 | 认证 | 失败影响 | 证据 |
|---|---|---|---|---|---|---|
| {{INTEGRATION}} | 入站 / 出站 | {{PROTOCOL}} | {{PURPOSE}} | {{AUTH}} | {{FAILURE_IMPACT}} | `[V/R][E-...]` |

## 入站接口

| 入口 | 输入 | 校验与授权 | 输出 | 错误 | 实现位置 |
|---|---|---|---|---|---|
| `{{INTERFACE}}` | {{INPUT}} | {{VALIDATION}} | {{OUTPUT}} | {{ERRORS}} | `{{PATH}}::{{SYMBOL}}` |

## 出站调用

| 目标 | 调用位置 | 超时 | 重试 | 降级 | 幂等性 | 证据 |
|---|---|---|---|---|---|---|
| {{TARGET}} | `{{PATH}}::{{SYMBOL}}` | {{TIMEOUT}} | {{RETRY}} | {{FALLBACK}} | {{IDEMPOTENCY}} | `[V/I][E-...]` |

## 数据库、缓存和消息系统

{{INFRASTRUCTURE_INTEGRATIONS}}

## 配置与密钥边界

{{CONFIG_AND_SECRETS}}

## 本地替代和测试替身

{{LOCAL_SUBSTITUTES}}

