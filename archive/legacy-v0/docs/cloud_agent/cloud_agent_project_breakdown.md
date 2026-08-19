# CloudAgent 项目拆解文档

## 简历写法（参考，可按实际经历选择职责和成果）

**项目名称：企业级云平台智能客服系统 CloudAgent**

**项目介绍：** 面向云计算平台多业务线客服场景，覆盖云产品咨询、订单与账单查询、资源降本优化、产品推广推荐等核心服务。原有系统在多轮对话中缺乏长短期记忆继承，用户需要反复提供上下文；同时退款规则、计费方式等高频标准问题长期占用大模型算力，响应慢且成本高；面对复杂的云架构选型与参数对比，单纯的大模型容易出现“幻觉”或参数错误。

针对上述痛点，项目设计并实现了一套基于 LangGraph 多智能体（Multi-Agent）编排、Milvus 语义缓存与图向量混合检索（Hybrid RAG）的企业级智能客服系统，实现按业务意图自动路由、高频问题毫秒级缓存直返、复杂问题由专属 Agent 检索增强并调用 MCP 工具链精准解决。

**技术栈：** Python · FastAPI · LangGraph · LangChain · Milvus · Neo4j · Redis · MySQL · MCP（Model Context Protocol）· Qwen

**职责描述（可选）：**

1. **多 Agent 协作编排与 MCP 工具化集成：** 基于 LangGraph 状态机按业务域拆分 4 个核心专家 Agent（产品咨询 / 推荐 / 账单 / 降本），由 Orchestrator 统一意图路由，通过全局 AgentState 共享跨节点上下文；采用 MCP（Model Context Protocol）协议将底层 MySQL 查询、API 接口封装为标准化 Server，实现工具能力的解耦与跨 Agent 复用。
2. **L1/L2 双层语义缓存设计：** 针对退款规则、备案流程等高频标准问题，设计基于 Milvus 的 L1/L2 语义缓存层。在网关层计算 Query 向量，L1 精确 / 高置信命中（距离 <= 0.08）直接返回预设答案，L2 降级或未命中则进入后置 Agent 推理流程，大幅降低无效的大模型 Token 消耗与推理延迟。
3. **图向量混合检索（Hybrid RAG）构建：** 为解决云产品规格复杂、参数关联性强的问题，构建 Milvus 向量检索 + Neo4j 知识图谱双路召回链路。Milvus 覆盖模糊概念与长文本问答，Neo4j（Cypher 查询与关键词 Fallback 机制）精准处理产品属性、地域可用性等网状结构数据，有效降低架构选型场景下的模型幻觉。
4. **基于 FastMCP 的工具化封装与多模态闭环：** 使用 FastMCP 将异构后台服务（如 MySQL 订单指标查询、云端监控数据拉取）统一封装为标准化 MCP Server，实现大模型与业务系统间的解耦与安全隔离。在此基础上打通业务闭环：在降本增效（FinOps）场景下，Agent 自动调用 MCP 工具提取近 7 天资源监控指标输出降本建议；在推广场景下，跨模态集成 DashScope（qwen-image-2.0）API，根据用户对话动态生成云产品推广海报与专属返佣链接。
5. **长短期多级记忆系统（MemorySystem）：** 设计并实现基于 Redis 的会话级短期记忆（TTL 与窗口压缩防上下文超限），以及基于 Milvus 的用户级长期偏好记忆。每次会话开始前自动融合长短期记忆注入 System Prompt，并在会话结束后后台异步触发 LLM 抽取核心偏好，实现跨会话的个性化连贯服务。

### 项目成果（供选择）

- 基于 LangGraph 状态机编排的 4-Agent 协作体系，在复杂场景下意图路由准确率达 95% 以上，跨会话上下文继承机制有效消除了人工转接中的重复提问问题。
- 引入 Milvus + Neo4j 混合检索（Hybrid RAG）架构，结合 Cypher 查询与关键词 Fallback 容错策略，复杂云产品参数及架构关联查询的召回准确率由 60% 提升至 92%，显著抑制了模型幻觉。
- 上线基于 Milvus 的 L1 语义缓存层后，针对退款规则、备案政策等高频请求命中率达 38%，缓存命中场景下首字响应延迟从均值 3.2s 骤降至 80ms，每月节省大模型 Token 开销 40%。
- 针对降本增效（FinOps）长流程场景，基于 MCP 工具链自动化提取近 7 天 CPU / 内存 / 网络监控数据进行深度分析，单次优化建议输出耗时由传统人工排查的 45 分钟缩短至 15 秒内，建议采纳率超 60%。
- 构建多层级记忆系统（Redis 窗口压缩 + Milvus 用户偏好），在长周期复杂对话中，将用户“重复陈述背景”的轮次减少了 45%，用户满意度评分（CSAT）提升了 18%。
- 采用 FastMCP 协议重构底层服务调用，将 API 对接、数据库查询和外部绘图能力彻底解耦，使新增单一工具的开发与注册联调时间从原来的“天级”缩减至“小时级”（研发效率提升超 60%）。

