# Enterprise Architecture Skill

## Purpose

The `enterprise-architecture` skill provides enterprise-grade architecture analysis, documentation, and decision support. It operates across TOGAF domains (Business, Data, Application, Technology) with ArchiMate viewpoints and structured Architecture Decision Records (ADRs).

## When to Use

- Architecture Decision Records (ADRs)
- Technology radar / portfolio analysis
- Capability-based planning (TOGAF Phase E/F)
- Cloud architecture design (AWS/Azure/GCP)
- Infrastructure pattern selection
- QoS/DSCP architecture design (VoxFlow domain)
- Security architecture assessment
- Gap analysis and migration planning

## Inputs

| Input | Type | Required | Description |
|-------|------|----------|-------------|
| `task` | string | yes | One of: `adr`, `radar`, `capability-planning`, `cloud-design`, `pattern-select`, `security-assess`, `gap-analysis` |
| `title` | string | for `adr` | Title of the architecture decision record |
| `context` | string | yes | Problem statement, domain context, or architecture question |
| `domain` | string | no | TOGAF domain: Business, Data, Application, Technology |
| `scope` | string | no | Specific technology area for radar analysis |
| `constraints` | array | no | Known constraints (budget, timeline, regulation) |

## Outputs

All outputs follow the enforced structure: **Context → Analysis → Decision/Design → Consequences → References**

### ADR Output
- Context (the issue being addressed)
- Analysis of alternatives (pros/cons table)
- Decision with rationale
- Consequences (what becomes easier/harder)
- Cross-references to related ADRs

### Technology Radar Output
- Categorized technology assessment (Adopt / Trial / Assess / Hold)
- Evidence and rationale per technology
- Actionable recommendations

## Policy

- **Personality:** architect
- **Default Model:** ollama:deepseek-v4-pro:cloud
- **Output Format:** markdown
- **Required Structure:** Context → Analysis → Decision/Design → Consequences → References
- ADRs are numbered, dated, and cross-referenced
- All technology recommendations include rationale
- Security implications are always addressed

## Example Usage

```bash
# Generate an Architecture Decision Record
hermes run --skill enterprise-architecture \
  --input '{
    "task": "adr",
    "title": "QoS Policy Federation",
    "context": "Need to propagate DSCP policies across AWS/Azure/GCP with 99.99% SLA compliance",
    "domain": "Technology"
  }'

# Analyze technology choices for the QoS stack
hermes run --skill enterprise-architecture \
  --input '{
    "task": "radar",
    "domain": "infrastructure",
    "scope": "QoS and networking"
  }'

# Capability-based planning for VoxFlow Phase 2
hermes run --skill enterprise-architecture \
  --input '{
    "task": "capability-planning",
    "context": "Extend VoxFlow with WhatsApp Business API and RCS messaging",
    "constraints": ["Must maintain 4x9s SLA", "Must work across AWS/Azure/GCP"]
  }'
```

## TOGAF Mapping

| ADM Phase | Hermes Capability |
|-----------|-------------------|
| Preliminary | Identity + scope definition |
| A. Architecture Vision | VISION.md |
| B. Business Architecture | income-generation skill |
| C. Information Systems | voxflow-operations skill |
| D. Technology Architecture | This skill + infra analysis |
| E. Opportunities & Solutions | Gap analysis |
| F. Migration Planning | Phase plans |
| G. Implementation Governance | Code review + PR oversight |
| H. Architecture Change Management | Memory + session continuity |

## Technology Radar Rings

| Ring | Meaning | Examples |
|------|---------|----------|
| Adopt | Proven, use by default | Docker, Git, PostgreSQL, Pulumi |
| Trial | Worth evaluating | Cilium eBPF, QUIC transport, CRDT state |
| Assess | Promising but early | WebAssembly plugins, AI-driven ops |
| Hold | Avoid or phase out | Unencrypted protocols, shared secrets |
