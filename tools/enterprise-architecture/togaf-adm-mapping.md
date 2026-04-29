# TOGAF ADM Phase Mapping to Hermes AI OS

## Overview

This document maps each phase of the TOGAF Architecture Development Method (ADM) to the Hermes AI OS ecosystem — personalities, skills, domain skills, skill packs, and tools. The intent is to show how an enterprise architect can leverage Hermes AI OS as an AI-augmented TOGAF toolchain, accelerating each ADM phase while maintaining architectural rigour.

**TOGAF Version:** TOGAF 10 (backward-compatible with 9.2)
**Hermes Version:** Current (CLAUDE.md baseline)
**Author:** Brett Moore, Principal Enterprise Architect

---

## ADM Phase Mapping

### Preliminary Phase: Architecture Capability

**Purpose:** Establish the architecture practice — principles, governance, tools, and team.

| Hermes Capability | How It Supports This Phase |
|---|---|
| **Personality: `architect`** | System prompt tuned for EA governance, principles definition, and framework selection. Acts as architecture practice advisor. |
| **Skill: `planning`** | Generates architecture capability maturity assessments, team structure recommendations, and tooling roadmaps. |
| **Domain Skill: `enterprise-architecture`** | Core EA domain — provides ADR templates, technology radar, ArchiMate modelling guidance. All tooling assets in this directory support Preliminary phase setup. |
| **Skill: `summarisation`** | Condenses existing architecture documentation, standards, and reference architectures into actionable principles. |
| **Tools:** `adr-template.md` | Establishes the decision governance framework before the first architectural decision. |
| **Tools:** `technology-radar.md` | Defines the technology governance framework — what to Adopt, Trial, Assess, Hold. |
| **Tools:** `capability-map.yaml` | Baseline assessment of current EA capability maturity. |

**Example prompt:**
> "As Hermes architect personality, define a set of 8-12 architecture principles for a multi-cloud CPaaS platform. Each principle must have a name, statement, rationale, and implications. Align with TOGAF 10 recommendations."

**Deliverable:** Architecture Principles document, EA Capability Assessment, Governance Framework.

---

### Phase A: Architecture Vision

**Purpose:** Define scope, stakeholders, business goals, and the high-level architecture vision.

| Hermes Capability | How It Supports This Phase |
|---|---|
| **Personality: `architect`** | Synthesises business strategy into architecture vision statements. Evaluates business scenarios and generates solution concepts. |
| **Personality: `advisor`** | Stakeholder-friendly communication of the vision. Helps prepare executive presentations and board-level summaries. |
| **Skill: `planning`** | Creates architecture vision documents, stakeholder maps, and business capability heat maps. |
| **Domain Skill: `enterprise-architecture`** | Provides structured view of business capabilities vs technical capabilities, identifying gaps. |
| **Domain Skill: `income-generation`** | Quantifies business value of the architecture vision — ROI, TCO, revenue impact modelling for consulting engagements. |
| **Tools:** `capability-map.yaml` | Target-state capability mapping for the vision phase. |

**Example prompt:**
> "As Hermes architect, create an Architecture Vision for a multi-cloud QoS federation platform targeting telecom carriers. Include: business context, stakeholder concerns mapped to architectural responses, high-level solution concept diagram (describe in text for diagram generation), and a capability increment roadmap over 18 months."

**Deliverable:** Architecture Vision Document, Statement of Architecture Work, Business Case.

---

### Phase B: Business Architecture

**Purpose:** Develop the business architecture — processes, capabilities, organisation, and business services.

| Hermes Capability | How It Supports This Phase |
|---|---|
| **Personality: `analyst`** | Analyses business processes, identifies process inefficiencies, and models business capability dependencies. |
| **Skill: `summarisation`** | Extracts business processes from existing documentation, contracts, and SLAs. |
| **Domain Skill: `voxflow-operations`** | Maps VoxFlow business services (CPaaS API, SIP trunking, billing, analytics) to business architecture building blocks. |
| **Tools:** `archimate-viewpoint-guide.md` | Select the appropriate ArchiMate viewpoint for business capability modelling. |
| **Tools:** `capability-map.yaml` | Extend the capability map into business domains beyond infrastructure. |

