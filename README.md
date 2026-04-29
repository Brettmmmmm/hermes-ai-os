# Hermes AI OS

> **An enterprise-grade AI operating system — not a chatbot with plugins.**

Hermes AI OS is the unified intelligence layer that orchestrates infrastructure, provides enterprise architecture tooling, generates income, and operates autonomously across platforms. It thinks in personalities, routes through skills, and draws from a multi-model reasoning fabric.

---

## What Hermes AI OS Is

Hermes is the bridge between **intent and execution**. It classifies every incoming request, selects the right personality (system prompt + reasoning lens), routes to the optimal model, enforces deterministic output policy, and produces structured, verifiable results.

But it's more than routing. Hermes IS the AI OS:

| Layer | Function |
|-------|----------|
| **Personality Engine** | 7 tuned reasoning lenses: Architect, Coder, Analyst, Operator, Researcher, Advisor, Tutor |
| **Skill Layer** | 8 deterministic skill contracts with enforced output structures |
| **Model Fabric** | 11 models across Ollama cloud + OpenAI, each assigned to the right task |
| **Domain Skills** | Enterprise Architecture, VoxFlow Operations, Income Generation, Hermes Mesh |
| **Policy Enforcement** | Format, safety, and reproducibility guarantees on every output |
| **Execution Profiles** | Fast, deep, or secure — trade speed for accuracy |
| **Pipelines** | Chained skills for end-to-end autonomous workflows |
| **Hermes Mesh** | QUIC-native, CRDT-based multi-agent orchestration fabric (Phase 4) |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                       HERMES AI OS LAYER                             │
│                                                                      │
│   ┌─────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│   │  CHAT   │  │   CRON   │  │   MESH   │  │   API    │           │
│   │Telegram │  │Automation│  │Multi-Agent│  │ REST/WS  │           │
│   │  CLI    │  │Briefings │  │Orchestr. │  │ Web UI   │           │
│   └────┬────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘           │
│        │            │             │              │                   │
│   ┌────┴────────────┴─────────────┴──────────────┴─────┐           │
│   │              PERSONALITY ENGINE                     │           │
│   │  architect | coder | analyst | operator | researcher │          │
│   │              advisor | tutor                         │          │
│   └──────────────────────┬──────────────────────────────┘           │
│                          │                                           │
│   ┌──────────────────────┴──────────────────────────────┐           │
│   │                   SKILL LAYER                        │           │
│   │  diagnostics | codegen | planning | remediation      │           │
│   │  enterprise-architecture | voxflow-operations        │           │
│   │  income-generation | hermes-mesh                     │           │
│   └──────────────────────┬──────────────────────────────┘           │
│                          │                                           │
│   ┌──────────────────────┴──────────────────────────────┐           │
│   │                 MODEL FABRIC                         │           │
│   │  DeepSeek v4 Pro | Kimi K2.6 | Qwen 3.5 | Kimi K2.5 │           │
│   │  DeepSeek V3.1 671B | GLM-5 | MiniMax M2.7          │           │
│   └──────────────────────┬──────────────────────────────┘           │
│                          │                                           │
│   ┌──────────────────────┴──────────────────────────────┐           │
│   │            TOOLS & INTEGRATIONS                      │           │
│   │  GitHub | Docker | Pulumi | K8s | Ollama | Email     │           │
│   └─────────────────────────────────────────────────────┘           │
└─────────────────────────────────────────────────────────────────────┘
```

Detailed diagram: [Hermes Full Architecture](diagrams/mermaid/hermes-full-architecture.mmd)

---

## Personalities

Each personality is a tuned reasoning lens — a system prompt with an assigned default model.

| ID | Role | Default Model | Best For |
|----|------|---------------|----------|
| `architect` | Enterprise Architect | deepseek-v4-pro:cloud | System design, risk assessment, ADRs |
| `coder` | Code Engineer | deepseek-v3.1:671b-cloud | Script generation, implementations |
| `analyst` | Systems Analyst | kimi-k2.6:cloud | Root cause analysis, diagnostics |
| `operator` | Ops Engineer | kimi-k2.6:cloud | Runbooks, remediation, deployment |
| `researcher` | Technical Researcher | qwen3.5:cloud | Summaries, comparisons, evidence |
| `advisor` | Strategic Advisor | deepseek-v4-pro:cloud | Holistic analysis, second-order effects |
| `tutor` | Expert Tutor | qwen3.5:cloud | Clear explanations, comprehension |

---

## Skills

Skills are deterministic contracts: personality + model + enforced output structure.

### Core Operational Skills

| ID | Personality | Model | Output Structure |
|----|-------------|-------|-----------------|
| `diagnostics` | analyst | kimi-k2.6:cloud | Symptoms → Root Cause → Evidence → Remediation |
| `remediation` | operator | kimi-k2.6:cloud | Goal → Plan → Steps → Verification |
| `codegen` | coder | deepseek-v3.1:671b-cloud | Context → Code → Explanation |
| `planning` | architect | deepseek-v4-pro:cloud | Objective → Constraints → Design → Risks |
| `summarisation` | researcher | qwen3.5:cloud | Summary → Key Points |

### Domain Skills

| ID | Personality | Model | Purpose |
|----|-------------|-------|---------|
| `enterprise-architecture` | architect | deepseek-v4-pro:cloud | TOGAF, ArchiMate, ADRs, tech radar |
| `voxflow-operations` | operator | kimi-k2.6:cloud | VoxFlow health, QoS compliance, deployment |
| `income-generation` | analyst | kimi-k2.6:cloud | Consulting proposals, job matching, CVs |
| `hermes-mesh` | architect | deepseek-v4-pro:cloud | Multi-agent orchestration fabric |

---

## The VoxFlow Connection

VoxFlow (InfraForesight) is Brett Moore's QoS-aware enterprise CPaaS platform — 9 microservices, multi-cloud (AWS/Azure/GCP), eBPF DSCP marking, FreeSWITCH + Kamailio. It is the primary infrastructure target Hermes AI OS manages.

The `voxflow-operations` skill provides:
- Automated health checks across all 9 services
- QoS compliance verification (DSCP marking, Grafana dashboards)
- Deployment and demo startup (<60 seconds)
- Cross-cloud VPN tunnel health
- Tenant API key rotation monitoring

See [docs/docs/domain-skills/voxflow-operations.md](docs/docs/domain-skills/voxflow-operations.md) for the full operations playbook.

---

## Getting Started

See [docs/docs/getting-started.md](docs/docs/getting-started.md) for the complete setup guide.

### Quick Start

```bash
# Clone the repo
git clone git@github.com:btfmo/hermes-ai-os.git
cd hermes-ai-os

