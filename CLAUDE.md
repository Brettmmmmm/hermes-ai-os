# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hermes AI OS is a configuration-driven, enterprise-grade AI orchestration system. It defines **personalities** (system prompts with assigned models), **skills** (structured task definitions with enforced output policy), **profiles** (temperature/safety presets), **domain skills** (enterprise architecture, VoxFlow operations, income generation, mesh fabric), and **skill packs** (bundled, sandboxed skill bundles with prompt files). There is no runtime binary in this repo — the `hermes` CLI is a future planned component.

**Master Vision:** Read `VISION.md` at the repo root for the full execution plan, phase roadmap, and architectural principles.

## VoxFlow Context

VoxFlow (InfraForesight) is Brett Moore's QoS-aware enterprise CPaaS platform — 9 microservices deployed across AWS/Azure/GCP, using eBPF DSCP marking via Cilium, FreeSWITCH + Kamailio for media and signaling, and TimescaleDB hypertables for analytics. The canonical source lives at `/home/brett/.openclaw.pre-migration/workspace-infra/voxflow`. The `voxflow-operations` skill in this repo provides the operational automation layer.

## Repo Architecture

```
config/hermes/          ← YAML: main config, personalities, skills, profiles
config/profiles/        ← Execution profiles (fast/deep/secure)
docs/                   ← Docusaurus documentation site
diagrams/mermaid/       ← Text-based .mmd diagrams (render anywhere)
diagrams/drawio/        ← Editable Draw.io XML diagrams
tools/modules/          ← PowerShell module (Hermes.Orchestration)
tools/skill-packs/      ← Reusable, signed skill bundles
```

### Domain Model

**Personality** → a system prompt with an assigned default model. Seven defined: `architect`, `coder`, `analyst`, `operator`, `researcher`, `advisor`, `tutor`.

**Skill** → binds a personality + model + output policy (required heading structure). Eight defined: `diagnostics`, `remediation`, `codegen`, `planning`, `summarisation`, `enterprise-architecture`, `voxflow-operations`, `income-generation`.

**Domain Skill** → a skill scoped to a specific business domain. Four defined:
- `enterprise-architecture` — TOGAF, ArchiMate, ADRs, tech radar. Personality: architect. Model: deepseek-v4-pro:cloud.
- `voxflow-operations` — VoxFlow platform ops, QoS compliance, troubleshooting. Personality: operator. Model: kimi-k2.6:cloud.
- `income-generation` — Consulting proposals, job matching, CVs, brand building. Personality: analyst. Model: kimi-k2.6:cloud.
- `hermes-mesh` — Multi-agent orchestration fabric (documented vision). Personality: architect. Model: deepseek-v4-pro:cloud.

**Profile** → overrides temperature/safety settings. Three: `fast` (0.2 temp), `deep` (0.1 temp), `secure` (0.0 temp, strict safety).

**Skill Pack** → standalone directory with `skill.yaml` (inputs, outputs, policy) + prompt templates in `prompts/`. Currently one example: `windows-update-repair`.

**Pipeline** → chains skills in sequence. Documented but not yet codified in YAML config.

**Policy** → each skill enforces a Markdown output structure (e.g., Symptoms → Root Cause → Evidence → Remediation).

### Model Registry (in `config/hermes/config.yaml`)

Available Ollama cloud models:
- `deepseek-v4-pro:cloud` — Flagship reasoning model (temp 0.1, 32K tokens)
- `kimi-k2.6:cloud` — Operational reasoning (temp 0.2, 32K tokens)
- `qwen3.5:cloud` — Fast general-purpose (temp 0.2, 16K tokens)
- `kimi-k2.5:cloud` — Legacy operational fallback (temp 0.2, 4K tokens)
- `deepseek-v3.1:671b-cloud` — Code generation heavyweight (temp 0.1, 32K tokens)
- `glm-5:cloud` — Alternative reasoning (temp 0.2, 16K tokens)
- `minimax-m2.7:cloud` — Alternative reasoning (temp 0.2, 16K tokens)
- `phi3.5:latest` — Lightweight local (temp 0.2, 4K tokens)
- `wizardlm-uncensored:latest` — Creative/unfiltered (temp 0.5, 4K tokens)
- `nomic-embed-text:latest` — Embeddings only (temp 0.0, 512 tokens)

Cloud fallback: `gpt-4.1-mini` via OpenAI (temp 0.3, 4K tokens).

### Routing Logic (in `config/hermes/config.yaml`)

Skills are pinned to specific skill→model mappings under `routing:`. The default model is `ollama:deepseek-v4-pro:cloud`. Model definitions include provider, model name, temperature, and token limits.

## Common Tasks

### Validate YAML config

```bash
pip install yamllint
yamllint config/hermes
yamllint tools/skill-packs
```

### Add a new personality

Create `config/hermes/personalities/<id>.yaml` with `id`, `name`, `description`, `system_prompt`, and `model` fields. Optionally document it in `docs/docs/personalities/<id>.md` and add it to the Docusaurus sidebar in `docs/sidebars.ts`.

### Add a new skill

Create `config/hermes/skills/<id>.yaml` with `id`, `description`, `personality` (must reference an existing personality), `model`, and `policy` (format + structure array). Document in `docs/docs/skills/<id>.md`.

### Add a new domain skill

Create `config/hermes/skills/<id>.yaml` following the same pattern as regular skills but with domain-specific tags and optional `domains` field. Document in `docs/docs/domain-skills/<id>.md` and add to the sidebar.

### Add a new skill pack

Create `tools/skill-packs/<id>/` containing `skill.yaml` (id, personality, model, policy, inputs, outputs) and `prompts/system.md` (the system prompt template).

### CI/CD

Pushing a `v*.*.*` tag triggers validation (yamllint + YAML parsing check), PowerShell module packaging, and GitHub Release creation via `.github/workflows/release.yml`.

## Key Constraints

- Personalities referenced in skills must exist in `config/hermes/personalities/`
- Skill output structures are deterministic — every skill's `policy.structure` is an ordered list of required Markdown headings
- Temperature is set at both the model definition level and can be overridden by profiles
- Skill packs define explicit `inputs` and `outputs` schemas for pipeline chaining
- The `.hermes/` runtime directory must NEVER be committed — it contains private API keys and secrets