**Example prompt:**
> "As Hermes analyst personality, model the business architecture for a CPaaS provider offering QoS-assured SIP trunking. Identify: business actors, business services, business processes (order-to-cash, trouble-to-resolution), and map each to the underlying technical capabilities. Use ArchiMate business layer vocabulary."

**Deliverable:** Business Architecture Model, Business Capability Map, Process Catalog, Organisation Model.

---

### Phase C: Information Systems Architecture (Data + Application)

**Purpose:** Develop data architecture and application architecture — logical and physical.

#### C1: Data Architecture

| Hermes Capability | How It Supports This Phase |
|---|---|
| **Personality: `architect`** | Defines data domains, data entities, data flows, and data governance. Evaluates database technologies. |
| **Personality: `analyst`** | Analyses data volumes, velocity, and variety. Models data lifecycle and retention policies. |
| **Skill: `planning`** | Creates data architecture documents, data flow diagrams (text descriptions), and CRUD matrices. |
| **Domain Skill: `voxflow-operations`** | Deep understanding of VoxFlow data: CDRs (TimescaleDB hypertables), session state (Redis), media recordings (S3), billing (PostgreSQL). |

**Example prompt:**
> "As Hermes architect, design the data architecture for VoxFlow analytics. We ingest 2M CDRs/day. Define: logical data model, physical storage selection (TimescaleDB hypertables with chunking strategy), data retention tiers (hot/warm/cold), and GDPR/PII handling for call detail records."

#### C2: Application Architecture

| Hermes Capability | How It Supports This Phase |
|---|---|
| **Personality: `coder`** | Evaluates application frameworks, API designs, and microservice decomposition patterns. |
| **Skill: `codegen`** | Generates API specifications (OpenAPI), microservice scaffolding, and interface definitions. |
| **Domain Skill: `voxflow-operations`** | Detailed knowledge of the 9 VoxFlow microservices, their interfaces, and dependencies. |
| **Tools:** `cloud-patterns.md` | Select architectural patterns for application deployment. |

**Example prompt:**
> "As Hermes coder personality, design the application architecture for a new real-time media routing service in VoxFlow. Requirements: select best media worker based on latency + capacity metrics, publish route updates via Redis pub/sub, and expose gRPC API for the signalling layer. Provide service decomposition rationale, interface contracts, and integration patterns with existing Kamailio and FreeSWITCH components."

**Deliverable:** Data Architecture Model, Application Architecture Model, Interface Catalog, Application/Data Matrix.

---

### Phase D: Technology Architecture

**Purpose:** Develop the technology architecture — infrastructure, platforms, and middleware.

| Hermes Capability | How It Supports This Phase |
|---|---|
| **Personality: `architect`** | Primary personality for technology architecture design. Evaluates platforms, patterns, and infrastructure choices. |
| **Personality: `operator`** | Validates technology choices from operational perspective — operability, monitoring, DR, runbooks. |
| **Skill: `diagnostics`** | Evaluates technology options against non-functional requirements (performance, availability, scalability). |
| **Skill: `remediation`** | Assesses technology resilience — failover scenarios, DR strategies, and recovery procedures. |
| **Domain Skill: `enterprise-architecture`** | Full suite of EA tooling: technology radar, cloud patterns, capability map. |
| **Domain Skill: `voxflow-operations`** | VoxFlow-specific technology choices: Cilium, FreeSWITCH, Kamailio, TimescaleDB, Redis, eBPF. |
| **Tools:** `technology-radar.md` | Place candidate technologies in appropriate rings. |
| **Tools:** `cloud-patterns.md` | Select and document cloud infrastructure patterns. |
| **Tools:** `adr-template.md` | Record technology selection decisions with alternatives analysis. |
| **Tools:** `archimate-viewpoint-guide.md` | Use Technology Usage viewpoint for technology-application mapping. |