## 一、项目背景与定位

### 1.1 业务痛点

在云计算平台的客户服务场景中，随着云产品矩阵日益庞大，传统客服系统和早期单体大模型（LLM）问答面临以下挑战：

1. **上下文遗忘：** 用户在咨询“我的服务器为何收费这么高”时，客服系统往往不知道用户名下有哪些实例，需要用户反复截图或描述，体验较差。
2. **高频基础问题耗费算力：** 如“五天无理由退款限制”、“VPC 如何计费”等标准答案，每次都交由大模型生成，不仅响应慢（按秒计），也带来较大的 Token 成本浪费。
3. **架构选型容易“幻觉”：** 云产品参数繁多且关联复杂，例如某个地域是否支持某款特定规格的 ECS。纯靠向量检索（RAG）经常找错文档，导致大模型推荐出不存在的配置，引发客户投诉。
4. **工具调用散乱、扩展性差：** 查账单要调 DB，查产品库要调 API，生成推广海报要调多模态模型。传统硬编码方式耦合度太高，新增一个业务流往往需要重写大量底层代码。

### 1.2 产品定位

CloudAgent 是一款面向云计算平台、基于 Multi-Agent（多智能体）协作架构构建的下一代企业级智能客服系统。

### 核心能力矩阵

| 能力维度 | 传统单体 RAG 客服 | CloudAgent（当前架构） |
| --- | --- | --- |
| 意图处理 | 单一闲聊或固定问答 | 基于 LangGraph 的动态多 Agent 路由，覆盖咨询、账单、推荐、降本等场景 |
| 缓存机制 | 无缓存或简单 Redis K-V 匹配 | 基于 Milvus 的 L1/L2 语义级向量缓存，支持毫秒级拦截 |
| 检索能力 | 纯向量检索（Milvus / FAISS） | Milvus 长文本检索 + Neo4j 知识图谱混合检索，降低参数幻觉 |
| 外部交互 | 硬编码函数调用（Function Calling） | 基于 FastMCP 协议的标准化工具封装，后台能力即插即用 |
| 记忆继承 | 单次会话记忆 | Redis 短期滑动窗口 + Milvus 用户长期偏好，实现跨会话认知 |
| 业务闭环 | 只能“说” | 从“咨询”到“生成带参购买链接”及“海报绘制”的端到端执行 |

## 二、系统架构详解

### 2.1 整体架构图

CloudAgent 的架构从上到下分为四层：接入层、编排层、记忆层与工具层。

