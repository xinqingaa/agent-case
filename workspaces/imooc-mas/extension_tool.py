"""A pure read-only tool for the original MoocManus BaseTool contract."""
from app.domain.models.tool_result import ToolResult
from app.domain.services.tools.base import BaseTool, tool


class TextStatsTool(BaseTool):
    name = "text_stats"

    @tool(
        name="text_stats_count",
        description="Count characters and whitespace-delimited words in supplied text.",
        parameters={"text": {"type": "string", "maxLength": 10000}},
        required=["text"],
    )
    async def count(self, text: str) -> ToolResult:
        if not isinstance(text, str) or len(text) > 10000:
            return ToolResult(success=False, message="text must be a string of at most 10000 characters")
        return ToolResult(data={"characters": len(text), "words": len(text.split())})
