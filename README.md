# Hermes AI OS Layer

Hermes is the conversational and orchestration layer of the personal AI OS.

## What it provides

- **Personality packs** — architect, coder, analyst, operator, researcher
- **Skill routing** — diagnostics, remediation, codegen, planning, summarisation
- **Model routing** — local Ollama + optional cloud fallback
- **Deterministic policy layers** — enforce structure, safety, reproducibility
- **Execution profiles** — fast, deep, secure

## Quick start

```bash
# Validate config
yamllint config/hermes

# List personalities
hermes personalities list

# Run a skill
hermes run --skill diagnostics --input '{"system_state": "..."}'
```

## Repo layout

```
hermes-ai-os/
├── config/           # Hermes config, personalities, skills, profiles
├── docs/             # Docusaurus documentation site
├── diagrams/         # Mermaid + Draw.io architecture diagrams
├── tools/            # PowerShell module + skill packs
└── .github/workflows/# CI/CD pipeline
```

## License

MIT
