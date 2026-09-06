# 扩展任务：增加一个工具

在最小复刻闭环或项目开发环境中增加一个只读工具，例如“读取指定文本文件摘要”。需要完成工具接口、参数校验、注册位置、Agent 可见描述、成功/失败 ToolResult 和事件展示。

验证重点：工具能被选择并执行；非法参数不会进入外部调用；异常会转换成可观察的失败事件；原有工具和终止条件仍通过测试。项目源码对应 `api/app/domain/services/tools/`、工具结果模型和 Flow/Agent 注册处。

## 本次完成的扩展

实际实现选用无外部副作用的 [TextStatsTool](extension_tool.py)，接入原项目的 BaseTool、tool 装饰器与 ToolResult。工具集名字为 text_stats，模型可调用的函数名为 text_stats_count。两个名字服务于不同层次：前者用于分组和事件内容，后者必须与模型 tool_calls.function.name 一致。

`verify_source.py` 将新工具实例传入原 BaseAgent，假模型先请求调用，再读取结果并回复。测试核对模型实际收到 schema、工具结果确为 11 字符/2 单词，以及最终消息返回；另一个测试验证整数、布尔值、None 和超长文本被拒绝。现有八个原行为测试也全部通过。

## 二开原项目时要改哪里

将类加入授权的开发副本，在 `domain/services/flows/planner_react.py` 构造工具列表的位置增加 `TextStatsTool()`，两个 Agent 都能获得声明，但 Planner 仍采用 tool_choice=none。源码主目录本轮没有修改；实验通过依赖注入验证接入契约。

原 BaseTool 会过滤多余字段，missing 参数则会触发 Python TypeError；这不等于统一的 schema 校验。本扩展在方法内部显式检查文本类型和上限。若希望所有工具统一校验，应在调用分发处加结构化校验与对应回归测试，而不是只修改工具描述。

Runner 的 `_handle_tool_event` 针对若干内置工具名补充截图等 UI 内容。新工具即使能执行，也不自动拥有专属预览组件。先复用普通 ToolEvent 的 function_result；需要专属呈现时再修改 EventMapper 与 UI，验证未识别工具是否有合理回退。

运行命令见 [源码学习](source-study-guide.md)。当前已完成“原 Agent 基类上的工具扩展验证”，尚未完成“完整页面选择并展示新工具”的端到端验证。替换模型、增加 MCP 服务与修改计划循环有不同影响面，应在这个最小扩展通过后逐项实施。
