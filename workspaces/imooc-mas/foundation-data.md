# MoocManus 数据、状态与事件

## 阅读目标
理解会话、计划、步骤、消息、工具结果和领域事件怎样协作。

会话由 `Session` 及其事件列表承载；用户消息、助手消息、计划、步骤、工具调用和完成标记都以领域事件表达。`event.py` 用 Pydantic 的判别联合按 `type` 区分 `PlanEvent`、`TitleEvent`、`StepEvent`、`MessageEvent`、`ToolEvent`、`WaitEvent`、`ErrorEvent` 和 `DoneEvent`。

Planner 产生结构化 `Plan`，其中包含多个 `Step`。Flow 依次取未完成步骤交给 ReAct；ReAct 用 `StepEvent` 表示开始/完成/失败，用 `ToolEvent` 表示调用中/已调用，用 `MessageEvent` 传递结果。Planner 更新计划后继续下一轮，所有步骤完成后 ReAct 汇总为最终消息。

事件先进入任务输出流，再由 `AgentTaskRunner._put_and_add_event` 写入会话仓库。Redis stream 负责任务消息协作，PostgreSQL 的 SessionModel 用 JSONB 保存 events、files 和 memories；文件二进制内容另由 COS 保存。两次写入不是跨 Redis/Postgres 的原子事务。附件会在执行前同步到 sandbox，执行后产生的文件可回传存储。

事件 `type` 使用 Pydantic 判别联合；`DoneEvent` 表示本次流结束，不等同于所有外部副作用都成功。原实现中 cancelled 也会触发 DoneEvent，异常处理仍可把会话设为 COMPLETED。实测 ReAct 甚至会在发出失败步骤事件后把步骤改为 COMPLETED，所以这些状态不能单独作为业务成功依据。具体实验见 [源码学习](source-study-guide.md)。
