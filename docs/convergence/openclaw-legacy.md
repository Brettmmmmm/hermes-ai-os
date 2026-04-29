# OpenClaw Pre-Migration Legacy Workspaces

**Date:** 2026-04-29
**Location:** `/home/brett/.openclaw.pre-migration/`

---

## What Was OpenClaw?

OpenClaw was Brett's AI agent orchestration platform that ran from approximately
February-April 2026 on `claw.btfm.uk` (VPS hostname: vmi3165828). It provided:

- Multi-agent architecture (8 specialized agents)
- WhatsApp delivery channel
- Ollama + NVIDIA NIM model backend
- Gateway with token auth and Tailscale
- Heartbeat-based proactive monitoring
- Self-learning loops (Darwin PR system)
- DREAMS memory subsystem

The system was migrated off OpenClaw in April 2026, and `hermes-ai-os` became
the canonical configuration repo. The live OpenClaw instance is now shut down.

---

## Workspace Map

The `.openclaw.pre-migration/` directory contains a root-level `.git` repo that
tracked the entire ecosystem, plus each workspace had its own independent git
repo. Here's what each workspace was for:

### workspace-jarvis/ -- Central Orchestrator (MAIN)

The "Jarvis" workspace was the central agent that:
- Received all incoming WhatsApp messages
- Routed tasks to specialized sub-agents via `openclaw agent --agent <name>`
- Maintained the AGENTS.md routing table with exact commands
- Managed self-learning loops (Darwin PR, nightly self-assessment, weekly intel)
- Tracked job hunt activity

**Key content:**
- `AGENTS.md` -- The routing brain. Contains exact `openclaw agent` commands
  for research, coding, infra, marketing, jobs, improve, and monitor agents.
  Also has WhatsApp delivery format and Darwin PR loop instructions.
- `job-hunt/` -- Job search intelligence. Full job descriptions, scoring,
  archived sessions
- `research/github-repos/` -- Cloned reference repos: repomix, oh-my-claudecode,
  gstack, autoagent, ai-marketing-skills
- `skills/` -- OnionClaw (web scraping), browser automation
- `open-jarvis-repo/` -- Open Jarvis repository
- `agent-configs/` -- Agent configuration files

**Valuable assets:** AGENTS.md routing logic, job-hunt data
**Status:** ARCHIVE -- most value is in the routing concepts, now conceptually
migrated to hermes-ai-os skill routing.

### workspace-infra/ -- Infrastructure & VoxFlow

Handled all infrastructure: VoxFlow CPaaS platform, Docker, Pulumi, Kubernetes,
VPN mesh, security hardening, monitoring stack.

**Key content:**
- `voxflow/` -- THE CANONICAL VOXFLOW SOURCE. 9 microservices (signaling,
  media, QoS engine, tenant manager, WhatsApp connector, API gateway, analytics,
  billing, webhook dispatcher), Docker configs, Pulumi IaC for AWS/Azure/GCP,
  Kamailio SIP, FreeSWITCH media server, Homer SIP capture, Cilium eBPF QoS.
  This is the most valuable technical asset in the entire legacy ecosystem.
- `voxflow-dashboard/` -- Next.js QoS monitoring dashboard with live MOS chart,
  jitter/loss, SLA tracking, tenant management, alerts.
- `MEMORY.md` -- Complete VoxFlow project status: all 8 infrastructure
  components completed, commit hashes, key file locations.
- `AGENTS.md` -- Infra-specific session startup and principles
- `DREAMS.md` -- Agent dream diary (poetic reflections of overnight monitoring
  heartbeats -- beautiful but not functional)

**Valuable assets:** ALL of voxflow/ and voxflow-dashboard/
**Status:** KEEP voxflow/ as canonical source until explicitly migrated

### workspace-marketing/ -- Signal (Marketing & BD)

InfraForesight marketing and business development agent named "Signal".
Positioned around "Deterministic Quality. Contractual SLA. Any Cloud."

**Key content:**
- `SOUL.md` -- Signal personality: LinkedIn content strategy, BD outreach,
  strict auth gate (POST_APPROVED), InfraForesight positioning
- `infrastructure-foresight/` -- Static marketing website: sales one-pager
  plus 6 thought leadership articles on multi-cloud, AI foresight, ROI,
  resilience, etc.
- `infrastructure-foresight/index.html` -- THE InfraForesight sales one-pager

**Valuable assets:** SOUL.md, the entire infrastructure-foresight/ site
**Status:** KEEP -- marketing site could be deployed standalone

### workspace-monitor/ -- Pulse (Health & Observability)

System health monitoring agent named "Pulse" with a "clinical NOC engineer"
vibe. Watched gateway, RAM, disk, Docker, cron, Ollama, NVIDIA NIM.

**Key content:**
- `SOUL.md` -- Pulse personality: health checks, thresholds, escalation
  (info/warning/critical), baseline metrics for claw.btfm.uk
- `scripts/pulse-voice-hook.py` -- TTS voice alert generation using edge-tts
  (free Microsoft cloud TTS, no API key). Generates spoken alerts for
  critical issues and can deliver via WhatsApp.
- `memory/2026-04-17-connectivity-test.md` -- Connectivity test results

**Valuable assets:** SOUL.md (excellent agent personality design),
pulse-voice-hook.py (reusable utility)
**Status:** KEEP -- personality conceptually migrated to Hermes

