# ArchiMate Viewpoint Quick Reference

## Overview

This guide maps common architectural questions to the most appropriate ArchiMate viewpoint. Each viewpoint is a selection of ArchiMate concepts and relationships tailored to a specific stakeholder concern. Use this as a rapid reference during modelling sessions and architecture reviews.

**ArchiMate Version:** 3.2
**Tooling:** These viewpoints can be modelled in any ArchiMate-compliant tool (Archi, Sparx EA, BiZZdesign, etc.) or sketched manually.

---

## Viewpoint Selection Flow

```
Stakeholder asks...
        |
        v
"What is the big picture?"     → Layered Viewpoint
"How do we deliver X?"         → Capability Map Viewpoint
"What runs on what?"           → Technology Usage Viewpoint
"How do we get from A to B?"   → Migration Viewpoint
"Who does what?"               → Organisation Viewpoint (see below)
"How do applications talk?"    → Application Cooperation Viewpoint (see below)
"What are the gaps?"           → Gap Analysis (use Capability Map + Migration)
```

---

## 1. Layered Viewpoint

### What Question It Answers
"How do the business, application, and technology layers relate to each other? What is the holistic architecture picture?"

### Stakeholder
Enterprise architects, CTO, architecture review board, programme managers. The "default" viewpoint for architecture overviews.

### Concepts Used
All core ArchiMate layers:
- **Business Layer:** Business actors, roles, business services, business processes
- **Application Layer:** Application components, application services, data objects
- **Technology Layer:** Nodes, devices, system software, technology services
- **Relationships:** Serving, realisation, assignment, composition, aggregation
- **Cross-layer:** Service realisation (business service → application service → technology service)

### When to Use
- Creating an architecture overview (Phase A/B/C/D deliverables)
- Onboarding new team members to the architecture
- Architecture Review Board presentations
- Impact analysis: "if this technology changes, what business services are affected?"

### Example
**Scenario:** Understanding the VoxFlow CPaaS platform end-to-end.

```
LAYERED VIEWPOINT: VoxFlow CPaaS Platform

=== BUSINESS LAYER ===
[Wholesale Customer] --uses--> [SIP Trunking Service]
[Wholesale Customer] --uses--> [CPaaS API Service]
[Enterprise Customer] --uses--> [Managed Voice Service]

=== APPLICATION LAYER ===
[SIP Trunking Service] --realised by--> [Kamailio Signalling]
[CPaaS API Service] --realised by--> [REST API Gateway] + [WebSocket Gateway]
[REST API Gateway] --serves--> [Billing Engine]
[Kamailio Signalling] --serves--> [FreeSWITCH Media Worker]
[FreeSWITCH Media Worker] --accesses--> [CDR Data Object]

=== TECHNOLOGY LAYER ===
[Kamailio Signalling] --deployed on--> [K8s Cluster (AWS)]
[Kamailio Signalling] --deployed on--> [K8s Cluster (Azure)]
[FreeSWITCH Media Worker] --deployed on--> [Compute Node]
[CDR Data Object] --stored on--> [TimescaleDB Hypertable]
[TimescaleDB Hypertable] --hosted on--> [EBS Volume (AWS)]
```

### Anti-Pattern
Putting everything on one diagram. The Layered Viewpoint should be selectively scoped — show only the elements relevant to the story you're telling. If the diagram has 50+ elements, split into multiple viewpoints.

---

## 2. Capability Map Viewpoint

### What Question It Answers
"What business capabilities do we have? What is their maturity? Where are our gaps? What capabilities are needed to support the strategy?"

### Stakeholder
Business architects, CIO, strategy team, portfolio managers. NOT typically for technical stakeholders (use Technology Usage instead).

### Concepts Used
- **Capability:** A business-facing ability that the organisation possesses or requires
- **Resource:** Assigned to a capability (people, technology, budget)
- **Outcome / Goal:** Realised by a capability
- **Relationship:** Composition (capability nesting), realisation, serving
- **No technology elements** (by design — capability maps are technology-agnostic)

### When to Use
- Strategic planning and capability-based investment decisions
- Identifying capability gaps between current and desired state
- Mergers and acquisitions (comparing capability maps)
- Aligning IT spend to business capabilities

### Example
**Scenario:** Assessing Cloud Infrastructure capabilities for a CPaaS provider.

