# Enterprise Architecture Tools

Production-quality enterprise architecture assets for consulting, architecture governance, and platform design. These tools embody 30 years of enterprise infrastructure and architecture experience, adapted for AI-augmented delivery via Hermes AI OS.

**Author:** Brett Moore, Principal Enterprise Architect, InfraForesight
**Version:** 2026-Q2
**Scope:** Multi-cloud, QoS-aware CPaaS platforms (VoxFlow), enterprise architecture consulting

---

## Tool Index

### 1. ADR Template (`adr-template.md`)
**Purpose:** Full Architecture Decision Record framework with usage instructions and a complete worked example.

**What's included:**
- Complete ADR structure: Status, Context, Decision, Alternatives Considered (table format), Consequences (positive/negative), Compliance and Validation, References
- Decision maturity lifecycle (Proposed → Accepted → Deprecated → Superseded)
- Usage instructions: when to write an ADR, naming conventions, storage
- **Worked example:** ADR-001: Adopt Kubernetes as Container Orchestration Platform — a production-quality reference ADR covering the VoxFlow K8s adoption decision with five alternatives analysed and full consequences documented

**Use for:** Technology selection governance, architecture review boards, consulting deliverables, client-facing decision documentation.

---

### 2. Technology Radar (`technology-radar.md`)
**Purpose:** Framework for classifying and governing the technology portfolio across four adoption rings.

**What's included:**
- Four-ring model definitions: Adopt, Trial, Assess, Hold — with precise criteria for each ring
- Governance process: how technologies move between rings, who decides, review cadence
- **Worked example:** Infrastructure domain radar with 18 technologies placed across all four rings
  - Adopt: Docker, Kubernetes, Terraform, Cilium, Prometheus+Grafana
  - Trial: Cilium eBPF Advanced, TimescaleDB, Flux CD, SPIFFE/SPIRE
  - Assess: CRDTs, WebAssembly on K8s, OpenTelemetry, Kamailio v6.0
  - Hold: FTP/FTPS, Docker Swarm, Calico, CentOS, SNMPv2
- Summary matrix and trend indicators
- Usage guide for teams and architecture review

**Use for:** Technology governance, quarterly portfolio reviews, new project technology selection, risk management, client technology strategy.

---

### 3. Capability Map (`capability-map.yaml`)
**Purpose:** Capability-based planning template for the Cloud Infrastructure domain, with maturity assessment.

**What's included:**
- YAML-structured capability taxonomy with 4 domains and 12 sub-capabilities:
  - Compute (Container Orchestration, Serverless Execution, VM Management)
  - Network (QoS Enforcement, Cross-Cloud Connectivity, Load Balancing, Service Mesh)
  - Storage (Block & File Storage, Object Storage, Data Protection)
  - Security (Identity & Access, Network Security, Secrets Management, Compliance)
- Four-level maturity model: Initial → Managed → Defined → Optimised
- Current and target maturity levels per capability
- Evidence and recommendations per capability
- Gap analysis and prioritised improvement roadmap
- Summary statistics (average maturity 2.51, distribution, priority gaps)

**Use for:** Capability-based planning, maturity assessments, gap analysis, investment prioritisation, client capability audits.

---

### 4. TOGAF ADM Mapping (`togaf-adm-mapping.md`)
**Purpose:** Map every TOGAF ADM phase (Preliminary through H) to specific Hermes AI OS personalities, skills, domain skills, and tools.

**What's included:**
- Phase-by-phase mapping table with:
  - Which Hermes personality to use (architect, analyst, coder, operator, advisor, researcher)
  - Which Hermes skills to invoke (planning, codegen, diagnostics, summarisation, remediation)
  - Which domain skills are relevant (enterprise-architecture, voxflow-operations, income-generation, hermes-mesh)
  - Which EA tools from this directory apply
  - Example prompts demonstrating AI-augmented ADM phase execution
- Cross-cutting capabilities (profiles, config, PowerShell module, pipeline concept)
- Recommended workflows by engagement type (greenfield, technology selection, architecture review, capability assessment)

**Use for:** AI-augmented TOGAF delivery, consulting engagement planning, Hermes AI OS capability demonstration to clients.

---

### 5. Cloud Patterns (`cloud-patterns.md`)
**Purpose:** Catalogue of five battle-tested cloud architecture patterns developed through InfraForesight/VoxFlow engagements.