**Example prompt:**
> "As Hermes architect, define the technology architecture for VoxFlow's multi-cloud deployment. We operate across AWS, Azure, and GCP. Specify: compute platform (managed K8s), networking (Cilium eBPF with six-class DSCP), storage (cloud CSI + TimescaleDB), security (SPIFFE/SPIRE + External Secrets Operator), and observability (Prometheus + Grafana + Hubble). For each, reference the relevant technology radar ring and create ADRs where multiple options were considered."

**Deliverable:** Technology Architecture Model, Platform Decomposition, Technology Radar Update, ADRs for technology choices.

---

### Phase E: Opportunities and Solutions

**Purpose:** Identify delivery vehicles (projects, programmes), gap analysis, and implementation strategy.

| Hermes Capability | How It Supports This Phase |
|---|---|
| **Personality: `advisor`** | Advises on implementation sequencing, risk-based prioritisation, and build-vs-buy decisions. |
| **Skill: `planning`** | Creates implementation roadmaps, gap analysis matrices, and migration planning documents. |
| **Domain Skill: `income-generation`** | Models project costs, resource requirements, and business case validation. |
| **Tools:** `capability-map.yaml` | Gap analysis: current maturity vs target maturity per capability. |
| **Tools:** `archimate-viewpoint-guide.md` | Migration Viewpoint for transition planning. |

**Example prompt:**
> "As Hermes advisor, perform an opportunities and solutions analysis for closing the gaps identified in the capability map. Current gaps: secrets management (maturity 2→3), service mesh (2→3), cross-cloud connectivity (2→3), compliance (2→3). For each gap, propose: solution approach, estimated effort (t-shirt sizing), dependencies, and recommended implementation sequence. Generate a 12-month roadmap with quarterly milestones."

**Deliverable:** Gap Analysis, Solution Building Blocks, Implementation Roadmap, Migration Plan.

---

### Phase F: Migration Planning

**Purpose:** Detailed implementation and migration planning — prioritisation, transition architectures, and implementation governance.

| Hermes Capability | How It Supports This Phase |
|---|---|
| **Personality: `architect`** | Defines transition architectures — intermediate states between current and target. |
| **Personality: `operator`** | Validates migration plans against operational constraints — maintenance windows, rollback strategies, and business continuity. |
| **Skill: `planning`** | Generates detailed migration plans with task dependencies, critical paths, and resource assignments. |
| **Skill: `remediation`** | Defines rollback procedures and contingency plans for each migration step. |
| **Domain Skill: `voxflow-operations`** | VoxFlow-specific migration considerations — session preservation during K8s node drains, SIP registration continuity, CDR zero-loss during storage migration. |
| **Tools:** `archimate-viewpoint-guide.md` | Migration Viewpoint for visualising transition states. |

**Example prompt:**
> "As Hermes operator, create a migration plan for deploying Cilium Service Mesh to VoxFlow production. Current state: mTLS via cert-manager with manual certificate rotation. Target state: Cilium Service Mesh with SPIRE for workload identity. Define: transition architecture (coexistence phase where both systems operate), migration waves (by namespace / criticality), pre-migration validation checklist, cutover procedure, rollback triggers, and post-migration validation criteria. Include session impact analysis for live SIP calls during migration."

**Deliverable:** Migration Plan, Transition Architectures, Implementation Governance Model.

---

### Phase G: Implementation Governance

**Purpose:** Govern the implementation — architecture compliance reviews, change control, and contract monitoring.

| Hermes Capability | How It Supports This Phase |
|---|---|
| **Personality: `architect`** | Conducts architecture compliance reviews against principles, patterns, and ADRs. |
| **Personality: `operator`** | Monitors operational compliance — are deployments following runbooks and operational standards? |
| **Skill: `diagnostics`** | Analyses implementation deviations, configuration drift, and non-compliance root causes. |
| **Skill: `remediation`** | Recommends corrective actions for implementation issues. |
| **Domain Skill: `enterprise-architecture`** | Architecture Review Board (ARB) facilitation — checklists, review templates, compliance scoring. |
| **Tools:** `adr-template.md` | Validate that implementation decisions are captured as ADRs where they deviate from architecture. |
| **Tools:** `technology-radar.md` | Validate that technologies used align with radar rings — flag unauthorised HOLD ring usage. |

