# Hermes AI OS -- Repo Convergence Manifest

**Date:** 2026-04-29
**Status:** IN PROGRESS -- Documenting the path from chaos to clarity

---

## Summary

Brett has accumulated multiple AI-related repositories and workspaces over the past
several months of experimenting with Copilot, OpenClaw, Ollama, and AI agents.
Some are AI-generated stubs (all classes literally say `pass`), some are
production-quality agent configurations, and some are genuine business artifacts
like the VoxFlow CPaaS platform infrastructure and the InfraForesight sales
one-pager.

This document explains what exists, where the canonical versions live, and how
to safely converge on **hermes-ai-os** as the single source of truth.

---

## Current State: Messy (Multiple Competing Visions)

There are four distinct "clusters" of work spread across the filesystem:

### Cluster 1: `/home/brett/hermes-ai-os/` -- THE CANONICAL REPO
- Configuration-driven AI orchestration system
- Personalities, skills, profiles, domain skills, skill packs
- Enterprise Architecture, VoxFlow operations, income generation tools
- Docusaurus documentation site
- No runtime binary -- configuration and orchestration layer only
- ACTIVE AND MAINTAINED

### Cluster 2: `/home/brett/copilot-hermes/` -- Dead Code + Chat Logs
- `hermes-os/`: GitHub Copilot-generated placeholder stubs. Every Python class
  says `class Foo: pass`. Every Rust file is a skeleton. No real functionality.
  **This is entirely dead code.**
- Root directory: Copilot chat export HTML files and gemini-code script
  fragments. Historical artifacts only.

### Cluster 3: `/home/brett/.openclaw.pre-migration/` -- Legacy OpenClaw Ecosystem
- Was Brett's production AI agent system before migrating to Hermes
- 8 specialized agent workspaces (infra, jarvis, marketing, monitor, research,
  tickets, coding, improve, jobs)
- Contains valuable artifacts: VoxFlow source (workspace-infra/voxflow),
  InfraForesight marketing site, agent personalities (SOUL.md files),
  WireGuard monitor scripts, voice hook
- Each workspace has its own `.git` repo, memory system, AGENTS.md

### Cluster 4: `/home/brett/.hermes/` -- LIVE RUNTIME (DO NOT TOUCH)
- The currently running Hermes agent runtime
- Contains private API keys and secrets
- **Excluded from convergence -- this is production**

---

## Target State: Clean (hermes-ai-os is canonical)

```
/home/brett/hermes-ai-os/          ← Single source of truth
  ├── config/hermes/                ← AI personalities, skills, profiles
  ├── docs/convergence/             ← THIS DIRECTORY -- convergence docs
  ├── tools/                        ← Domain tools (EA, VoxFlow, income)
  ├── diagrams/
  └── CLAUDE.md                     ← Repo guide

/home/brett/.openclaw.pre-migration/  ← ARCHIVE (read-only, keep for history)
  ├── workspace-infra/voxflow/      ← VoxFlow canonical source (until migrated)
  ├── workspace-infra/voxflow-dashboard/
  ├── workspace-marketing/infrastructure-foresight/
  ├── workspace-monitor/scripts/
  └── [other workspaces -- archived]

/home/brett/copilot-hermes/         ← ARCHIVE or DELETE (all dead stubs)

/home/brett/.hermes/                ← LIVE RUNTIME -- never committed, never touched
```

---

## Migration Path

### Phase 1: Document (DONE -- this manifest)
- Document everything that exists
- Create asset inventory
- No files deleted, nothing moved

### Phase 2: Archive copilot-hermes
- Read `ARCHIVE.md` in this directory
- Brett can safely `rm -rf /home/brett/copilot-hermes/` when ready
- It's ALL placeholder stubs and chat logs

### Phase 3: Migrate high-value OpenClaw artifacts (future)
- VoxFlow source -> migrate to hermes-ai-os or standalone repo
- InfraForesight marketing site -> migrate to standalone deploy
- Agent personalities -> already conceptually migrated to Hermes config
- WireGuard scripts -> hermes-ai-os/tools/