### workspace-research/ -- Jarvis-Research

Deep research and analysis agent. Curiosity-driven, citation-focused.

**Key content:**
- `SOUL.md` -- Research personality: deep dives, synthesis, "clarity over volume"
- `FREESWITCH_OPTIMIZATION.md` -- FreeSWITCH performance optimization research
- `INTEGRATION_TESTING_STRATEGY.md` -- VoxFlow integration testing approach
- `todo.md`, `TASK.md` -- Active research tracking

**Valuable assets:** SOUL.md, FreeSWITCH and integration testing docs
**Status:** KEEP -- research docs are VoxFlow-relevant

### workspace-jobs/ -- Scout (Job Search)

Job search intelligence agent named "Scout" targeting UK Enterprise Architect
contract and fractional roles. Scored against Brett's criteria matrix.

**Key content:**
- `SOUL.md` -- Scout personality: search strategy (Reed, CWJobs, Adzuna,
  Indeed, LinkedIn), scoring template, CV-shadow-matcher skill, auth gate
  (APPROVED: [Role]), rate targets (£750-1200/day)

**Valuable assets:** SOUL.md (excellent specialized agent personality)
**Status:** KEEP -- conceptually migrated to hermes-ai-os income-generation tools

### workspace-coding/ -- Jarvis-Coder

Focused coding and development workspace. Built the VoxFlow QoS dashboard.

**Key content:**
- `dashboard/` -- First version of the Next.js QoS dashboard
- `voxflow-dashboard/` -- Updated version with GlobalCallQualityMap,
  additional components
- `AGENTS.md` -- Coding agent instructions
- `.env.local.example` -- Environment templates

**Valuable assets:** Both dashboard versions (verify which is canonical)
**Status:** KEEP -- duplicates workspace-infra/voxflow-dashboard

### workspace-improve/ -- Darwin (Self-Improvement)

Self-improvement and optimization agent that ran Darwin PR loops, self-assessment
cron jobs, and weekly intelligence gathering.

**Key content:**
- `SOUL.md` -- Darwin personality (to verify)
- `heartbeat.log` -- Heartbeat execution history
- `cron.log` -- Cron job execution history
- Long history of daily memory files dating to 2026-04-08

**Valuable assets:** SOUL.md concept, execution logs for debugging
**Status:** ARCHIVE

### workspace-tickets/ -- Ticket Management

Ticket tracking workspace. Minimal content beyond the standard template files.

**Key content:**
- `SOUL.md` -- Ticket agent personality
- Standard template files (AGENTS.md, MEMORY.md, HEARTBEAT.md, etc.)
- Daily memory files

**Valuable assets:** Minimal -- standard templates plus session logs
**Status:** ARCHIVE

---

## What's Been Migrated to Hermes

| OpenClaw Concept | Hermes Equivalent |
|---|---|
| Agent personalities (SOUL.md) | `config/hermes/personalities/*.yaml` |
| Agent routing logic | Skill routing in `config/hermes/config.yaml` |
| Marketing content strategy | `tools/income-generation/linkedin-content.md` |
| Job search/scoring | `tools/income-generation/job-matching-matrix.yaml` |
| EA practice tools | `tools/enterprise-architecture/` |
| VoxFlow operations | `tools/voxflow-automation/` |
| Model registry | `config/hermes/config.yaml` model section |

---

## What Remains Valuable (Not Yet Migrated)

### HIGH VALUE -- Should be migrated ASAP

1. **InfraForesight sales one-pager**
   - `workspace-marketing/infrastructure-foresight/index.html`
   - Brett's primary BD asset for InfraForesight Ltd

2. **VoxFlow source**
   - `workspace-infra/voxflow/` (entire directory)
   - 9 microservices, Docker, Pulumi, SIP/WebRTC infrastructure

3. **VoxFlow dashboard**
   - `workspace-infra/voxflow-dashboard/`
   - Next.js QoS monitoring dashboard

### MEDIUM VALUE -- Nice to have

4. **Pulse voice hook**
   - `workspace-monitor/scripts/pulse-voice-hook.py`
   - Reusable TTS utility, no API key needed

5. **WireGuard monitors**
   - `scripts/wg-monitor.sh` and `scripts/wg-monitor-simple.sh`
   - Client traffic monitoring scripts

6. **Agent personality definitions (SOUL.md files)**
   - Signal (marketing), Pulse (monitor), Scout (jobs), Jarvis-Research
   - These are well-crafted and could inform future Hermes personalities

### LOW VALUE -- Reference only

7. **Copilot chat logs** -- Historical AI interaction records
8. **DREAMS.md files** -- Poetic but not functional
9. **Daily memory files** -- Session logs from February-April 2026
10. **Cloned reference repos** -- ai-marketing-skills, repomix, etc.

---

## What's Dead Code

- All of `copilot-hermes/hermes-os/` -- see ARCHIVE.md
- Unfilled template files (IDENTITY.md, BOOTSTRAP.md in each workspace)
- Duplicate dashboards (workspace-coding vs workspace-infra)

---

## Preservation Strategy

1. **Document everything** (DONE -- this file)
2. **Extract high-value assets** to hermes-ai-os or standalone repos
3. **Keep `.openclaw.pre-migration/` around** as read-only archive
4. **Eventually archive to cold storage** (tar.gz to backup location)