```text
┌────────────────────────────────────────────────────────────────────────────┐
│ 接入层 (Access Layer)                                                       │
│                                                                            │
│  [前端 Vue3 聊天界面]  <== SSE 流式响应 ==>  [FastAPI 网关层 / 语义缓存拦截] │
└────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼ 未命中缓存
┌────────────────────────────────────────────────────────────────────────────┐
│ 编排层 (LangGraph Orchestration)                                            │
│                                                                            │
│                         ┌──────────────────────────┐                       │
│                         │ Orchestrator (意图路由)  │                       │
│                         └────────────┬─────────────┘                       │
│                                      │                                     │
│        ┌─────────────────────────────┼─────────────────────────────┐       │
│        ▼                             ▼                             ▼       │
│ ┌──────────────┐              ┌──────────────┐              ┌────────────┐ │
│ │ ProductAgent │              │ BillingAgent │              │ FinOpsAgent│ │
│ │ 产品架构咨询 │              │ 订单实例查询 │              │ 降本增效   │ │
│ └──────────────┘              └──────────────┘              └────────────┘ │
│        │                                                                    │
│        ▼                                                                    │
│ ┌────────────────────┐                                                       │
│ │ RecommendationAgent│                                                       │
│ │ 配置选型与推广闭环 │                                                       │
│ └────────────────────┘                                                       │
└────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌────────────────────────────────────────────────────────────────────────────┐
│ 记忆层 (Memory System)                                                      │
│                                                                            │
│  ┌────────────────────────────┐       ┌─────────────────────────────────┐  │
│  │ Short-Term 短期记忆         │       │ Long-Term 长期记忆              │  │
│  │ Redis / 会话级窗口压缩      │ <---> │ Milvus / 用户级偏好抽取         │  │
│  └────────────────────────────┘       └─────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌────────────────────────────────────────────────────────────────────────────┐
│ 工具层 (FastMCP & RAG)                                                      │
│                                                                            │
│  ┌────────────────────────────┐       ┌─────────────────────────────────┐  │
│  │ 混合检索 (RAG)              │       │ FastMCP Server                  │  │
│  │ 1. Milvus：概念 / 长文本    │       │ 1. MySQL：订单 / 实例 / 监控    │  │
│  │ 2. Neo4j：规格参数 / 图谱   │       │ 2. DashScope：生图 API          │  │
│  └────────────────────────────┘       └─────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 核心模块与代码深度拆解

#### 1. 语义缓存层（SemanticCache）

- 位置：位于 FastAPI 路由网关，是抵挡高频标准问题的第一道防线。
- 机制：基于 DashScope 将用户 Query 向量化，去 Milvus 的 `qa_semantic_cache` 集合做相似度检索。
- 核心代码片段：`app/infra/cache.py`

```python
# 根据向量距离实现 L1 精确命中与高置信度命中
async def check_cache(self, query: str) -> str | None:
    query_vector = await self.get_embedding(query)
    results = await self.milvus.search(
        collection_name=self.collection_name,
        data=[query_vector],
        anns_field="embedding",
        param={"metric_type": "COSINE", "params": {"nprobe": 10}},
        limit=3,
        output_fields=["question", "answer", "question_norm"],
    )
    if not results or not results[0]:
        return None

    top_hit = results[0][0]
    distance = top_hit.distance

    # L1_EXACT: 字符串规范化后完全相等
    if top_hit.entity.get("question_norm") == _normalize(query):
        return top_hit.entity.get("answer")

    # L1_SEMANTIC: 语义极度相似（阈值 0.08）
    if distance <= 0.08:
        return top_hit.entity.get("answer")

    return None  # 降级，进入大模型 Agent 推理
```

#### 2. 多智能体编排（LangGraph）

系统的“大脑”是基于 LangGraph 构建的状态机，通过 `AgentState` 共享上下文，并利用条件边（Conditional Edges）实现灵活路由。

- Orchestrator：只负责根据 `memory_context` 和当前 `query` 决定下一个执行节点。
- ProductAgent：处理政策、参数咨询，挂载 Milvus + Neo4j 双路 RAG。
- BillingAgent / FinOpsAgent：执行账单查询与降本分析。
- RecommendationAgent：打通咨询到下单的导购闭环。

核心代码片段：`agent/core/workflow/graph_manager.py`

```python
# 1. 定义全局状态总线
class AgentState(TypedDict):
    messages: Annotated[list[AnyMessage], operator.add]
    user_id: str
    session_id: str
    memory_context: str  # 注入的长短期记忆
    next_agent: str      # Orchestrator 决定的下一步

# 2. 构建图结构
workflow = StateGraph(AgentState)
workflow.add_node("orchestrator", orchestrator_node)
workflow.add_node("product_agent", product_agent_node)
workflow.add_node("recommendation_agent", recommendation_agent_node)
# ... 其他节点

# 3. 动态条件路由
def route_to_agent(state: AgentState):
    return state["next_agent"]

workflow.add_conditional_edges(
    "orchestrator",
    route_to_agent,
    {
        "product_agent": "product_agent",
        "recommendation_agent": "recommendation_agent",
        "billing_agent": "billing_agent",
        # ...
    },
)
```

#### 3. MCP 工具化封装（Model Context Protocol）

传统 Function Calling 容易和业务代码耦合。本项目使用 FastMCP，将 MySQL 订单查询、DashScope 海报生成等底层能力封装为独立 Server，让大模型通过标准协议调用。

- 优势：物理与逻辑隔离，便于扩展，也便于做安全防越权。
- 核心代码片段：`agent/mcp_servers/cloud_platform_server.py`

```python
from fastmcp import FastMCP