### Phase 4: Sunset OpenClaw workspace (future)
- Once all valuable content is migrated, archive the entire
  `.openclaw.pre-migration/` directory
- Keep around for historical reference

---

## File Mapping: Old Location -> Canonical Location

### copilot-hermes/ (ALL OBSOLETE)

| Old Location | Canonical | Disposition |
|---|---|---|
| `copilot-hermes/hermes-os/` (everything) | `hermes-ai-os/` | OBSOLETE -- all placeholder stubs |
| `copilot-hermes/hermes-os/runtime/hermes_runtime/runtime.py` | N/A -- was literally `class HermesRuntime: pass` | OBSOLETE |
| `copilot-hermes/hermes-os/runtime/hermes_runtime/bus.py` | N/A -- was literally `class EventBus: pass` | OBSOLETE |
| `copilot-hermes/hermes-os/runtime/hermes_runtime/mesh/*.py` | N/A -- all stubs | OBSOLETE |
| `copilot-hermes/hermes-os/hermesctl/src/main.rs` | N/A -- Rust skeleton | OBSOLETE |
| `copilot-hermes/hermes-os/spec/hermes_os_v1.tex` | N/A -- empty spec doc | OBSOLETE |
| `copilot-hermes/hermes-os/docs/*` | `hermes-ai-os/docs/` | OBSOLETE (placeholder docs) |
| `copilot-hermes/hermes-os/Makefile` | N/A -- empty build targets | OBSOLETE |
| `copilot-hermes/hermes-os/docker-compose.yml` | N/A -- skeleton | OBSOLETE |
| `copilot-hermes/gemini-code-*.{sh,md,yaml}` | N/A -- historical script fragments | ARCHIVE |
| `copilot-hermes/Microsoft Copilot*.html` | N/A -- chat export logs | ARCHIVE |

### .openclaw.pre-migration/workspace-infra/

| Old Location | Canonical | Disposition |
|---|---|---|
| `workspace-infra/voxflow/` (entire dir) | Standalone -- VoxFlow CPaaS source | KEEP (migrate later) |
| `workspace-infra/voxflow-dashboard/` | Standalone | KEEP |
| `workspace-infra/voxflow-dashboard/DREAMS.md` | N/A -- agent dream diary | ARCHIVE (poetic, not functional) |
| `workspace-infra/voxflow-dashboard/HEARTBEAT.md` | N/A -- infra sprint tasks | ARCHIVE |
| `workspace-infra/voxflow/scripts/demo.sh` | VoxFlow source | KEEP |
| `workspace-infra/voxflow/scripts/docker-build.sh` | VoxFlow source | KEEP |
| `workspace-infra/voxflow/docker-compose.demo.yml` | VoxFlow source | KEEP |
| `workspace-infra/AGENTS.md` | N/A -- agent instructions | ARCHIVE |
| `workspace-infra/MEMORY.md` | N/A -- agent memory | ARCHIVE |
| `workspace-infra/IDENTITY.md` | N/A -- template (unfilled) | OBSOLETE |
| `workspace-infra/HEARTBEAT.md` | N/A -- sprint task list | ARCHIVE |

### .openclaw.pre-migration/workspace-marketing/

| Old Location | Canonical | Disposition |
|---|---|---|
| `workspace-marketing/SOUL.md` | `hermes-ai-os/config/hermes/personalities/` (conceptually) | KEEP (Signal agent personality) |
| `workspace-marketing/infrastructure-foresight/` | Standalone marketing site | KEEP |
| `workspace-marketing/infrastructure-foresight/index.html` | InfraForesight sales one-pager | KEEP -- high value |
| `workspace-marketing/infrastructure-foresight/public/insights/*.html` | InfraForesight thought leadership | KEEP |
| `workspace-marketing/AGENTS.md` | N/A -- generic agent template | ARCHIVE |
| `workspace-marketing/MEMORY.md` | N/A | ARCHIVE |
| `workspace-marketing/DREAMS.md` | N/A | ARCHIVE |

