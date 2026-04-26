# Hermes AI OS Layer

> **Conversational orchestration for a deterministic, self-improving AI operating system.**

Hermes is the bridge between you and your models. It handles **intent classification**, **personality selection**, **skill routing**, **model fallback**, and **deterministic policy enforcement** — so every output is structured, safe, and reproducible.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        User / CLI / Editor                          │
└──────────────────────────────────┬──────────────────────────────────┘
                                   │
                    ┌──────────────▼──────────────┐
                    │   Intent Classifier         │
                    └──────────────┬──────────────┘
                                   │
          ┌────────────────────────┼────────────────────────┐
          │            ┌───────────▼────────────┐         │
          │            │  Hermes Router           │         │
          │            │  • Skill routing         │         │
          │            │  • Personality switch    │         │
          │            │  • Model fallback        │         │
          │            │  • Policy enforcement    │         │
          │            └───────────┬────────────┘         │
          │                        │                      │
   ┌──────▼──────┐      ┌─────────▼─────────┐   ┌───────▼───────┐
   │   Skills    │      │   Personalities    │   │   Profiles    │
   │ • diagnostics│      │ • architect        │   │ • fast        │
   │ • remediation│     │ • coder            │   │ • deep        │
   │ • codegen   │      │ • analyst          │   │ • secure      │
   │ • planning  │      │ • operator         │   └───────────────┘
   │ • summarise│       │ • researcher       │
   └──────┬──────┘      └─────────┬─────────┘
          │                       │
          └───────────┬───────────┘
                      │
           ┌──────────▼──────────┐
           │    Model Layer      │
           ├─────────────────────┤
           │ Ollama (local)      │
           │  • kimi-k2.5:cloud  │
           │  • deepseek-r1      │
           ├─────────────────────┤
           │ Cloud (fallback)    │
           │  • gpt-4.1-mini     │
           └─────────────────────┘
```

Detailed diagrams:
- [Mermaid: AI OS Overview](diagrams/mermaid/ai-os-overview.mmd)
- [Mermaid: Hermes Routing](diagrams/mermaid/hermes-routing.mmd)
- [Draw.io: AI OS Overview](diagrams/drawio/ai-os-overview.drawio)
- [Draw.io: Hermes Routing](diagrams/drawio/hermes-routing.drawio)

---

## What Hermes Provides

| Layer | What It Does |
|-------|--------------|
| **Personalities** | Tuned system prompts for architect, coder, analyst, operator, researcher roles |
| **Skill Routing** | Maps intent to the right personality + model + output structure |
| **Model Routing** | Local-first (Ollama) with optional cloud fallback |
| **Policy Layers** | Enforces format, safety, and reproducibility on every output |
| **Execution Profiles** | Fast, deep, or secure — trade speed for accuracy or safety |
| **Skill Packs** | Reusable, signed, sandboxed bundles (e.g. Windows Update Repair) |
| **Pipelines** | Chains skills into end-to-end deterministic workflows |
| **PowerShell Module** | `Invoke-HermesSkill` and `Invoke-WindowsUpdateRepair` wrappers |
| **CI/CD** | GitHub Actions validate YAML, package modules, and release on tags |

---

## Directory Structure

```
hermes-ai-os/
├── README.md
├── LICENSE
├── .gitignore
│
├── config/
│   └── hermes/
│       ├── config.yaml              # Main routing + model config
│       ├── personalities/           # 5 persona packs (yaml)
│       │   ├── architect.yaml
│       │   ├── coder.yaml
│       │   ├── analyst.yaml
│       │   ├── operator.yaml
│       │   └── researcher.yaml
│       └── skills/                # 5 skill definitions (yaml)
│           ├── diagnostics.yaml
│           ├── remediation.yaml
│           ├── codegen.yaml
│           ├── planning.yaml
│           └── summarisation.yaml
│
├── config/profiles/
│   ├── fast.yaml                  # Low-latency, standard safety
│   ├── deep.yaml                  # Maximum reasoning depth
│   └── secure.yaml                # Zero-temperature, strict filtering
│
├── docs/                          # Docusaurus site (full documentation)
│   ├── docusaurus.config.ts
│   ├── sidebars.ts
│   └── docs/
│       ├── index.md
│       ├── architecture/
│       │   ├── overview.md
│       │   ├── models-and-routing.md
│       │   └── policy-layers.md
│       ├── personalities/
│       │   ├── architect.md
│       │   ├── coder.md
│       │   ├── analyst.md
│       │   ├── operator.md
│       │   └── researcher.md
│       ├── skills/
│       │   ├── diagnostics.md
│       │   ├── remediation.md
│       │   ├── codegen.md
│       │   ├── planning.md
│       │   └── summarisation.md
│       └── pipelines/
│           ├── overview.md
│           ├── windows-update-repair.md
│           └── ai-os-orchestration.md
│
├── diagrams/
│   ├── mermaid/                   # Text-based diagrams (render anywhere)
│   │   ├── ai-os-overview.mmd
│   │   ├── hermes-routing.mmd
│   │   └── windows-update-repair.mmd
│   └── drawio/                    # Editable Draw.io XML
│       ├── ai-os-overview.drawio
│       ├── hermes-routing.drawio
│       └── windows-update-repair.drawio
│
├── tools/
│   ├── modules/
│   │   └── Hermes.Orchestration/  # PowerShell module
│   │       ├── Hermes.Orchestration.psm1
│   │       └── Hermes.Orchestration.psd1
│   └── skill-packs/
│       └── windows-update-repair/ # Example skill pack
│           ├── skill.yaml
│           └── prompts/
│               ├── system.md
│               └── examples.md
│
└── .github/workflows/
    └── release.yml                # CI: validate, package, release
