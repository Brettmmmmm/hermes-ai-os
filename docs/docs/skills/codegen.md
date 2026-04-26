# Codegen Skill

**ID:** `codegen`
**Personality:** [coder](../personalities/coder)
**Model:** `ollama:deepseek-r1`

## Purpose
High-quality, complete code generation with no placeholders.

## Input Schema
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `context` | string | Yes | What the code should accomplish |
| `language` | string | No | `powershell`, `python`, `bash`, `rust` |
| `constraints` | list | No | Performance, compatibility, or security limits |

## Output Structure
- **Context** — Restated requirements
- **Code** — Complete implementation
- **Explanation** — Design rationale

## Example Invocation
```bash
hermes run --skill codegen --input '{"context":"Docker restart script for v2raya","language":"bash"}'
```