**Example prompt:**
> "As Hermes architect, conduct an architecture compliance review for the newly deployed VoxFlow billing service. Review checklist: does the deployment match the architecture defined in ADR-012 (Billing Service Data Isolation)? Does it follow the six-class DSCP model for its traffic? Are secrets managed via External Secrets Operator rather than K8s secrets? Are observability endpoints registered in Prometheus? Generate a compliance report with findings, severity ratings, and remediation recommendations."

**Deliverable:** Compliance Assessments, Architecture Review Records, Change Requests.

---

### Phase H: Architecture Change Management

**Purpose:** Manage changes to the architecture — business-driven, technology-driven, and lessons learned.

| Hermes Capability | How It Supports This Phase |
|---|---|
| **Personality: `analyst`** | Analyses change triggers, business impact, and architecture implications of proposed changes. |
| **Personality: `researcher`** | Researches technology trends, emerging threats/opportunities, and industry shifts that may trigger architecture changes. |
| **Skill: `summarisation`** | Consolidates lessons learned from implementation, operations, and incidents. |
| **Skill: `planning`** | Creates architecture change proposals, impact assessments, and transition plans for approved changes. |
| **Domain Skill: `hermes-mesh`** | Multi-agent analysis of cross-cutting changes — how a change in one domain ripples across others. |
| **Tools:** `technology-radar.md` | Updated as new technologies emerge or existing ones are deprecated. |
| **Tools:** `capability-map.yaml` | Updated as capabilities mature or new capabilities are added. |
| **Tools:** `adr-template.md` | New ADRs created for architecture changes; old ADRs marked as superseded. |

**Example prompt:**
> "As Hermes researcher, scan the technology landscape for emerging threats to our current architecture. Specifically: (1) Is there a viable alternative to Cilium that provides better eBPF performance or a more mature service mesh? (2) Are there new managed K8s services (EKS Auto Mode, GKE Autopilot) that could reduce our operational burden? (3) What is the impact of QUIC/HTTP3 on our SIP/WebSocket signalling architecture? Produce a technology watch report with recommendations for architecture change proposals."

**Deliverable:** Architecture Change Proposals, Technology Watch Reports, Updated Architecture Baseline.

---

## Cross-Cutting Hermes Capabilities (All Phases)

| Hermes Capability | TOGAF Application |
|---|---|
| **Profile: `deep`** (temp 0.1) | Use for formal deliverables, ADRs, and architecture documents requiring precision. |
| **Profile: `fast`** (temp 0.2) | Use for exploratory work, brainstorming, and draft iterations. |
| **Profile: `secure`** (temp 0.0, strict safety) | Use when handling sensitive architecture data, security patterns, or compliance documentation. |
| **Config: `config/hermes/config.yaml`** | Central routing configuration — maps skills to models. Tune model selection per ADM phase needs. |
| **Tool: PowerShell Module** `Hermes.Orchestration` | Automation of repeatable EA tasks — bulk ADR generation, radar updates, capability assessments. |
| **Pipeline Concept** (documented, not yet codified) | Chain skills sequentially: e.g., planning → codegen → diagnostics → summarisation for full ADM cycle. |

---

## Recommended Workflow by Engagement Type

### Greenfield Architecture Engagement
Preliminary → A → B → C → D → E → F → G → H (full cycle, AI-accelerated)

### Technology Selection Engagement
Preliminary (principles) → D (technology architecture) + ADR template → E (implementation options) → F (migration if replacing existing)

### Architecture Review Engagement
G (implementation governance — compliance review) → H (recommend changes)

### Capability Assessment Engagement
Preliminary (capability map baseline) → B (business alignment) → D (technology gaps) → E (opportunities) → F (improvement roadmap)

### Technology Radar Refresh (Quarterly)
H (technology watch) → Update `technology-radar.md` → Review with ARB

---

*Version: 2026-Q2 | Author: Brett Moore, Principal Enterprise Architect*
