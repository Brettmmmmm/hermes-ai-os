# Summarisation Skill

**ID:** `summarisation`
**Personality:** [researcher](../personalities/researcher)
**Model:** `openai:gpt-4.1-mini`

## Purpose
Fast, evidence-based summarisation for large or complex inputs.

## Input Schema
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `source` | string | Yes | Text, URL, or file path to summarise |
| `format` | string | No | `bullet`, `paragraph`, `structured` |
| `max_length` | int | No | Maximum output length in tokens |

## Output Structure
- **Summary** — One-paragraph overview
- **Key Points** — Bulleted takeaways

## Example Invocation
```bash
hermes run --skill summarisation --input '{"source":"10-page architecture doc","format":"structured","max_length":512}'
```
