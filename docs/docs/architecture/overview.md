# Architecture Overview

Hermes sits between:

- **User interfaces** (CLI, editor, agents)
- **Models** (Ollama, cloud LLMs)
- **Skills** (diagnostics, remediation, codegen, planning, summarisation)

Core concepts:

- **Personality**: defines tone, role, and system prompt
- **Skill**: defines a task type, personality, model, and policy
- **Profile**: defines execution preferences (fast, deep, secure)
- **Routing**: maps tasks to skills and models
