# Asset Inventory -- Complete File-Level Manifest

**Date:** 2026-04-29
**Purpose:** Every significant file across all workspaces, classified by disposition.

Disposition codes:
- **KEEP** — Valuable, should be preserved/migrated
- **HERMES-OS** — Already has canonical version in hermes-ai-os
- **ARCHIVE** — Worth keeping for historical reference but not active
- **OBSOLETE** — Dead code, empty templates, or AI-generated stubs with no value

Excluded: node_modules/, .git/ internals, __pycache__, *.pyc, .next/ build artifacts

---

## /home/brett/copilot-hermes/

### hermes-os/ (ALL OBSOLETE)

Every Python, Rust, TypeScript, and YAML file in this tree is a Copilot-generated
placeholder stub. Verification: `HermesRuntime` = `class HermesRuntime: pass`,
`EventBus` = `class EventBus: pass`, etc.

| File | Purpose | Disposition |
|---|---|---|
| `hermes-os/runtime/hermes_runtime/runtime.py` | Placeholder: HermesRuntime class | OBSOLETE |
| `hermes-os/runtime/hermes_runtime/bus.py` | Placeholder: EventBus class | OBSOLETE |
| `hermes-os/runtime/hermes_runtime/queue.py` | Placeholder: queue stub | OBSOLETE |
| `hermes-os/runtime/hermes_runtime/mesh/mesh.py` | Placeholder: mesh stub | OBSOLETE |
| `hermes-os/runtime/hermes_runtime/mesh/crdt.py` | Placeholder: CRDT stub | OBSOLETE |
| `hermes-os/runtime/hermes_runtime/mesh/quic_transport.py` | Placeholder: QUIC stub | OBSOLETE |
| `hermes-os/runtime/hermes_runtime/mesh/security.py` | Placeholder: security stub | OBSOLETE |
| `hermes-os/runtime/main.py` | Placeholder: runtime entry point | OBSOLETE |
| `hermes-os/hermesctl/src/main.rs` | Placeholder: Rust CLI skeleton | OBSOLETE |
| `hermes-os/mesh-dashboard/src/main.tsx` | Placeholder: React dashboard stub | OBSOLETE |
| `hermes-os/web-dashboard/src/main.tsx` | Placeholder: React web dashboard stub | OBSOLETE |
| `hermes-os/marketplace/main.py` | Placeholder: marketplace stub | OBSOLETE |
| `hermes-os/config/hermes-mesh.yml` | Placeholder: mesh config | OBSOLETE |
| `hermes-os/docker-compose.yml` | Placeholder: compose skeleton | OBSOLETE |
| `hermes-os/Makefile` | Empty build targets | OBSOLETE |
| `hermes-os/tests/runtime/test_event_bus.py` | Test skeleton | OBSOLETE |
| `hermes-os/.github/workflows/ci.yml` | CI skeleton | OBSOLETE |
| `hermes-os/spec/hermes_os_v1.tex` | Empty spec document | OBSOLETE |
| `hermes-os/docs/intro.md` | Doc placeholder | OBSOLETE |
| `hermes-os/docs/architecture/overview.md` | Doc placeholder | OBSOLETE |
| `hermes-os/docs/architecture/event-model.md` | Doc placeholder | OBSOLETE |
| `hermes-os/docs/cli/hermesctl.md` | Doc placeholder | OBSOLETE |
| `hermes-os/docs/runtime-api/http.md` | Doc placeholder | OBSOLETE |
| `hermes-os/docs/plugins/manifest.md` | Doc placeholder | OBSOLETE |

### copilot-hermes/ root -- historical artifacts

| File | Purpose | Disposition |
|---|---|---|
| `gemini-code-1777210356993.sh` | Gemini Code CLI script fragment | ARCHIVE |
| `gemini-code-1777210365539.sh` | Gemini Code CLI script fragment | ARCHIVE |
| `gemini-code-1777210371268.sh` | Gemini Code CLI script fragment | ARCHIVE |
| `gemini-code-1777210377446.sh` | Gemini Code CLI script fragment | ARCHIVE |
| `gemini-code-1777210384026.sh` | Gemini Code CLI script fragment | ARCHIVE |
| `gemini-code-1777210393902.md` | Gemini Code markdown output | ARCHIVE |
| `gemini-code-1777210399283.yaml` | Gemini Code YAML output | ARCHIVE |
| `Microsoft Copilot... (4_25_2026 4:56:34 AM).u.zip.html` | Copilot chat export (zipped) | ARCHIVE |
| `Microsoft Copilot... (4_25_2026 4:53:20 AM).html` | Copilot chat export | ARCHIVE |

