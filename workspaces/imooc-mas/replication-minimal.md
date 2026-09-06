# 最小复刻路线：Agent 工具闭环

目标是在不复刻 UI、数据库、Docker 沙箱和所有外部服务的情况下，实现一个可测试闭环：用户问题 → Planner 生成步骤 → ReAct 选择一个工具 → 工具返回观察 → Agent 决定继续或结束 → 输出事件。

最小组件：Python 状态对象、模型适配接口、一个计算或文件工具、工具结果结构、最大迭代次数和事件列表。先使用确定性的假模型和假工具，验证控制流，再替换真实 LLM。

完成标准：至少覆盖一次工具调用、一次继续/终止判断、一次工具失败；测试能断言事件顺序和最终输出。与原项目差异必须明确记录：不实现多租户会话、Redis/PostgreSQL、COS、MCP/A2A、浏览器沙箱和前端 UI。

## 已实现的最小版本

[replica.py](replica.py) 是独立于原项目的可执行教学实现。它把“计划与执行分工”保留下来：Model.plan 提供步骤，Engine 逐步执行，Model.decide 根据观察决定调用工具或结束步骤，Model.revise 修改剩余工作，最后 summarize 形成任务回复。

为隔离控制流与生成质量，DemoModel 是确定性假模型，输入文本经 text_stats 工具返回字数。它不理解任意自然语言，也不模拟真实模型的质量；更换模型适配器后才能评估开放任务。复刻的是执行协议和控制边界，而不是原产品的全部能力。

## 从零搭建顺序

1. 先定义 Observation(success/data/error) 与 Decision(kind/tool/arguments/text)。工具失败要成为能供下一轮推理使用的观察，程序协议错误才结束任务。
2. 建立 Registry，并实现 text_stats。注册与调用使用明确函数，不让模型直接执行任意 Python 或 shell。
3. 完成一步内的循环：decision → tool → observation → decision。无工具的 finish 结束该步；ask 产生 wait 并退出本轮。
4. 在外面增加计划循环。每完成一步便把结果交给 revise；已完成结果不因重规划而消失。
5. 加两个独立预算。max_turns 限一步内模型决策次数，max_steps 限整个任务完成步数，防止模型不断产生新计划。
6. 加事件记录，最后才接输出界面。先断言事件和状态，再考虑动画或真实网络。

```sh
python3 -B workspaces/imooc-mas/replica.py
python3 -B workspaces/imooc-mas/verify_replica.py
```

示例输入 `agent tools return observations` 产生 plan、step_started、tool_calling、tool_called、step_completed、plan_updated、message、done 八个事件；工具返回 4 个按空格分隔的单词。characters 使用 Python 字符长度，不是模型 token 数，也不是中文分词。

## 失败实验与改造边界

配套 8 个测试覆盖正常链路、非法参数、未知工具、失败后改正参数、模型轮数耗尽、计划无限增长、等待人工输入以及空/非法计划。任何预算错误后都不能再发 done。wait 只展示暂停语义，本教学版本没有实现持久化恢复，不能把它当生产续跑功能。

原实现的 max_iterations 边界和失败状态覆盖问题见 [源码学习](source-study-guide.md)。本版本有意不复现这些缺陷：一个事件流只能以 wait、error 或 done 三者之一收尾。要继续提高保真度，应先增加会话存储、事件回放与恢复测试，再替换真实 LLM；原项目现有 UI、COS 和沙箱不是理解这两层循环的前提。
