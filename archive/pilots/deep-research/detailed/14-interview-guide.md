# DeepResearch 面试表达指南

## 使用约束

只使用本详细版中的 `[V]`、未来补充的 `[R]` 或用户明确确认的 `[C]`。当前没有证据证明你本人设计、开发或优化了这些实现，因此应说“项目实现了/源码显示”，不要说“我设计/我提升”，除非用户另行确认个人贡献。

## 两分钟项目介绍

DeepResearch 是一个基于 LangGraph 的研究助手，提供 Vue Web、FastAPI API 和 CLI 三种使用面。它先通过规则加 LLM 做意图分流：简单问题进入直接回答，复杂问题由 Planner 拆成搜索计划，再进入 Bocha Web 和 Milvus 本地知识库两路检索。检索结果由 Python 分配受控 source ID，Evidence Judge 合并审计，Analyst 判断证据缺口；必要时 Reflect 生成补搜计划，达到条件后 Writer 生成 Markdown 报告，并删除不在合法集合中的引用编号。

它更准确地是固定图驱动的多角色 LLM pipeline：八个 Agent 的 tools 都为空，检索由节点函数直接调用。Web 使用 POST 响应中的 SSE 阶段事件，不是 WebSocket，也不是 token 级正文流。项目还实现了 checkpointer 和短期/长期记忆的多后端降级，但当前缺少自动化测试、认证和完整租户隔离，运行可复现性也尚待验证。[V][E-ARCH-006][E-ARCH-007][E-ARCH-008][E-ARCH-009][E-ARCH-010][E-FLOW-001][E-FLOW-002][E-FLOW-003][E-FLOW-004][E-FLOW-005][E-FLOW-006][E-FLOW-007][E-FLOW-008][E-RISK-001][E-RISK-002][E-RISK-003]

## 五分钟讲解结构

1. **问题与边界**：把复杂研究拆成受控阶段，并尝试保留来源；当前是通用研究工作台，不应直接称生产级企业系统。
2. **入口与架构**：Vue/FastAPI/CLI 共享 LangGraph；外部依赖是 Qwen、Bocha、Milvus、PostgreSQL/Redis/SQLite。
3. **核心链路**：Intent → Plan → Web+Local → Judge → Analyze → Reflect/Write。
4. **关键机制**：source ID 白名单、JSON fallback、迭代上限、节点级 SSE、执行前后记忆。
5. **取舍**：固定图比自主 ReAct 更可控，但节点多、延迟高；多后端降级提升可用性，却可能改变持久化和隔离语义。
6. **风险与改进**：先解决密钥、认证、统一上下文键和测试，再谈指标和扩展工具。

## 核心链路讲法

| 链路 | 用户价值 | 技术实现 | 难点 | 取舍 | 证据 |
|---|---|---|---|---|---|
| 意图分流 | 简单问题不走完整研究 | 规则初判 + LLM JSON 复核 | LLM 可覆盖规则 | Direct 仍有两次模型调用 | E-FLOW-005 |
| 双源研究 | 结合公开与本地信息 | LangGraph 分支 + Bocha/Milvus | 状态合并、空分支 | 固定调用更可控但不自主 | E-FLOW-004、E-FLOW-006、E-FLOW-008 |
| 补搜闭环 | 缺证据时继续查询 | Analyst flag + Reflect plan + iteration | 上限和证据累积 | 达上限仍强制写作 | E-FLOW-004、E-FLOW-007 |
| 引用约束 | 减少不存在的引用编号 | source ID 白名单 + 正则清理 | 语义支持仍未验证 | 轻量但不是事实校验 | E-FLOW-006、E-FLOW-007 |
| 会话记忆 | 跨轮次带入用户上下文 | 执行前注入，执行后持久化 | 多后端隔离一致性 | 降级提高存活但弱化语义 | E-DATA-002、E-RISK-003 |

## 高频问题

### 1. 为什么用 LangGraph，不用一个 ReAct Agent？

这类任务有稳定阶段和明确的回路：规划必须先于检索，证据审计先于分析，只有证据不足才补搜。LangGraph 把这些控制流写成显式边，便于限制迭代和观察阶段。当前实现也证明 Agent 没有绑定工具，外部检索由节点直接调用，所以选择重点是确定性编排，不是让模型自由选择下一步。[V][E-FLOW-004][E-ARCH-009]

