# Models and Routing

Hermes routes every request to the optimal model based on the active **skill** and **execution profile**.

## Supported Models

| Alias | Provider | Model | Temperature | Max Tokens | Role |
|-------|----------|-------|-------------|------------|------|
| `ollama:kimi-k2.5:cloud` | Ollama | `kimi-k2.5:cloud` | 0.2 | 4096 | Default (deep reasoning) |
| `ollama:deepseek-r1` | Ollama | `deepseek-r1` | 0.1 | 4096 | Code generation |
| `openai:gpt-4.1-mini` | OpenAI | `gpt-4.1-mini` | 0.3 | 4096 | Fast / cloud fallback |

## Routing Table

| Task Type | Target Model | Personality |
|-----------|--------------|-------------|
| `summarisation` | `openai:gpt-4.1-mini` | researcher |
| `diagnostics` | `ollama:kimi-k2.5:cloud` | analyst |
| `remediation` | `ollama:kimi-k2.5:cloud` | operator |
| `codegen` | `ollama:deepseek-r1` | coder |
| `planning` | `ollama:kimi-k2.5:cloud` | architect |

## How Routing Works

1. **User prompt arrives** at the Hermes orchestration layer
2. **Intent classifier** tags the task (diagnostics, codegen, etc.)
3. **Skill definition** resolves the target personality and model
4. **Execution profile** (fast / deep / secure) may override temperature or model
5. **Deterministic policy layer** enforces output structure before returning

## Fallback Chain

```
Primary model (local Ollama) → Cloud model (OpenAI) → Default personality (architect)
```

This ensures maximum uptime even when local models are unavailable.
