# MoocManus 数据、状态与事件

## 阅读目标
理解会话、计划、步骤、消息、工具结果和领域事件怎样协作。

会话由 `Session` 及其事件列表承载；用户消息、助手消息、计划、步骤、工具调用和完成标记都以领域事件表达。`event.py` 用 Pydantic 的判别联合按 `type` 区分 `PlanEvent`、`TitleEvent`、`StepEvent`、`MessageEvent`、`ToolEvent`、`WaitEvent`、`ErrorEvent` 和 `DoneEvent`。

Planner 产生结构化 `Plan`，其中包含多个 `Step`。Flow 依次取未完成步骤交给 ReAct；ReAct 用 `StepEvent` 表示开始/完成/失败，用 `ToolEvent` 表示调用中/已调用，用 `MessageEvent` 传递结果。Planner 更新计划后继续下一轮，所有步骤完成后 ReAct 汇总为最终消息。

事件先进入任务输出流，再由 `AgentTaskRunner._put_and_add_event` 写入会话仓库。Redis stream 负责任务消息协作，PostgreSQL repository 保存会话、文件和事件相关关系数据；文件对象另由 COS 保存。附件会在执行前同步到 sandbox，执行后产生的文件可回传存储。

关键不变量：事件 `type` 必须能映射到唯一 Pydantic 子类型；计划完成前不能发出最终完成事件；工具异常应转为错误或失败步骤；`DoneEvent` 表示本次流结束，不等同于所有外部副作用都成功。