---

## /home/brett/.openclaw.pre-migration/

### Root-level files

| File | Purpose | Disposition |
|---|---|---|
| `openclaw.json` | OpenClaw gateway config -- model registry, gateway auth, plugins, WhatsApp channel | ARCHIVE (has partial API tokens, do NOT commit) |
| `scripts/wg-monitor.sh` | WireGuard client monitor -- DNS + TCP/UDP tracking for iOS/Android/Windows clients | KEEP |
| `scripts/wg-monitor-simple.sh` | Simplified WireGuard client monitor (DNS + headers only, iOS/Android) | KEEP |

### workspace-infra/

| File | Purpose | Disposition |
|---|---|---|
| `AGENTS.md` | Infra agent instructions -- session startup, memory, principles | ARCHIVE |
| `MEMORY.md` | VoxFlow project context -- all 8 infra components completed, Kamailio, FreeSWITCH, Homer, Cilium, VPN, etc. | KEEP (valuable project status) |
| `HEARTBEAT.md` | VoxFlow sprint tasks -- 4 priorities: Docker images, Grafana dashboards, staging deploy, VPN status | ARCHIVE |
| `IDENTITY.md` | Template (unfilled) -- name, creature, vibe, emoji | OBSOLETE |
| `voxflow/` (entire directory) | VoxFlow CPaaS source -- 9 microservices, Docker configs, Pulumi IaC, SIP/WebRTC infrastructure. THE canonical VoxFlow source. | KEEP |
| `voxflow/infrastructure/aws/Pulumi.yaml` | AWS Pulumi project | KEEP |
| `voxflow/infrastructure/azure/Pulumi.yaml` | Azure Pulumi project | KEEP |
| `voxflow/infrastructure/gcp/Pulumi.yaml` | GCP Pulumi project | KEEP |
| `voxflow/scripts/demo.sh` | VoxFlow demo startup script | KEEP |
| `voxflow/scripts/docker-build.sh` | Docker image build script | KEEP |
| `voxflow/docker-compose.demo.yml` | Demo compose with pre-built images | KEEP |
| `voxflow/memory/2026-04-17.md` | Infra agent session log | ARCHIVE |
| `voxflow-dashboard/` (entire directory) | Next.js QoS monitoring dashboard -- MOS charts, jitter/loss, SLA, alerts, tenant management | KEEP |
| `voxflow-dashboard/DREAMS.md` | Agent dream diary -- poetic reflections of overnight heartbeats | ARCHIVE (beautiful but not functional) |
| `voxflow-dashboard/HEARTBEAT.md` | Dashboard sprint tasks | ARCHIVE |
| `voxflow-dashboard/USER.md` | User profile (Brett Moore) | ARCHIVE |
| `voxflow-dashboard/memory/` | Daily session logs (2026-04-08 through 2026-04-16) | ARCHIVE |
| `voxflow-dashboard/memory/.dreams/` | DREAMS memory subsystem -- session corpus, events, signals | ARCHIVE |

### workspace-marketing/

