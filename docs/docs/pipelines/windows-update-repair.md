# Windows Update Repair Pipeline

This pipeline is a deterministic, AI-driven workflow that orchestrates:

1. **Diagnostics**  
   Uses the `diagnostics` skill (analyst + kimi-k2.5:cloud) to identify symptoms, evidence, and root cause.

2. **Remediation Planning**  
   Uses the `windows-update-repair` skill pack (operator) to generate a structured plan.

3. **Script Generation**  
   Uses the `codegen` skill (coder + deepseek-r1) to produce a complete PowerShell script.

4. **Execution & Verification**  
   Runs the script, then re-invokes diagnostics to confirm resolution.

## Skill Pack Structure

The skill pack lives in:

```
tools/skill-packs/windows-update-repair/
```

It contains:

- `skill.yaml` — skill definition
- `prompts/system.md` — system prompt
- `prompts/examples.md` — example inputs/outputs
- `docs.md` — documentation for internal use

## Pipeline Flow

See `/diagrams/mermaid/windows-update-repair.mmd` and `/diagrams/drawio/windows-update-repair.drawio` for the full flow.

## Deterministic Output Format

Every invocation produces:

- Goal
- Diagnostics Summary
- Root Cause
- Remediation Plan
- PowerShell Script
- Verification Steps
- Post-Checks
