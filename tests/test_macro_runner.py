"""
Macro Sequence Execution Engine & Tests
"""

import asyncio
import time
from typing import List, Dict, Any


class MacroStep:
    def __init__(self, target: str, command: str, delay_ms: int = 100):
        self.target = target
        self.command = command
        self.delay_ms = delay_ms


class Macro:
    def __init__(self, id: str, name: str, steps: List[MacroStep]):
        self.id = id
        self.name = name
        self.steps = steps


class MacroRunner:
    def __init__(self):
        self.executed_log = []

    async def execute_step(self, step: MacroStep):
        # Simulate dispatching to target transport
        self.executed_log.append((step.target, step.command))
        if step.delay_ms > 0:
            await asyncio.sleep(step.delay_ms / 1000.0)

    async def run_macro(self, macro: Macro) -> List[str]:
        self.executed_log.clear()
        for step in macro.steps:
            await self.execute_step(step)
        return [f"{t}:{c}" for t, c in self.executed_log]


import pytest


@pytest.mark.asyncio
async def test_macro_execution_sequence():
    macro = Macro(
        id="watch_tv",
        name="Watch Tata Play TV",
        steps=[
            MacroStep(target="TV", command="POWER", delay_ms=10),
            MacroStep(target="TV", command="SOURCE_HDMI1", delay_ms=10),
            MacroStep(target="STB", command="POWER", delay_ms=10),
            MacroStep(target="STB", command="NUM_1", delay_ms=5),
            MacroStep(target="STB", command="NUM_0", delay_ms=5),
            MacroStep(target="STB", command="NUM_0", delay_ms=5),
        ]
    )

    runner = MacroRunner()
    result = await runner.run_macro(macro)

    assert result == [
        "TV:POWER",
        "TV:SOURCE_HDMI1",
        "STB:POWER",
        "STB:NUM_1",
        "STB:NUM_0",
        "STB:NUM_0"
    ]
    assert len(runner.executed_log) == 6