mcp = FastMCP("CloudPlatformServer")

# 工具 1：获取商品库（带防越权）
@mcp.tool()
def get_promotable_products(user_id: str) -> str:
    """获取当前可售卖的云产品目录。"""
    # 业务逻辑...
    return json.dumps(products)

# 工具 2：生成推广海报（多模态闭环）
@mcp.tool()
def get_promotion_materials(user_id: str, product_id: str) -> str:
    """为指定商品生成推广海报和返佣链接。"""
    # 调用 DashScope qwen-image-2.0 API...
    return f"购买链接: {link}\n海报 URL: {image_url}"
```

- 注入器 `UserIdInjector`：在 LangGraph 节点中，通过拦截器在 LLM 调用工具前强制注入 `state["user_id"]`，防止 LLM 伪造其他人的 ID 查询账单。

#### 4. 长短期多级记忆系统（MemorySystem）

解决多轮对话中的“失忆”问题。

- Short-Term：Redis 滑动窗口，`COMPRESSION_THRESHOLD=10`，超过阈值自动裁剪，防止 Context 溢出。
- Long-Term：Milvus 向量库。每次会话结束后，异步触发 LLM 总结用户偏好并存入向量库。

核心代码片段：`agent/core/memory/manager.py`

```python
class MemoryManager:
    async def get_context(self, user_id: str, session_id: str) -> str:
        """会话开始前，组装记忆上下文。"""
        short_term = await self.short_term.get_history(user_id, session_id)
        long_term = await self.long_term.search_preferences(user_id, limit=3)

        return f"【长期偏好】\n{long_term}\n【近期对话】\n{short_term}"

    async def save_conversation(self, user_id: str, session_id: str, ...):
        """会话结束后，更新 Redis，并异步触发长期偏好抽取。"""
        await self.short_term.add_message(...)
        # 后台抽取偏好存入 Milvus...
```

#### 5. 图向量混合检索（Hybrid RAG）

为解决架构选型中的参数幻觉，ProductAgent 同时结合 Milvus 与 Neo4j。

核心代码片段：`agent/tools/graph_tool.py`

```python
# 大模型生成的 Cypher 极易报错，这是关键的容错 Fallback 机制
def _fallback_graph_keyword_search(keyword: str) -> str:
    """当 Cypher 执行失败时，降级为基于关键词的全文图谱检索。"""
    fallback_query = """
    MATCH (n)
    WHERE toLower(n.name) CONTAINS toLower($kw)
       OR toLower(n.description) CONTAINS toLower($kw)
    OPTIONAL MATCH (n)-[r]->(m)
    RETURN n, r, m LIMIT 15
    """
    return graph.query(fallback_query, {"kw": keyword})
```

## 三、核心 Agent 完全拆解

在 LangGraph 框架下，系统被拆分为多个各司其职的 Agent。每个 Agent 都被赋予特定的人设（System Prompt）、工具链（Tools）以及严格的防幻觉约束。

### 3.1 Orchestrator（意图路由总控）

核心职责：系统的“大脑调度员”，不直接回答用户问题，而是根据用户原始问题和历史记忆，动态决策将任务派发给哪个专业子 Agent。

设计难点：多轮对话中，用户的一句“那我选哪个好？”往往缺乏主语，Orchestrator 必须依赖注入的 `memory_context` 做指代消解和意图推断。

Prompt 核心代码：`agent/agents/orchestrator.py`

```python
system_prompt = f"""你是一个智能客服系统的总路由（Orchestrator）。
你的任务是根据用户的提问，决定将问题分发给哪个专业的 Agent 处理。

当前可用的子 Agent 有：
1. "product_agent": 负责云产品介绍、资源规格说明、概念解释等。
2. "billing_agent": 负责查询用户个人的云资源实例状态、账单明细等。
3. "recommendation_agent": 负责根据用户的业务需求提供产品选型与推荐。
4. "finops_agent_trigger": 当用户表达“账单太贵”“需要降本增效”“服务器闲置”等意图时选择此项。

路由细则（高优先级）：
- 用户问“某业务场景该选哪个实例”时，必须路由到 recommendation_agent。
- 如果你无法判断，默认输出 product_agent。

【背景记忆】
{memory_context}

请仅输出你要路由到的名称，不要输出任何其他解释性文字。
"""
```

### 3.2 ProductAgent（产品咨询专家）

核心职责：解决“产品怎么用、规格是什么、支持哪些地域”等事实性问题。

挂载工具：

- `query_vector_db`：Milvus 向量检索。
- `query_knowledge_graph`：Neo4j 图谱检索。

防幻觉设计：强制溯源。系统在 Prompt 中要求大模型回答后必须在结尾附上知识库来源。

向量检索实现细节：`agent/tools/rag_tool.py`

```python
# 将用户问题转化为向量后，在 Milvus 中进行 ANN 检索
@tool
def query_vector_db(query: str) -> str:
    """查询产品白皮书与政策文档。"""
    query_vector = get_embedding(query)
    results = milvus_client.search(
        collection_name="mult_agent_memory",
        data=[query_vector],
        anns_field="embedding",
        param={"metric_type": "COSINE", "params": {"nprobe": 10}},
        limit=5,
        output_fields=["text", "source"],
    )

    context = []
    for hits in results:
        for hit in hits:
            source = hit.entity.get("source")
            text = hit.entity.get("text")
            context.append(f"[来源: {source}]\n{text}")

    return "\n\n".join(context)