```
CAPABILITY MAP VIEWPOINT: InfraForesight Cloud Infrastructure

STRATEGIC THEME: "Deliver QoS-Assured Multi-Cloud CPaaS"

Level 1 Capabilities:
  ├── Cloud Infrastructure (owner: Head of Platform Engineering)
  │   ├── Compute Orchestration         [Maturity: Defined    → Target: Optimised]
  │   │   ├── Container Orchestration   [Maturity: Defined    → Target: Optimised]
  │   │   ├── Serverless Execution      [Maturity: Managed    → Target: Defined]
  │   │   └── VM Management             [Maturity: Defined    → Target: Managed*]
  │   │
  │   ├── Network Services              [Maturity: Managed    → Target: Defined]
  │   │   ├── QoS Enforcement (DSCP)    [Maturity: Defined    → Target: Optimised]
  │   │   ├── Cross-Cloud Connectivity  [Maturity: Managed    → Target: Defined]
  │   │   ├── Load Balancing            [Maturity: Defined    → Target: Defined]
  │   │   └── Service Mesh              [Maturity: Managed    → Target: Defined]
  │   │
  │   ├── Storage Services              [Maturity: Defined    → Target: Defined]
  │   │   ├── Block & File Storage      [Maturity: Defined    → Target: Defined]
  │   │   ├── Object Storage            [Maturity: Defined    → Target: Defined]
  │   │   └── Data Protection           [Maturity: Managed    → Target: Defined]
  │   │
  │   └── Infrastructure Security       [Maturity: Managed    → Target: Defined]
  │       ├── Identity & Access         [Maturity: Defined    → Target: Optimised]
  │       ├── Network Security          [Maturity: Defined    → Target: Optimised]
  │       ├── Secrets Management        [Maturity: Managed    → Target: Defined]
  │       └── Compliance & Audit        [Maturity: Managed    → Target: Defined]

  ├── Product Engineering               [owner: VP Engineering]
  ├── Customer Operations               [owner: VP Operations]
  └── Sales & Marketing                 [owner: CRO]

*VM Management deliberately reduced as workloads migrate to containers

GAP HEATMAP: ██ = Critical gap, ██ = Moderate gap, ██ = On-track
```

### Anti-Pattern
Mixing technology components into the capability map (e.g., "Kubernetes Cluster" is not a capability; "Container Orchestration" is). Capabilities answer "what" not "how."

---

## 3. Technology Usage Viewpoint

### What Question It Answers
"What applications and business processes depend on which technologies? If we decommission technology X, what is the blast radius? Are we over-dependent on a single platform?"

### Stakeholder
Enterprise architects, infrastructure architects, IT operations, risk/compliance teams. Essential for technology lifecycle management and risk assessment.

### Concepts Used
- **Technology elements:** Nodes, devices, system software, technology services, artifacts
- **Application elements:** Application components, application services
- **Business elements (optional):** Business processes, business services (shown as dependents)
- **Relationships:** Realisation, serving, assignment, dependency
- **Cross-layer dependency chains:** Business Service → Application Component → Technology Node

### When to Use
- Technology obsolescence planning ("what breaks if we retire CentOS?")
- Risk assessment and dependency analysis
- Cloud migration planning (what runs where?)
- Technology radar reviews (identify HOLD ring blast radius)
- SOC2 / ISO27001 evidence for technology dependency management

### Example
**Scenario:** Understanding what depends on CentOS 7 (currently in HOLD ring).

```
TECHNOLOGY USAGE VIEWPOINT: CentOS 7 Dependency Analysis

BUSINESS SERVICES AFFECTED:
  [SIP Trunking Service] --depends on--> [FreeSWITCH Media Worker (Legacy)]
  [CDR Archival Service] --depends on--> [Legacy FTP Server]

APPLICATION COMPONENTS ON CENTOS 7:
  [FreeSWITCH Media Worker (Legacy)] --deployed on--> [VM: media-legacy-01 (CentOS 7)]
  [FreeSWITCH Media Worker (Legacy)] --deployed on--> [VM: media-legacy-02 (CentOS 7)]
  [Legacy FTP Server] --deployed on--> [VM: ftp-archive-01 (CentOS 7)]

TECHNOLOGY STACK PER NODE:
  Node: media-legacy-01
    ├── OS: CentOS 7.9 (EOL: June 2024)
    ├── Runtime: FreeSWITCH 1.10.7
    ├── Kernel: 3.10.0-1160 (no eBPF support)
    └── QoS: Legacy tc qdisc (not Cilium-managed)

  Node: media-legacy-02
    ├── OS: CentOS 7.9
    ├── Runtime: FreeSWITCH 1.10.7
    └── (same stack as -01)

  Node: ftp-archive-01
    ├── OS: CentOS 7.9
    ├── Service: vsftpd 3.0.2
    └── Protocol: FTPS (explicit TLS)

MIGRATION TARGETS:
  media-legacy-0x → Rocky Linux 9 + FreeSWITCH 1.10.11 (or K8s pod if DPDK viable)
  ftp-archive-01  → SFTP on Ubuntu 24.04 LTS

BLAST RADIUS SCORE: MEDIUM (3 nodes, 2 business services affected)
MIGRATION PRIORITY: HIGH (OS EOL, security risk)
```

### Anti-Pattern
Listing every single technology instance. Focus on dependencies that create risk — EOL software, single points of failure, unauthorised technology, or over-dependency on a single vendor.

---

## 4. Migration Viewpoint