追问：固定图如何扩展新来源？回答时说明要新增适配器、状态字段/合并策略、节点或现有检索节点分支，以及测试和 SSE 文案。

### 2. 有几个 Agent？为什么文档有七、八、九种说法？

当前源码构造八个 Agent 对象：Intent、Planner、Web Scout、Local Scout、Evidence Judge、Analyst、Direct Responder、Writer；图有九个节点，因为 Reflect 节点复用 Planner Agent。旧稿的七个 Agent 或独立 Reflect Agent 表述均不精确。[V][E-ARCH-009]

### 3. 怎么防止幻觉引用？

Python 在检索后分配 source ID；Scout 和 Judge 的输出都被剪裁到允许集合；Writer 只收到合法 ID 列表，输出后正则删除非法编号并追加参考资料。这防的是“不存在的编号”。[V][E-FLOW-006][E-FLOW-007] 它没有证明某结论被某来源语义支持，仓库也没有评测支撑“幻觉率”数字。[U][E-OPEN-007]

### 4. SSE 是怎么实现的？

FastAPI 返回 `StreamingResponse`，工作线程同步消费 `app.stream(..., stream_mode="updates")`，通过 `asyncio.Queue` 送到异步生成器。前端用 fetch 读取字节流，按两个换行解析 `data:` JSON。发送的是 status/phase/route/final/error，最终正文一次性返回。[V][E-FLOW-001][E-FLOW-002][E-FLOW-003]

### 5. 记忆和 checkpointer 有什么区别？

Checkpointer 保存 LangGraph 状态，当前 namespace 只传 thread ID；MemoryManager 保存最近对话、摘要、画像、事实和可选任务，并在每轮前注入 Prompt。它们后端可能重叠，但数据模型和用途不同。[V][E-DATA-002][E-DATA-003]

### 6. 最严重的技术风险是什么？

优先级最高的是疑似真实 Key 已进 Git、运行时数据库被跟踪、API 无认证，以及 checkpoint/降级记忆的租户隔离不完整。先轮换密钥和隔离数据，再统一可信身份与三元上下文键，并建立无网络自动化测试。[V][E-RISK-001][E-RISK-002][E-RISK-003][E-RISK-006] 数据库内容是否真的含用户数据尚未读取确认。[I][E-RISK-007]

### 7. 你会怎么测试？

先测纯函数的意图、JSON fallback、source ID、引用和循环边界；再用 Fake Agent/检索器编译内存图，覆盖 direct、研究、补搜和空证据；API 层验证 schema 与 SSE 顺序；最后用隔离环境做受控端到端。真实 Bocha/模型测试必须 opt-in、有预算且不能用源码 Key。

### 8. 项目还有哪些工程问题？

依赖清单冲突、旧节点残留、RAG 入库脚本不可直接用、相关性过滤未接主链、核心文件过长、健康检查不覆盖依赖、记忆失败可能覆盖已生成结果，以及客户端取消未传播。

## 不能直接声称

| 声称 | 为什么不能说 | 需要的证据 |
|---|---|---|
| “项目已跑通/可一键启动” | 当前未执行安装和启动 | L4 干净环境运行记录 |
| “引用准确率 94%/幻觉率 6%” | 无数据集和评测脚本 | 指标定义、标注集、脚本、结果、日期 |
| “意图准确率 96%” | 无路由评测 | 分类数据集、混淆矩阵、基线 |
| “双源检索小于 8 秒” | 无 workload/环境/trace | 延迟分位数、环境和样本量 |
| “WebSocket 实时输出” | 当前实现为 POST SSE | 除非未来源码改变 |
| “Agent 自主调用工具” | 所有 Agent `tools=[]` | 除非未来接入工具调用 |
| “使用 Neo4j/MySQL/MCP” | 当前调用链未发现 | 真实源码/部署证据 |
| “具备企业多租户安全” | 无认证且隔离有缺口 | 威胁模型、认证授权、隔离测试 |
| “我设计并优化了这些机制” | 没有个人贡献确认 | 用户确认、提交/任务记录 |

## 面试前复核

- [ ] 两分钟介绍不超过事实边界。
- [ ] 能画系统上下文和 LangGraph。
- [ ] 能从 Web fetch 讲到 final SSE。
- [ ] 能解释一个 fallback、一个安全风险和一个设计取舍。
- [ ] 所有数字都有可复现来源；没有则明确说未验证。
- [ ] 区分项目已有实现、自己的实际贡献和未来改进。