| File | Purpose | Disposition |
|---|---|---|
| `SOUL.md` | Signal agent personality -- InfraForesight marketing/BD, LinkedIn content, brand positioning | KEEP (excellent agent personality) |
| `AGENTS.md` | Generic workspace template (standard OpenClaw template) | ARCHIVE |
| `MEMORY.md` | Marketing agent long-term memory | ARCHIVE |
| `HEARTBEAT.md` | Marketing heartbeat tasks | ARCHIVE |
| `IDENTITY.md` | Template (unfilled) | OBSOLETE |
| `BOOTSTRAP.md` | First-run bootstrap | ARCHIVE |
| `TOOLS.md` | Tool notes | ARCHIVE |
| `USER.md` | User profile | ARCHIVE |
| `DREAMS.md` | Dream diary (marketing agent dreams) | ARCHIVE |
| `infrastructure-foresight/` | InfraForesight static marketing site | KEEP |
| `infrastructure-foresight/index.html` | InfraForesight sales one-pager -- THE high-value marketing asset | KEEP -- HIGH VALUE |
| `infrastructure-foresight/public/index.html` | Public landing page | KEEP |
| `infrastructure-foresight/public/insights/beyond-the-hype-cycle.html` | Thought leadership article | KEEP |
| `infrastructure-foresight/public/insights/ai-crystal-ball.html` | Thought leadership article | KEEP |
| `infrastructure-foresight/public/insights/multi-cloud-by-design.html` | Thought leadership article | KEEP |
| `infrastructure-foresight/public/insights/what-if-imperative.html` | Thought leadership article | KEEP |
| `infrastructure-foresight/public/insights/resilient-infrastructure-blueprint.html` | Thought leadership article | KEEP |
| `infrastructure-foresight/public/insights/roi-of-foresight.html` | Thought leadership article | KEEP |

### workspace-monitor/

| File | Purpose | Disposition |
|---|---|---|
| `SOUL.md` | Pulse agent personality -- health/observability, clinical NOC engineer vibe, WhatsApp alerting | KEEP (excellent agent personality) |
| `AGENTS.md` | Generic workspace template | ARCHIVE |
| `MEMORY.md` | Monitor agent long-term memory -- baseline metrics, alert history | ARCHIVE |
| `HEARTBEAT.md` | Monitor heartbeat tasks | ARCHIVE |
| `IDENTITY.md` | Template (unfilled) | OBSOLETE |
| `BOOTSTRAP.md` | First-run bootstrap | ARCHIVE |
| `TOOLS.md` | Tool notes | ARCHIVE |
| `USER.md` | User profile | ARCHIVE |
| `DREAMS.md` | Dream diary (monitor agent dreams) | ARCHIVE |
| `scripts/pulse-voice-hook.py` | TTS voice alert generation using edge-tts (free Microsoft cloud TTS, no API key needed) | KEEP -- useful utility |
| `memory/2026-04-17-connectivity-test.md` | Connectivity test results | ARCHIVE |

### workspace-research/

| File | Purpose | Disposition |
|---|---|---|
| `SOUL.md` | Jarvis-Research agent personality -- deep dives, synthesis, curiosity-driven | KEEP |
| `AGENTS.md` | Research agent instructions | ARCHIVE |
| `MEMORY.md` | Research agent long-term memory | ARCHIVE |
| `HEARTBEAT.md` | Research heartbeat tasks | ARCHIVE |
| `IDENTITY.md` | Template (unfilled) | OBSOLETE |
| `TOOLS.md` | Tool notes | ARCHIVE |
| `USER.md` | User profile | ARCHIVE |
| `DREAMS.md` | Dream diary | ARCHIVE |
| `TASK.md` | Active research task | ARCHIVE |
| `todo.md` | Research todo list | ARCHIVE |
| `FREESWITCH_OPTIMIZATION.md` | FreeSWITCH performance optimization research | KEEP (VoxFlow-relevant) |
| `INTEGRATION_TESTING_STRATEGY.md` | VoxFlow integration testing strategy | KEEP |
| `.gitignore` | Gitignore for research workspace | ARCHIVE |

### workspace-jobs/

| File | Purpose | Disposition |
|---|---|---|
| `SOUL.md` | Scout agent personality -- job search intelligence, UK EA contract roles, scoring matrix, CV matcher | KEEP (excellent agent personality) |
| `AGENTS.md` | Generic workspace template | ARCHIVE |
| `MEMORY.md` | Jobs agent long-term memory | ARCHIVE |
| `HEARTBEAT.md` | Jobs heartbeat tasks | ARCHIVE |
| `IDENTITY.md` | Template (unfilled) | OBSOLETE |
| `BOOTSTRAP.md` | First-run bootstrap | ARCHIVE |
| `TOOLS.md` | Tool notes | ARCHIVE |
| `USER.md` | User profile | ARCHIVE |
| `DREAMS.md` | Dream diary | ARCHIVE |

