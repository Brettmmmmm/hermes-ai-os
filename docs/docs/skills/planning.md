# Planning Skill

**ID:** `planning`
**Personality:** [architect](../personalities/architect)
**Model:** `ollama:kimi-k2.5:cloud`

## Purpose
Architectural planning with deterministic, risk-aware design output.

## Input Schema
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `objective` | string | Yes | What the system must do |
| `constraints` | list | No | Budget, time, compliance limits |
| `existing_stack` | string | No | Current technology landscape |

## Output Structure
- **Objective** — Clear success criteria
- **Constraints** — Hard and soft limits
- **Design** — Modular architecture
- **Risks** — Threats and mitigations

## Example Invocation
```bash
hermes run --skill planning --input '{"objective":"Migrate v2raya from snap to Docker","existing_stack":"snap, systemd, docker"}'
```
