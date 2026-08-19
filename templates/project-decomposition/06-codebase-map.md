# {{PROJECT_NAME}} 代码库地图

## 阅读说明

- 前置知识：产品链路和架构
- 阅读目标：知道入口、模块分工和第一次阅读顺序
- 预计时间：`{{TIME}}`
- 验证状态：`[V/I/U]`

## 顶层结构

```text
{{ANNOTATED_TREE}}
```

## 关键目录与模块

| 路径 | 职责 | 主要入口 | 上游 | 下游 | 证据 |
|---|---|---|---|---|---|
| `{{PATH}}` | {{RESPONSIBILITY}} | `{{ENTRY}}` | {{UPSTREAM}} | {{DOWNSTREAM}} | `[V][E-...]` |

## 入口清单

| 入口类型 | 路径与符号 | 触发方式 | 对应产品场景 | 证据 |
|---|---|---|---|---|
| HTTP / UI / CLI / Job / Event | `{{PATH}}::{{SYMBOL}}` | {{TRIGGER}} | {{SCENARIO}} | `[V/R][E-...]` |

## 模块依赖方向

```mermaid
flowchart LR
    Entry[入口] --> Core[核心逻辑]
    Core --> Adapter[数据与外部适配]
```

## 推荐首次阅读顺序

| 顺序 | 路径与符号 | 阅读目标 | 暂时跳过什么 | 完成标准 |
|---|---|---|---|---|
| 1 | `{{PATH}}::{{SYMBOL}}` | {{GOAL}} | {{SKIP}} | {{CHECK}} |

## 不应优先阅读的区域

| 区域 | 原因 | 何时再看 |
|---|---|---|
| `{{PATH}}` | 生成文件 / 工具代码 / 非核心 | {{WHEN}} |

## 命名与代码约定

{{CONVENTIONS}}

## 完成判定与下一步

- 完成判定：{{COMPLETION_CHECK}}
- 下一篇：{{NEXT_DOCUMENT}}
