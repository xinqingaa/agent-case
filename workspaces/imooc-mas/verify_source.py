"""Behavioral probes against original code; no application config or services loaded."""
import copy
import json
import logging
from pathlib import Path
import sys
import unittest

sys.dont_write_bytecode = True
SOURCE = Path(__file__).resolve().parents[2] / "sources/imooc-mas/mooc-manus/api"
sys.path.insert(0, str(SOURCE))

from app.domain.models.app_config import AgentConfig
from app.domain.models.event import ErrorEvent, MessageEvent, StepEvent
from app.domain.models.memory import Memory
from app.domain.models.message import Message
from app.domain.models.plan import ExecutionStatus, Plan, Step
from app.domain.models.tool_result import ToolResult
from app.domain.services.agents.base import BaseAgent
from app.domain.services.agents.planner import PlannerAgent
from app.domain.services.agents.react import ReActAgent
from app.domain.services.tools.base import BaseTool, tool
from extension_tool import TextStatsTool


class MemoryUow:
    def __init__(self):
        self.session = self
        self.memories = {}

    async def __aenter__(self):
        return self

    async def __aexit__(self, *args):
        return False

    async def get_memory(self, session_id, name):
        return self.memories.setdefault((session_id, name), Memory())

    async def save_memory(self, session_id, name, memory):
        self.memories[session_id, name] = memory


class ScriptedLLM:
    def __init__(self, replies):
        self.replies = iter(replies)
        self.calls = []

    async def invoke(self, **kwargs):
        self.calls.append(copy.deepcopy(kwargs))
        return next(self.replies)


class JsonParser:
    async def invoke(self, text):
        return json.loads(text)


class EchoTool(BaseTool):
    name = "echo"

    def __init__(self):
        super().__init__()
        self.received = []

    @tool(name="echo", description="Return input", parameters={"text": {"type": "string"}}, required=["text"])
    async def echo(self, text: str):
        self.received.append(text)
        return ToolResult(data=text)


def answer(text):
    return {"role": "assistant", "content": text}


def tool_call(call_id="call-1"):
    return {"id": call_id, "type": "function", "function": {"name": "echo", "arguments": '{"text":"hello"}'}}


def make_agent(agent_class, replies, tools=None, iterations=3):
    store = MemoryUow()
    llm = ScriptedLLM(replies)
    agent = agent_class(lambda: store, "synthetic-session", AgentConfig(max_iterations=iterations), llm, JsonParser(), tools or [])
    agent._retry_interval = 0
    return agent, llm, store


class OriginalBehavior(unittest.IsolatedAsyncioTestCase):
    async def test_extension_runs_through_original_agent(self):
        call = tool_call()
        call["function"] = {"name": "text_stats_count", "arguments": '{"text":"hello world"}'}
        agent, llm, _ = make_agent(BaseAgent, [{"role": "assistant", "content": None, "tool_calls": [call]}, answer("two words")], [TextStatsTool()])
        events = [event async for event in agent.invoke("count")]
        self.assertEqual(events[1].function_result.data, {"characters": 11, "words": 2})
        self.assertEqual(llm.calls[0]["tools"][0]["function"]["name"], "text_stats_count")
        self.assertEqual(events[-1].message, "two words")

    async def test_extension_validates_types_and_length(self):
        tool_instance = TextStatsTool()
        for value in (42, True, None, "a" * 10001):
            self.assertFalse((await tool_instance.invoke("text_stats_count", text=value)).success)

    async def test_tool_result_enters_next_model_turn(self):
        echo = EchoTool()
        agent, llm, store = make_agent(BaseAgent, [{"role": "assistant", "content": None, "tool_calls": [tool_call()]}, answer("finished")], [echo])
        events = [event async for event in agent.invoke("run")]
        self.assertEqual([event.type for event in events], ["tool", "tool", "message"])
        self.assertEqual([event.status.value for event in events[:2]], ["calling", "called"])
        observation = llm.calls[1]["messages"][-1]
        self.assertEqual(observation["tool_call_id"], "call-1")
        self.assertEqual(json.loads(observation["content"])["data"], "hello")
        self.assertTrue(store.memories)

    async def test_only_first_of_multiple_tool_calls_executes(self):
        echo = EchoTool()
        agent, _, _ = make_agent(BaseAgent, [{"role": "assistant", "content": None, "tool_calls": [tool_call(), tool_call("call-2")]}, answer("finished")], [echo])
        _ = [event async for event in agent.invoke("run")]
        self.assertEqual(echo.received, ["hello"])

    async def test_schema_is_not_runtime_type_validation(self):
        echo = EchoTool()
        result = await echo.invoke("echo", text=42, unexpected="discarded")
        self.assertEqual(result.data, 42)
        self.assertEqual(echo.received, [42])
        with self.assertRaises(TypeError):
            await echo.invoke("echo")

    async def test_direct_unknown_tool_returns_exception_object(self):
        self.assertIsInstance(await EchoTool().invoke("missing"), ValueError)

    async def test_iteration_boundary_emits_error_and_final_message(self):
        agent, _, _ = make_agent(BaseAgent, [{"role": "assistant", "content": None, "tool_calls": [tool_call()]}, answer("finished")], [EchoTool()], iterations=1)
        events = [event async for event in agent.invoke("run")]
        self.assertEqual([event.type for event in events], ["tool", "tool", "error", "message"])

    async def test_failed_step_is_overwritten_after_error(self):
        class FailedReAct(ReActAgent):
            async def invoke(self, *args, **kwargs):
                yield ErrorEvent(error="synthetic failure")

        agent, _, _ = make_agent(FailedReAct, [])
        step = Step(description="example")
        snapshots = [event.model_dump(mode="json") async for event in agent.execute_step(Plan(steps=[step]), step, Message(message="run"))]
        self.assertEqual(snapshots[1]["status"], "failed")
        self.assertEqual(step.status, ExecutionStatus.COMPLETED)
        self.assertFalse(step.success)
        self.assertEqual(step.error, "synthetic failure")

    async def test_planner_preserves_completed_prefix(self):
        finished = Step(description="done", status=ExecutionStatus.COMPLETED)
        pending = Step(description="old pending")
        plan = Plan(steps=[finished, pending])
        agent, llm, _ = make_agent(PlannerAgent, [answer(Plan(steps=[Step(description="replacement")]).model_dump_json())])
        events = [event async for event in agent.update_plan(plan, finished)]
        self.assertEqual([step.description for step in plan.steps], ["done", "replacement"])
        self.assertEqual(events[0].status.value, "updated")
        self.assertEqual(llm.calls[0]["tool_choice"], "none")

    async def test_memory_compaction_is_targeted_removal(self):
        memory = Memory(messages=[{"role": "tool", "function_name": "browser_view", "content": "html"}, {"role": "tool", "function_name": "search", "content": "sources"}, {"role": "assistant", "content": "answer", "reasoning_content": "thinking"}])
        memory.compact()
        self.assertEqual(memory.messages[0]["content"], "(removed)")
        self.assertEqual(memory.messages[1]["content"], "sources")
        self.assertNotIn("reasoning_content", memory.messages[2])


if __name__ == "__main__":
    logging.disable(logging.CRITICAL)
    unittest.main(verbosity=2)