### .openclaw.pre-migration/workspace-monitor/

| Old Location | Canonical | Disposition |
|---|---|---|
| `workspace-monitor/SOUL.md` | `hermes-ai-os/config/hermes/personalities/` (conceptually) | KEEP (Pulse agent personality) |
| `workspace-monitor/scripts/pulse-voice-hook.py` | `hermes-ai-os/tools/` | KEEP -- TTS voice alert |
| `workspace-monitor/AGENTS.md` | N/A | ARCHIVE |
| `workspace-monitor/MEMORY.md` | N/A -- baseline metrics | ARCHIVE |
| `workspace-monitor/memory/2026-04-17-connectivity-test.md` | N/A | ARCHIVE |

### .openclaw.pre-migration/workspace-research/

| Old Location | Canonical | Disposition |
|---|---|---|
| `workspace-research/SOUL.md` | `hermes-ai-os/config/hermes/personalities/` (conceptually) | KEEP (Jarvis-Research) |
| `workspace-research/FREESWITCH_OPTIMIZATION.md` | VoxFlow context | KEEP |
| `workspace-research/INTEGRATION_TESTING_STRATEGY.md` | VoxFlow context | KEEP |
| `workspace-research/todo.md` | N/A | ARCHIVE |
| `workspace-research/TASK.md` | N/A | ARCHIVE |

### .openclaw.pre-migration/workspace-jobs/

| Old Location | Canonical | Disposition |
|---|---|---|
| `workspace-jobs/SOUL.md` | `hermes-ai-os/config/hermes/personalities/` (conceptually) | KEEP (Scout agent) |
| `workspace-jobs/AGENTS.md` | N/A | ARCHIVE |
| `workspace-jobs/MEMORY.md` | N/A | ARCHIVE |

### .openclaw.pre-migration/workspace-coding/

| Old Location | Canonical | Disposition |
|---|---|---|
| `workspace-coding/dashboard/` | `workspace-infra/voxflow-dashboard/` | KEEP (Next.js QoS dashboard) |
| `workspace-coding/voxflow-dashboard/` | `workspace-infra/voxflow-dashboard/` | KEEP (duplicate, verify canonical) |

### .openclaw.pre-migration/workspace-jarvis/

| Old Location | Canonical | Disposition |
|---|---|---|
| `workspace-jarvis/AGENTS.md` | N/A -- agent routing instructions | ARCHIVE (has routing commands) |
| `workspace-jarvis/job-hunt/` | `hermes-ai-os/tools/income-generation/` | KEEP |
| `workspace-jarvis/research/github-repos/` | N/A -- cloned reference repos | ARCHIVE |
| `workspace-jarvis/skills/onionclaw/` | N/A -- web scraping skill | ARCHIVE |
| `workspace-jarvis/skills/browser-automation/` | N/A | ARCHIVE |

### .openclaw.pre-migration/ (root)

| Old Location | Canonical | Disposition |
|---|---|---|
| `openclaw.json` | N/A -- OpenClaw config (has tokens) | ARCHIVE (contains partial API keys) |
| `scripts/wg-monitor.sh` | `hermes-ai-os/tools/` | KEEP -- WireGuard monitor |
| `scripts/wg-monitor-simple.sh` | `hermes-ai-os/tools/` | KEEP -- simplified WG monitor |

---

## What NOT To Do

- DO NOT delete or modify `/home/brett/.hermes/` -- it's the live runtime
- DO NOT commit `.hermes/` to the hermes-ai-os repo
- DO NOT delete OpenClaw workspaces without extracting valuable content first
- DO NOT merge copilot-hermes stubs into hermes-ai-os -- they're all `pass`

---

## Related Documents

- `asset-inventory.md` -- Complete file-by-file inventory
- `ARCHIVE.md` -- copilot-hermes archive instructions
- `openclaw-legacy.md` -- OpenClaw pre-migration workspace docs
- `recommended-gitignore.txt` -- .gitignore patterns to add
