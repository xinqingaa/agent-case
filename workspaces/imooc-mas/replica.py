"""Small offline Planner/ReAct teaching model; independent of source and services."""
from dataclasses import asdict, dataclass, field
import json
from typing import Callable, Protocol


@dataclass
class Observation:
    success: bool
    data: object = None
    error: str = ""


@dataclass
class Decision:
    kind: str
    text: str = ""
    tool: str = ""
    arguments: dict = field(default_factory=dict)


class Model(Protocol):
    def plan(self, request: str) -> list[str]: ...
    def decide(self, step: str, observations: list[Observation]) -> Decision: ...
    def revise(self, pending: list[str], results: list[str]) -> list[str]: ...
    def summarize(self, results: list[str]) -> str: ...


class Registry:
    def __init__(self):
        self.tools: dict[str, Callable[[dict], Observation]] = {}

    def register(self, name: str, function: Callable[[dict], Observation]):
        if name in self.tools:
            raise ValueError(f"duplicate tool: {name}")
        self.tools[name] = function

    def invoke(self, name: str, arguments: dict) -> Observation:
        if name not in self.tools:
            return Observation(False, error=f"unknown tool: {name}")
        try:
            result = self.tools[name](arguments)
            if not isinstance(result, Observation):
                raise TypeError("tool must return Observation")
            return result
        except Exception as exc:
            return Observation(False, error=str(exc))


def text_stats(arguments: dict) -> Observation:
    if not isinstance(arguments, dict) or set(arguments) != {"text"}:
        raise ValueError("expected exactly one argument: text")
    text = arguments["text"]
    if not isinstance(text, str) or len(text) > 10000:
        raise ValueError("text must be a string of at most 10000 characters")
    return Observation(True, {"characters": len(text), "words": len(text.split())})


class Engine:
    def __init__(self, model: Model, tools: Registry, max_steps=8, max_turns=4):
        if max_steps < 1 or max_turns < 1:
            raise ValueError("budgets must be positive")
        self.model, self.tools = model, tools
        self.max_steps, self.max_turns = max_steps, max_turns
        self.events = []

    def emit(self, event_type, **data):
        self.events.append({"id": len(self.events) + 1, "type": event_type, **data})

    @staticmethod
    def validate_plan(steps):
        if not isinstance(steps, list) or not all(isinstance(step, str) and step.strip() for step in steps):
            raise ValueError("plan must be a list of nonempty descriptions")
        return list(steps)

    def run(self, request):
        self.events = []
        try:
            pending = self.validate_plan(self.model.plan(request))
            if not pending:
                raise ValueError("empty plan")
            self.emit("plan", steps=list(pending))
            results = []
            while pending:
                if len(results) >= self.max_steps:
                    raise RuntimeError("plan step budget exhausted")
                step = pending.pop(0)
                self.emit("step_started", description=step)
                observations = []
                for _ in range(self.max_turns):
                    decision = self.model.decide(step, list(observations))
                    if decision.kind == "finish":
                        if not decision.text:
                            raise ValueError("empty step result")
                        results.append(decision.text)
                        self.emit("step_completed", result=decision.text)
                        break
                    if decision.kind == "ask":
                        self.emit("wait", question=decision.text)
                        return self.events
                    if decision.kind != "tool":
                        raise ValueError("unknown decision kind")
                    self.emit("tool_calling", tool=decision.tool, arguments=decision.arguments)
                    result = self.tools.invoke(decision.tool, decision.arguments)
                    observations.append(result)
                    self.emit("tool_called", tool=decision.tool, result=asdict(result))
                else:
                    raise RuntimeError("model turn budget exhausted")
                pending = self.validate_plan(self.model.revise(list(pending), list(results)))
                self.emit("plan_updated", steps=list(pending))
            self.emit("message", text=self.model.summarize(list(results)))
            self.emit("done")
        except Exception as exc:
            self.emit("error", message=str(exc))
        return self.events


class DemoModel:
    def plan(self, request):
        return [request]

    def decide(self, step, observations):
        if not observations:
            return Decision("tool", tool="text_stats", arguments={"text": step})
        if not observations[-1].success:
            raise RuntimeError(observations[-1].error)
        return Decision("finish", text=json.dumps(observations[-1].data))

    def revise(self, pending, results):
        return pending

    def summarize(self, results):
        return "; ".join(results)


if __name__ == "__main__":
    registry = Registry()
    registry.register("text_stats", text_stats)
    print(json.dumps(Engine(DemoModel(), registry).run("agent tools return observations"), indent=2))