### workspace-coding/

| File | Purpose | Disposition |
|---|---|---|
| `AGENTS.md` | Coding agent instructions -- session startup, principles | ARCHIVE |
| `MEMORY.md` | Coding agent long-term memory | ARCHIVE |
| `HEARTBEAT.md` | Coding heartbeat tasks | ARCHIVE |
| `IDENTITY.md` | Template (unfilled) | OBSOLETE |
| `TOOLS.md` | Tool notes | ARCHIVE |
| `USER.md` | User profile | ARCHIVE |
| `DREAMS.md` | Dream diary | ARCHIVE |
| `dashboard/` | Next.js QoS dashboard (first version) | KEEP (verify against voxflow-dashboard) |
| `voxflow-dashboard/` | Next.js QoS dashboard (updated version) | KEEP |
| `dashboard/.env.local.example` | Dashboard env template | KEEP |
| `voxflow-dashboard/.env.local.example` | Dashboard env template | KEEP |
| `dashboard/src/components/LiveMosChart.tsx` | Live MOS score chart component | KEEP |
| `dashboard/src/components/RealtimeBridge.tsx` | WebSocket realtime bridge | KEEP |
| `dashboard/src/app/qos/page.tsx` | QoS page | KEEP |
| `dashboard/src/app/sla/page.tsx` | SLA page | KEEP |
| `dashboard/src/app/tenants/page.tsx` | Tenant management page | KEEP |
| `dashboard/src/app/alerts/page.tsx` | Alerts page | KEEP |
| `dashboard/src/app/api/qos/route.ts` | QoS API route | KEEP |
| `dashboard/src/app/api/tenants/route.ts` | Tenant API route | KEEP |
| `dashboard/src/app/api/sla/route.ts` | SLA API route | KEEP |
| `dashboard/src/app/api/alerts/route.ts` | Alerts API route | KEEP |
| `dashboard/src/lib/mock-data.ts` | Mock data for development | KEEP |
| `dashboard/src/lib/realtime-store.tsx` | Realtime state store | KEEP |
| `dashboard/package.json` | NPM dependencies | KEEP |
| `dashboard/tsconfig.json` | TypeScript config | KEEP |
| `dashboard/next.config.ts` | Next.js config | KEEP |

### workspace-jarvis/

| File | Purpose | Disposition |
|---|---|---|
| `AGENTS.md` | Main Jarvis agent -- routing instructions, self-learning loops, Darwin PR loop, cron jobs, WhatsApp delivery | KEEP (has useful routing commands) |
| `job-hunt/job-descriptions-full-2026-04-17.md` | Full job descriptions from scan | ARCHIVE |
| `job-hunt/jobs-to-review.md` | Jobs pending review | ARCHIVE |
| `job-hunt/scan-results-2026-04-17.json` | Job scan results JSON | ARCHIVE |
| `job-hunt/archive/2026-04-17/index.md` | Archived job hunt session | ARCHIVE |
| `job-hunt/archive/2026-04-17/outsideir35-ea-ma.md` | Outside IR35 EA role | ARCHIVE |
| `job-hunt/archive/2026-04-17/socode-enterprise-architect-voip.md` | SoCode EA VoIP role | ARCHIVE |
| `skills/browser-automation/` | Browser automation skill (Node.js) | ARCHIVE |
| `skills/onionclaw/` | OnionClaw web scraping skill (Python, BS4, requests) | ARCHIVE |
| `research/github-repos/repomix/` | Cloned reference: repomix | ARCHIVE |
| `research/github-repos/oh-my-claudecode/` | Cloned reference: oh-my-claudecode | ARCHIVE |
| `research/github-repos/gstack/` | Cloned reference: gstack | ARCHIVE |
| `research/github-repos/autoagent/` | Cloned reference: autoagent | ARCHIVE |
| `research/github-repos/ai-marketing-skills/` | Cloned reference: AI marketing skills (podcast ops, sales pipeline, telemetry, conversion ops) | ARCHIVE (valuable reference) |
| `open-jarvis-repo/` | Open Jarvis repository clone | ARCHIVE |
| `agent-configs/` | Agent configurations | ARCHIVE |

