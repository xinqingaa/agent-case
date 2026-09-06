import sys
import unittest

sys.dont_write_bytecode = True
from replica import Decision, DemoModel, Engine, Registry, text_stats


class ReplicaBehavior(unittest.TestCase):
    def setUp(self):
        self.tools = Registry()
        self.tools.register("text_stats", text_stats)

    def test_complete_trace(self):
        events = Engine(DemoModel(), self.tools).run("hello world")
        self.assertEqual([event["type"] for event in events], ["plan", "step_started", "tool_calling", "tool_called", "step_completed", "plan_updated", "message", "done"])
        self.assertEqual(events[3]["result"]["data"], {"characters": 11, "words": 2})
        self.assertEqual([event["id"] for event in events], list(range(1, 9)))

    def test_invalid_parameters_are_failure_observations(self):
        for arguments in ({}, {"text": 123}, {"text": "x", "extra": True}, {"text": "x" * 10001}):
            with self.subTest(arguments=list(arguments)):
                self.assertFalse(self.tools.invoke("text_stats", arguments).success)

    def test_unknown_tool_and_duplicate_registration(self):
        self.assertFalse(self.tools.invoke("missing", {}).success)
        with self.assertRaises(ValueError):
            self.tools.register("text_stats", text_stats)

    def test_failed_observation_can_be_corrected(self):
        class Correcting(DemoModel):
            def decide(self, step, observations):
                if not observations:
                    return Decision("tool", tool="text_stats", arguments={"text": 123})
                if not observations[-1].success:
                    return Decision("tool", tool="text_stats", arguments={"text": step})
                return super().decide(step, observations)
        events = Engine(Correcting(), self.tools).run("hello")
        results = [event["result"]["success"] for event in events if event["type"] == "tool_called"]
        self.assertEqual(results, [False, True])
        self.assertEqual(events[-1]["type"], "done")

    def test_inner_budget_exhaustion_has_no_success(self):
        events = Engine(DemoModel(), self.tools, max_turns=1).run("hello")
        self.assertEqual(events[-1]["type"], "error")
        self.assertFalse(any(event["type"] == "done" for event in events))

    def test_outer_plan_growth_is_bounded(self):
        class Growing(DemoModel):
            def revise(self, pending, results):
                return ["another step"]
        events = Engine(Growing(), self.tools, max_steps=2).run("hello")
        self.assertEqual(events[-1]["message"], "plan step budget exhausted")

    def test_wait_does_not_complete_task(self):
        class Asking(DemoModel):
            def decide(self, step, observations):
                return Decision("ask", text="Which text?")
        events = Engine(Asking(), self.tools).run("hello")
        self.assertEqual(events[-1]["type"], "wait")
        self.assertNotIn("done", [event["type"] for event in events])

    def test_empty_and_malformed_plans(self):
        for steps in ([], None, [42], [""]):
            class BadPlan(DemoModel):
                def plan(self, request):
                    return steps
            self.assertEqual(Engine(BadPlan(), self.tools).run("hello")[-1]["type"], "error")


if __name__ == "__main__":
    unittest.main(verbosity=2)
