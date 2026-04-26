# Pipeline Overview

A **pipeline** chains multiple skills into a deterministic, end-to-end workflow.

## Pipeline Anatomy

```
[User Input] → [Profile Select] → [Skill 1] → [Skill 2] → ... → [Verification] → [Output]
```

## Built-In Pipelines

| Pipeline | Skills Chained | Purpose |
|----------|----------------|---------|
| [Windows Update Repair](windows-update-repair) | diagnostics → remediation → codegen → verification | Repair Windows Update failures |
| [AI OS Orchestration](ai-os-orchestration) | planning → codegen → diagnostics → summarisation | Hermes self-improvement |

## Creating a Pipeline

1. Define a YAML skill pack in `tools/skill-packs/<name>/`
2. Reference upstream skill outputs as `inputs` to downstream skills
3. Add verification loops (re-run diagnostics after remediation)
4. Register in `config/hermes/skills/<name>.yaml`

## Execution Profiles

| Profile | Speed | Depth | Safety |
|---------|-------|-------|--------|
| `fast` | High | Low | Standard |
| `deep` | Medium | High | Standard |
| `secure` | Low | High | Strict |

Select at runtime: `hermes run --profile secure ...`