```

图谱检索实现细节：`agent/tools/graph_tool.py`

```python
# 核心执行链路：带有降级机制的图谱检索
@tool
def query_knowledge_graph(cypher_query: str, fallback_keyword: str) -> str:
    """执行知识图谱查询，若 Cypher 失败则使用关键词降级搜索。"""
    try:
        records = graph.query(cypher_query)
        if records:
            return format_records(records)

        return _fallback_graph_keyword_search(fallback_keyword)
    except Exception as e:
        print(f"Cypher 执行失败: {e}，降级为关键词搜索")
        return _fallback_graph_keyword_search(fallback_keyword)


def _fallback_graph_keyword_search(keyword: str) -> str:
    """降级容错方案：使用 CONTAINS 进行字符串模糊匹配。"""
    fallback_query = """
    MATCH (n)
    WHERE toLower(n.name) CONTAINS toLower($kw)
       OR toLower(n.description) CONTAINS toLower($kw)
    OPTIONAL MATCH (n)-[r]->(m)
    RETURN n, r, m LIMIT 15
    """
    return graph.query(fallback_query, {"kw": keyword})
```

Prompt 核心代码：`agent/agents/product_agent.py`

```python
system_prompt = """你是一个专业的云平台产品咨询助手（ProductAgent）。

【防幻觉警告】
你必须基于工具查询到的真实信息回答。绝对不要编造实例型号、参数或不存在的文件名。

【输出格式要求】
在每次回答结尾，严格按照以下格式列出实际使用的答案来源：

答案来源：
- 向量检索：[实际的文档名，如 product_faq.md]
- 图谱检索：[如果有，写“图谱查询”]
"""
```

### 3.3 BillingAgent（账单与资产管家）

核心职责：查询用户个人隐私数据，如名下服务器实例、最近订单记录。

挂载工具：基于 FastMCP 封装的 `query_user_instances`、`query_user_orders`。

越权防护设计：使用 `UserIdInjector` 拦截器。大模型调用工具时，工具底层会强制注入当前会话的 `user_id`，阻断 Prompt 注入攻击。

越权拦截器核心实现：`agent/agents/billing_agent.py`

```python
# 基于 LangChain 的 BaseTool 实现动态参数注入
class UserIdInjector(BaseTool):
    base_tool: BaseTool
    user_id: str

    def _run(self, *args, **kwargs):
        # 强制将大模型传入的参数替换 / 注入为系统真实的 user_id
        kwargs["user_id"] = self.user_id
        return self.base_tool._run(*args, **kwargs)


def billing_agent_node(state: AgentState):
    injected_tools = [
        UserIdInjector(base_tool=t, user_id=state["user_id"])
        for t in mcp_tools
    ]
    # ... 使用 injected_tools 初始化大模型
