# Remediation Skill

**ID:** `remediation`
**Personality:** [operator](../personalities/operator)
**Model:** `ollama:kimi-k2.5:cloud`

## Purpose
Deterministic repair planning and execution guidance.

## Input Schema
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `diagnostics_report` | string | Yes | Output from diagnostics skill |
| `system_type` | string | No | `windows`, `linux`, `docker`, etc. |

## Output Structure
- **Goal** — What success looks like
- **Plan** — High-level strategy
- **Steps** — Numbered, idempotent actions
- **Verification** — Confirmation checks

## Example Invocation
```bash
hermes run --skill remediation --input '{"diagnostics_report":"...","system_type":"docker"}'
```
