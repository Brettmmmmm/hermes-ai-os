# AI OS Orchestration Pipeline

Hermes acts as the orchestration layer for your personal AI OS.

## What It Coordinates

1. **Personality selection** — picks the right persona for the task
2. **Skill routing** — maps intent to skill definitions
3. **Model routing** — selects local or cloud model based on availability and cost
4. **Policy enforcement** — ensures output safety and structure
5. **Execution profiles** — trades speed for depth or security as needed

## The Windows Update Repair Pipeline

This is a concrete example of AI OS orchestration in action:

1. **Diagnostics skill** (analyst + kimi-k2.5:cloud)
2. **Remediation planning skill** (operator + kimi-k2.5:cloud)
3. **Codegen skill** (coder + deepseek-r1) for scripts
4. **Verification loop** using diagnostics again

## Self-Improvement Loop

Hermes can improve itself:

1. **Planning** — design a new skill or architecture change
2. **Codegen** — implement the change
3. **Diagnostics** — validate the change works
4. **Summarisation** — document the change

This creates a closed loop where the AI OS improves itself deterministically.

## Mermaid Diagram

See [/diagrams/mermaid/ai-os-overview.mmd](../../diagrams/mermaid/ai-os-overview.mmd) for the full architecture diagram.
