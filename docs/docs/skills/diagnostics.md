# Diagnostics Skill

**ID:** `diagnostics`
**Personality:** [analyst](../personalities/analyst)
**Model:** `ollama:kimi-k2.5:cloud`

## Purpose
Structured system diagnostics performed by the Analyst personality.

## Input Schema
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `system_state` | string | Yes | Current system description |
| `logs` | string | No | Relevant log excerpts |
| `error_codes` | list | No | Error codes or identifiers |

## Output Structure
- **Symptoms** — Observable behaviour
- **Root Cause** — Underlying trigger
- **Evidence** — Supporting data
- **Remediation** — Initial fix proposal

## Example Invocation
```bash
hermes run --skill diagnostics --input '{"system_state":"v2raya crash loop","logs":"port 2017 in use","error_codes":["EADDRINUSE"]}'
```