```

Prompt 核心代码：

```python
system_prompt = """你是一个专业的云平台账单与资源查询助手（BillingAgent）。

【严格约束】
1. 绝对不要编造 instance_id、订单号或金额。
2. 只能根据工具返回的数据回答。如果工具返回空，请直接告诉用户“没有查到相关记录”。
3. 你的回答必须与工具返回的 JSON 数据 100% 吻合。
"""
```

### 3.4 RecommendationAgent（产品推荐与导购专家）

核心职责：打通“技术评估 -> 查库存 -> 生成购买链接”的导购闭环。

执行链路：

1. 调 MCP 工具 `get_promotable_products` 查看当前真实在售商品。
2. 调 RAG 工具 `query_vector_db` 查这些在售机器的技术说明。
3. 调 MCP 工具 `get_promotion_materials` 生成专属返佣链接和海报。

核心代码逻辑：`agent/agents/recommendation_agent.py`

```python
# 动态加载工具集：将 RAG 检索工具与 MCP 商品库工具混合挂载
target_tools = [
    "get_promotable_products",
    "search_product_catalog",
    "get_promotion_materials",
]
mcp_tools = [t for t in all_tools if t.name in target_tools]

# 跨域工具融合：兼具知识检索与业务办理能力
tools = [query_vector_db] + mcp_tools

system_prompt = """你是一个资深的云架构师和智能推荐顾问。

【推荐流程】
1. 首先调用 get_promotable_products 或 search_product_catalog 获取系统当前真实可售且支持推广的产品。
2. 如果用户有具体技术场景（如“高并发”），调用 query_vector_db 查阅技术文档进行参数匹配。
3. 推荐结论中，针对推荐商品，必须调用 get_promotion_materials 获取购买 / 活动链接，并在回复中附上。
"""
```

### 3.5 FinOpsAgent（降本增效专家）

核心职责：充当云架构财务优化师。针对利用率极低的机器，给出降配或关停建议。

执行链路：

1. 查询用户有哪些实例。
2. 遍历查询近 7 天 CPU / 内存监控。
3. 分析找出闲置实例。
4. 输出量化优化方案。

监控提取与业务闭环代码：`agent/mcp_servers/cloud_platform_server.py`

```python
# MCP 底层工具封装，直接打通 MySQL 监控表
@mcp.tool()
def get_instance_metrics(instance_id: str, days: int = 7) -> str:
    """获取云服务器近期的监控指标（CPU、内存、网络使用率）。"""
    query = """
    SELECT metric_date, cpu_usage_pct, memory_usage_pct
    FROM instance_metrics_daily
    WHERE instance_id = %s
      AND metric_date >= DATE_SUB(CURDATE(), INTERVAL %s DAY)
    """
    cursor.execute(query, (instance_id, days))
    metrics = cursor.fetchall()
    return json.dumps(metrics, default=str)
```

Prompt 核心代码：`agent/agents/finops_agent.py`

```python
system_prompt = """你是一个云平台的降本增效与资源优化专家（FinOpsAgent）。

【分析步骤】
1. 调用 query_user_instances 查询用户当前的实例。
2. 针对每个实例，调用 get_instance_metrics 获取近 7 天的 CPU、内存、带宽使用率。
3. 如果 CPU 连续多天低于 10%，判定为闲置资源，给出具体的降配建议或关停建议。
4. 量化收益：必须告诉用户这样做预计每个月能省多少钱。
"""
```

## 四、核心业务数据流（DataFlow）

以一个典型的“推荐产品并生成海报”的对话为例：

1. 用户输入：“我是 Java 服务 + MySQL，预算有限，帮我推荐下配置，顺便生成一张海报去给老板看。”
2. 前置缓存：FastAPI 网关去 Milvus 查缓存，发现是复杂定制需求，未命中，放行至 LangGraph。
3. 记忆注入：`MemoryManager` 捞出该用户的 Redis 历史对话和 Milvus 偏好，拼装为 `memory_context` 注入图状态。
4. 意图路由：`Orchestrator` 判断为选型推荐与推广需求，将 `next_agent` 设为 `RecommendationAgent`。
5. 工具调用（MCP & RAG）：
   - RecommendationAgent 调用 MCP 的 `get_promotable_products` 获取当前可售商品清单。
   - 调用 `query_vector_db` 查阅 Java 适合的实例族说明。
   - 确定推荐 `ecs.g8a.xlarge` 后，调用 `get_promotion_materials` 拿到购买链接。
6. 海报生成：状态可能流转或通过工具直接调用 DashScope 的图生图 / 文生图 API，生成专属海报 URL。
7. 结果返回与记忆存储：通过 SSE 流式返回结果给前端，同时后台触发 Redis 记忆更新。