```

---

## Quick Start

### Prerequisites

- **Ollama** running locally with your desired models (e.g. `kimi-k2.5:cloud`, `deepseek-r1`)
- Optional: **OpenAI API key** for cloud fallback
- PowerShell 5.1+ (for the module)

### Validate Config

```bash
pip install yamllint
yamllint config/hermes
yamllint tools/skill-packs
```

### Run a Skill

```bash
hermes run --skill diagnostics \
  --input '{"system_state":"v2raya crash loop","logs":"port 2017 in use"}'
```

### Switch Profile

```bash
hermes run --skill planning --profile deep \
  --input '{"objective":"Migrate v2raya from snap to Docker"}'
```

### PowerShell Module

```powershell
Import-Module ./tools/modules/Hermes.Orchestration
Invoke-WindowsUpdateRepair -SystemState "WU failing" -ErrorCodes @("0x80070424")
```

---

## Personalities

| ID | Role | Model | Best For |
|----|------|-------|----------|
| `architect` | Enterprise Architect | kimi-k2.5:cloud | System design, planning, risk assessment |
| `coder` | Code Engineer | deepseek-r1 | Script generation, implementations |
| `analyst` | Security Analyst | kimi-k2.5:cloud | Root cause analysis, threat modelling |
| `operator` | Ops Engineer | kimi-k2.5:cloud | Runbooks, remediation, repair flows |
| `researcher` | Technical Researcher | gpt-4.1-mini | Summaries, comparisons, evidence analysis |

---

## Skills

| ID | Personality | Model | Policy Structure |
|----|-------------|-------|-----------------|
| `diagnostics` | analyst | kimi-k2.5:cloud | Symptoms → Root Cause → Evidence → Remediation |
| `remediation` | operator | kimi-k2.5:cloud | Goal → Plan → Steps → Verification |
| `codegen` | coder | deepseek-r1 | Context → Code → Explanation |
| `planning` | architect | kimi-k2.5:cloud | Objective → Constraints → Design → Risks |
| `summarisation` | researcher | gpt-4.1-mini | Summary → Key Points |

---

## Execution Profiles

| Profile | Temperature | Safety | Model | Use Case |
|---------|-------------|--------|-------|----------|
| `fast` | 0.2 | Standard | gpt-4.1-mini | Quick answers, low latency |
| `deep` | 0.1 | Standard | kimi-k2.5:cloud | Complex reasoning, high accuracy |
| `secure` | 0.0 | Strict | kimi-k2.5:cloud | Zero-tolerance, deterministic output |

---

## Pipelines

| Pipeline | Skills Chained | Purpose |
|----------|----------------|---------|
| [Windows Update Repair](docs/docs/pipelines/windows-update-repair.md) | diagnostics → remediation → codegen → verification | Repair Windows Update |
| [AI OS Orchestration](docs/docs/pipelines/ai-os-orchestration.md) | planning → codegen → diagnostics → summarisation | Self-improving AI OS |

---

## Deterministic Guarantees

Hermes enforces three policy layers on every output:

1. **Format Policy** — Validates required headings and structure
2. **Safety Policy** — Temperature, retry limits, content filtering
3. **Reproducibility Policy** — Pinned models, seeding, caching, idempotency checks

---

## CI/CD

On every `v*.*.*` tag:

1. **Validate** — `yamllint` all YAML, validate skill packs
2. **Package** — Bundle PowerShell module as artifact
3. **Release** — Create GitHub Release with attached artifacts

---

## Roadmap

- [ ] Real Hermes runtime daemon (event bus + queue)
- [ ] WebSocket event stream
- [ ] Plugin marketplace with signing + sandboxing
- [ ] TUI dashboard (ratatui / bubbletea)
- [ ] Web dashboard (React/Vue)
- [ ] Mesh network sync (CRDT-based)
- [ ] QUIC transport layer

---

## License

MIT — see [LICENSE](LICENSE).

Built with intention by **bm**.