**What's included:** Each pattern with Problem, Solution, ASCII Diagram, When to Use, When NOT to Use:

1. **Multi-Cloud QoS Federation** — Unified DSCP-based QoS fabric across AWS/Azure/GCP using eBPF and federation gateways
2. **eBPF Traffic Engineering** — Kernel-level traffic classification, bandwidth management, and load balancing via eBPF TC/XDP programs
3. **Cross-Cloud VPN Mesh** — Full-mesh WireGuard overlay with BGP routing for low-latency, QoS-preserving inter-cloud connectivity
4. **Hybrid SIP/VoIP Architecture** — Tiered SIP fabric bridging cloud-native Kamailio/FreeSWITCH with on-premises legacy SBCs and PBX systems
5. **Observability Fabric** — Unified telemetry pipeline (OpenTelemetry + TimescaleDB + Grafana) for cross-cloud, per-session observability

- Pattern selection guide matrix
- All patterns reference the six-class DSCP model (EF/46, AF41/34, CS3/24, AF21/18, AF31/26, BE/0)

**Use for:** Solution architecture, consulting proposals, pattern-based design, client education, pre-sales technical collateral.

---

### 6. ArchiMate Viewpoint Guide (`archimate-viewpoint-guide.md`)
**Purpose:** Quick reference for selecting and applying ArchiMate viewpoints to specific stakeholder questions.

**What's included:**
- Viewpoint selection flow (question → viewpoint)
- Four detailed viewpoints with stakeholder, concepts, when to use, examples, and anti-patterns:
  1. **Layered Viewpoint** — "What is the big picture?" (VoxFlow CPaaS example, all three layers)
  2. **Capability Map Viewpoint** — "What capabilities do we have?" (Cloud Infrastructure maturity map example)
  3. **Technology Usage Viewpoint** — "What depends on CentOS 7?" (Dependency analysis with blast radius)
  4. **Migration Viewpoint** — "How do we migrate from Calico to Cilium?" (Three-plateau migration plan)
- Brief reference for Organisation, Application Cooperation, and Goal Realisation viewpoints
- Quick reference card mapping needs to viewpoints
- ArchiMate 3.2 compliant

**Use for:** Architecture modelling sessions, stakeholder communication, architecture review preparation, consulting methodology.

---

### 7. README.md (this file)
**Purpose:** Index and navigation for the Enterprise Architecture tool suite.

---

## How to Use This Toolkit

### For Consulting Engagements
1. Start with `togaf-adm-mapping.md` to plan the engagement structure and identify which Hermes capabilities to invoke
2. Use `capability-map.yaml` for current-state maturity assessments
3. Use `technology-radar.md` to govern technology choices with the client
4. Use `adr-template.md` to document key decisions as they are made
5. Use `cloud-patterns.md` to propose proven solutions to client problems
6. Use `archimate-viewpoint-guide.md` to select the right communication format for each stakeholder

### For Internal Use (InfraForesight / VoxFlow)
1. Review `technology-radar.md` quarterly to keep the portfolio current
2. Update `capability-map.yaml` as capabilities evolve — track maturity progression
3. Write an ADR for every significant technology or architectural decision
4. Reference `cloud-patterns.md` when designing new platform features
5. Use `archimate-viewpoint-guide.md` for architecture review board presentations

### With Hermes AI OS
All these tools are designed to be referenced by Hermes personalities (especially `architect`) and the `enterprise-architecture` domain skill. The AI can:
- Generate ADRs from a decision description
- Update the technology radar based on new intelligence
- Assess capability maturity from operational data
- Generate ArchiMate viewpoints from architecture descriptions
- Apply cloud patterns to specific client requirements

---

## Directory Structure

```
tools/enterprise-architecture/
├── README.md                     ← This file
├── adr-template.md               ← ADR template with worked example
├── technology-radar.md           ← Four-ring radar framework with example
├── capability-map.yaml           ← Cloud Infrastructure capability assessment
├── togar-adm-mapping.md          ← TOGAF phases → Hermes AI OS capabilities
├── cloud-patterns.md             ← Five QoS-centric cloud patterns
└── archimate-viewpoint-guide.md  ← ArchiMate viewpoint quick reference
```

---

*Maintained by: Enterprise Architecture Function, InfraForesight*
*Contact: Brett Moore, Principal Enterprise Architect*