# Validate configuration
pip install yamllint
yamllint config/hermes

# (Future) Run a skill via the hermes CLI
hermes run --skill diagnostics \
  --input '{"system_state":"v2raya crash loop","logs":"port 2017 in use"}'
```

---

## Repository Structure

```
hermes-ai-os/
├── README.md                           ← You are here
├── VISION.md                           ← Master vision & execution plan
├── CLAUDE.md                           ← Guidance for Claude Code agents
├── LICENSE
│
├── config/
│   ├── hermes/
│   │   ├── config.yaml                 ← Model registry + skill routing
│   │   ├── personalities/             ← 7 personality packs
│   │   │   ├── architect.yaml
│   │   │   ├── coder.yaml
│   │   │   ├── analyst.yaml
│   │   │   ├── operator.yaml
│   │   │   ├── researcher.yaml
│   │   │   ├── advisor.yaml
│   │   │   └── tutor.yaml
│   │   └── skills/                    ← 8 skill definitions
│   │       ├── diagnostics.yaml
│   │       ├── remediation.yaml
│   │       ├── codegen.yaml
│   │       ├── planning.yaml
│   │       ├── summarisation.yaml
│   │       ├── enterprise-architecture.yaml
│   │       ├── voxflow-operations.yaml
│   │       └── income-generation.yaml
│   └── profiles/                       ← Execution profiles
│       ├── fast.yaml
│       ├── deep.yaml
│       └── secure.yaml
│
├── docs/                               ← Docusaurus documentation site
│   ├── docusaurus.config.ts
│   ├── sidebars.ts
│   └── docs/
│       ├── index.md
│       ├── getting-started.md
│       ├── architecture/
│       │   ├── overview.md
│       │   ├── models-and-routing.md
│       │   └── policy-layers.md
│       ├── personalities/
│       │   ├── architect.md
│       │   ├── coder.md
│       │   ├── analyst.md
│       │   ├── operator.md
│       │   ├── researcher.md
│       │   ├── advisor.md
│       │   └── tutor.md
│       ├── skills/
│       │   ├── diagnostics.md
│       │   ├── remediation.md
│       │   ├── codegen.md
│       │   ├── planning.md
│       │   └── summarisation.md
│       ├── domain-skills/
│       │   ├── enterprise-architecture.md
│       │   ├── voxflow-operations.md
│       │   └── income-generation.md
│       └── pipelines/
│           ├── overview.md
│           ├── windows-update-repair.md
│           └── ai-os-orchestration.md
│
├── diagrams/
│   ├── mermaid/
│   │   ├── ai-os-overview.mmd
│   │   ├── hermes-routing.mmd
│   │   ├── hermes-full-architecture.mmd
│   │   └── windows-update-repair.mmd
│   └── drawio/
│       ├── ai-os-overview.drawio
│       ├── hermes-routing.drawio
│       └── windows-update-repair.drawio
│
├── tools/
│   ├── modules/
│   │   └── Hermes.Orchestration/
│   │       ├── Hermes.Orchestration.psm1
│   │       └── Hermes.Orchestration.psd1
│   └── skill-packs/
│       └── windows-update-repair/
│           ├── skill.yaml
│           └── prompts/
│               ├── system.md
│               └── examples.md
│
└── .github/workflows/
    └── release.yml
```

---

## Execution Profiles

| Profile | Temperature | Safety | Use Case |
|---------|-------------|--------|----------|
| `fast` | 0.2 | Standard | Quick answers, low latency |
| `deep` | 0.1 | Standard | Complex reasoning, high accuracy |
| `secure` | 0.0 | Strict | Zero-tolerance, deterministic |

---

## Policy Guarantees

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

## About the Author

Hermes AI OS was built by **Brett Moore** (bm/btfmo), an enterprise infrastructure architect specializing in QoS-aware multi-cloud platforms, VoIP/CPaaS systems, and AI-driven operations.

- **VoxFlow**: QoS-aware CPaaS platform (9 microservices, multi-cloud)
- **InfraForesight**: Enterprise infrastructure consulting
- **Focus**: AWS/Azure/GCP, FreeSWITCH, Kamailio, eBPF, Pulumi, Ollama

---

## License

MIT — see [LICENSE](LICENSE).

Built with intention by **bm**.