### What Question It Answers
"How do we transition from the current architecture to the target architecture? What intermediate states exist? What is the sequence of changes?"

### Stakeholder
Programme managers, project managers, implementation teams, architecture review board. Essential for phased migration governance.

### Concepts Used
- **Plateau:** A snapshot of the architecture at a point in time (Current, Transition 1, Transition 2, ..., Target)
- **Gap:** A difference between two plateaus (shown as a delta)
- **Work Package:** A set of changes that close one or more gaps
- **All ArchiMate elements** can appear in plateaus, but focus on what CHANGES
- **Relationships:** Triggering (work package A triggers B), composition (work packages nest)

### When to Use
- Major platform migrations (VM → K8s, CentOS → Rocky Linux)
- Multi-phase programmes spanning quarters or years
- Communicating migration sequence to non-technical stakeholders
- Identifying migration dependencies and critical path

### Example
**Scenario:** Migrating from legacy networking (iptables/Calico) to eBPF/Cilium across the K8s fleet.

```
MIGRATION VIEWPOINT: Calico → Cilium CNI Migration

=== PLATEAU 0: CURRENT STATE (2026-Q2) ===
  AWS EKS:  Calico CNI
  Azure AKS: Calico CNI
  GCP GKE:   Calico CNI (early Cilium trial cluster exists)
  QoS:       iptables-based DSCP marking (unreliable)

=== PLATEAU 1: TRANSITION STATE (2026-Q3) ===
  AWS EKS:  Calico CNI ────── (unchanged)
  Azure AKS: Cilium CNI ◄─── (migrated first, lower risk)
  GCP GKE:  Cilium CNI ◄─── (migrated first, trial cluster)
  QoS:      Partial eBPF DSCP coverage

  Work Package: WP-AZURE-CILIUM
    ├── Deploy Cilium on AKS staging → validate
    ├── Canary migration: 10% of media worker pods
    ├── Full cutover with Calico→Cilium policy translation
    └── Post-migration validation: DSCP marking test

  Work Package: WP-GCP-CILIUM
    ├── Promote existing trial cluster
    └── Apply lessons learned from Azure migration

=== PLATEAU 2: TARGET STATE (2026-Q4) ===
  AWS EKS:  Cilium CNI ◄─── (final migration)
  Azure AKS: Cilium CNI
  GCP GKE:  Cilium CNI
  QoS:      Full eBPF DSCP coverage, six-class model enforced across all clusters

  Work Package: WP-AWS-CILIUM
    ├── Deploy Cilium on EKS staging → validate
    ├── Policy migration (Calico→CiliumNetworkPolicy, automated translation)
    ├── Canary migration
    ├── Full cutover
    └── Decommission Calico components

  Work Package: WP-QOS-VALIDATION (cross-cutting)
    ├── End-to-end DSCP marking test across all three clouds
    ├── Performance benchmark vs baseline
    └── Update operations runbooks

MIGRATION GAPS (Plateau 0 → Plateau 2):
  GAP-CNI:        Calico CNI → Cilium CNI (all clusters)
  GAP-QOS:        iptables marking → eBPF DSCP enforcement
  GAP-OBSERVE:    No flow visibility → Hubble observability
  GAP-POLICY:     Calico NP → CiliumNetworkPolicy (richer L7 rules)
```

### Anti-Pattern
Showing only current and target states with no transitions. Stakeholders need to see the path. Also avoid making transitions too granular — aim for 2-4 transition plateaus for a typical multi-quarter migration.

---

## Other Useful Viewpoints (Brief)

### Organisation Viewpoint
**Question:** "Who is responsible for what?"
**Concepts:** Business actors, roles, departments. Assignment and composition relationships.
**Use for:** RACI mapping, team structure design, identifying single points of knowledge.

### Application Cooperation Viewpoint
**Question:** "How do applications talk to each other?"
**Concepts:** Application components, application services, data flows, interfaces.
**Use for:** Integration architecture, API design, identifying tight coupling or circular dependencies.

### Goal/Requirements Realisation Viewpoint
**Question:** "Does our architecture actually deliver our goals?"
**Concepts:** Goals, outcomes, requirements, capabilities, core elements that realise them.
**Use for:** Strategy-to-architecture traceability, proving architecture delivers business objectives.

---

## Quick Reference Card

| I Need To... | Use This Viewpoint |
|---|---|
| Show the big picture across all layers | Layered Viewpoint |
| Assess and plan business capabilities | Capability Map Viewpoint |
| Understand technology dependencies and risk | Technology Usage Viewpoint |
| Plan a phased migration | Migration Viewpoint |
| Show who does what | Organisation Viewpoint |
| Show how apps integrate | Application Cooperation Viewpoint |
| Prove architecture meets goals | Goal Realisation Viewpoint |

---

*Version: 2026-Q2 | ArchiMate 3.2 | Author: Brett Moore, Principal Enterprise Architect*