### workspace-tickets/

| File | Purpose | Disposition |
|---|---|---|
| `SOUL.md` | Ticket agent personality | ARCHIVE |
| `AGENTS.md` | Generic workspace template | ARCHIVE |
| `MEMORY.md` | Ticket agent memory | ARCHIVE |
| `HEARTBEAT.md` | Ticket heartbeat tasks | ARCHIVE |
| `IDENTITY.md` | Template (unfilled) | OBSOLETE |
| `BOOTSTRAP.md` | First-run bootstrap | ARCHIVE |
| `TOOLS.md` | Tool notes | ARCHIVE |
| `USER.md` | User profile | ARCHIVE |
| `DREAMS.md` | Dream diary | ARCHIVE |

### workspace-improve/

| File | Purpose | Disposition |
|---|---|---|
| `SOUL.md` | Darwin/improve agent personality -- self-improvement, PR loops, code review | KEEP |
| `AGENTS.md` | Generic workspace template | ARCHIVE |
| `MEMORY.md` | Improve agent memory | ARCHIVE |
| `HEARTBEAT.md` | Improve heartbeat tasks | ARCHIVE |
| `IDENTITY.md` | Template (unfilled) | OBSOLETE |
| `BOOTSTRAP.md` | First-run bootstrap | ARCHIVE |
| `TOOLS.md` | Tool notes | ARCHIVE |
| `USER.md` | User profile | ARCHIVE |
| `DREAMS.md` | Dream diary | ARCHIVE |
| `heartbeat.log` | Heartbeat execution log | ARCHIVE |
| `cron.log` | Cron job execution log | ARCHIVE |

### skills/ (global skill directory)

| File | Purpose | Disposition |
|---|---|---|
| `skills/self-improving-agent/` | Self-improving agent skill definition | ARCHIVE |
| `skills/onionclaw/` | OnionClaw web scraping skill definition | ARCHIVE |

---

## /home/brett/hermes-ai-os/

This is the canonical repo and is actively maintained. All files here are under
version control and tracked in git. Notable directories:

| Directory | Purpose |
|---|---|
| `config/hermes/` | Personalities, skills, profiles -- the core AI orchestration |
| `config/hermes/personalities/` | 7 defined AI personalities |
| `config/hermes/skills/` | 8 defined skills + 4 domain skills |
| `config/profiles/` | Execution profiles (fast/deep/secure) |
| `docs/` | Docusaurus documentation site |
| `docs/convergence/` | THIS DIRECTORY |
| `diagrams/mermaid/` | Mermaid text diagrams |
| `diagrams/drawio/` | Draw.io XML diagrams |
| `tools/modules/` | PowerShell module (Hermes.Orchestration) |
| `tools/skill-packs/` | Reusable skill bundles |
| `tools/enterprise-architecture/` | EA domain tools (TOGAF, ArchiMate, ADRs) |
| `tools/income-generation/` | Income tools (job matching, CVs, proposals) |
| `tools/voxflow-automation/` | VoxFlow operational automation scripts |
| `VISION.md` | Master execution plan and phase roadmap |
| `CLAUDE.md` | Repo guide for Claude/AI assistants |

---

## /home/brett/.hermes/

LIVE RUNTIME -- DO NOT TOUCH, DO NOT COMMIT, DO NOT INVENTORY.

Contains private API keys, running agent state, runtime configuration.
Not included in this inventory for security reasons.

---

## Summary Statistics

| Disposition | Count | Notes |
|---|---|---|
| KEEP | ~50+ files | Valuable assets to preserve/migrate |
| HERMES-OS | 0 | Nothing explicitly mapped yet |
| ARCHIVE | ~100+ files | Historical reference, not active |
| OBSOLETE | ~30 files | Dead code, empty templates, stubs |

The copilot-hermes/ directory contains **zero** files worth keeping. Every
single source file in hermes-os/ is a placeholder stub.
