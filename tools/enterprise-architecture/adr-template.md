# Architecture Decision Record (ADR) Template

## Usage Instructions

1. Copy this template for each significant architectural decision.
2. Name the file `ADR-NNN-title-with-hyphens.md` where NNN is a zero-padded sequential number.
3. Fill in all sections. Be specific and evidence-based.
4. Store ADRs in `docs/adr/` within the project repository.
5. Once an ADR is Accepted, it is immutable. If a decision is superseded, create a new ADR referencing the old one and mark the old one as "Superseded by ADR-NNN".

**When to write an ADR:**
- Choosing between competing technologies or platforms
- Selecting a cloud service or architectural pattern
- Deciding on a data storage strategy
- Making irreversible or high-cost infrastructure decisions
- Defining cross-cutting concerns (auth, logging, monitoring strategy)

**When NOT to write an ADR:**
- Minor implementation details
- Decisions that can be easily reversed
- Coding style preferences
- Things already covered by existing policy or standards

---

# ADR-NNN: [Title]

| Field        | Value                              |
|--------------|------------------------------------|
| **ADR**      | ADR-NNN                            |
| **Title**    | [Brief decision title]             |
| **Status**   | [Proposed / Accepted / Deprecated / Superseded] |
| **Date**     | YYYY-MM-DD                         |
| **Author**   | [Name / Role]                      |
| **Deciders** | [Names of people who approved]     |
| **Supersedes** | [ADR-NNN or None]                |
| **Superseded By** | [ADR-NNN or None]              |

## Status

[Proposed | Accepted | Deprecated | Superseded by ADR-NNN]

*Proposed:* under discussion, not yet approved.
*Accepted:* approved and in effect.
*Deprecated:* no longer relevant (decision no longer applies).
*Superseded:* replaced by a later ADR.

## Context

[Describe the forces at play: business requirements, technical constraints, timeline pressures, stakeholder concerns. What is the problem we are trying to solve? Why can't we continue with the status quo? Include any relevant architectural principles that constrain the decision space.]

## Decision

[State the decision clearly and unambiguously. What are we going to do? Be specific — include version numbers, configuration choices, deployment models. This section should stand alone: a new team member should understand the decision by reading only this section.]

**We will** [action verb] [option chosen] **to achieve** [primary benefit] **because** [rationale].

## Alternatives Considered

| Alternative | Description | Pros | Cons | Outcome |
|---|---|---|---|---|
| [Option A name] | [Brief description] | [Key advantages] | [Key disadvantages] | [Chosen / Rejected because...] |
| [Option B name] | [Brief description] | [Key advantages] | [Key disadvantages] | [Chosen / Rejected because...] |
| [Status Quo / Do Nothing] | [What happens if we change nothing] | [Advantages of no change] | [Disadvantages of no change] | [Rejected because...] |

## Consequences

### Positive
- [Benefit 1: describe the impact]
- [Benefit 2: describe the impact]
- [Benefit 3: describe the impact]

### Negative
- [Risk or cost 1: describe the impact and mitigation]
- [Risk or cost 2: describe the impact and mitigation]
- [Risk or cost 3: describe the impact and mitigation]

### Neutral / Watchpoints
- [Observation: things to monitor that are neither clearly positive nor negative]

## Compliance and Validation

[How will we confirm the decision was implemented correctly? How do we measure success? Include specific metrics, thresholds, or acceptance criteria.]

## References

- [Link or citation 1]
- [Link or citation 2]
- [Related ADR-NNN: title]
- [Vendor documentation consulted]
- [Proof-of-concept results or benchmark data]

---

# EXAMPLE: ADR-001: Adopt Kubernetes as Container Orchestration Platform

| Field        | Value                              |
|--------------|------------------------------------|
| **ADR**      | ADR-001                            |
| **Title**    | Adopt Kubernetes as Container Orchestration Platform |
| **Status**   | Accepted                           |
| **Date**     | 2026-02-17                         |
| **Author**   | Brett Moore, Principal Enterprise Architect |
| **Deciders** | CTO, Head of Platform Engineering, Head of Infrastructure |
| **Supersedes** | None                             |
| **Superseded By** | None                           |

## Status

Accepted

## Context

InfraForesight is transitioning from VM-based deployments to containerised microservices for the VoxFlow CPaaS platform. We currently run Docker Compose in staging and have a mix of hand-rolled deployment scripts in production across three cloud providers (AWS, Azure, GCP). Our workloads include:

- 9 microservices (FreeSWITCH media workers, Kamailio signalling, REST API, WebSocket gateway, billing engine, analytics pipeline, CDR processor, provisioning service, QoS policy engine)
- Stateful workloads requiring persistent volumes (TimescaleDB hypertables, Redis clusters, PostgreSQL)
- Strict latency SLAs for real-time media (sub-50ms processing) and signalling (sub-10ms)
- Multi-cloud presence with eBPF-based DSCP marking via Cilium
- Expected growth from 50K to 500K sessions/month within 18 months

Our current deployment model causes: inconsistent environments between staging/production, manual rollback procedures, lack of auto-scaling for media workers, and configuration drift across cloud providers. We need a platform that provides declarative configuration, self-healing, horizontal scaling, and multi-cloud portability.

## Decision

**We will adopt Kubernetes (K8s) v1.31+ as the standard container orchestration platform** across all environments (dev, staging, production) and all three cloud providers, **to achieve** consistent declarative deployment, automated scaling, and self-healing for the VoxFlow microservice fleet, **because** Kubernetes is the industry standard with the richest ecosystem for networking (CNI), storage (CSI), and service mesh — all critical for our QoS-centric platform.

Specific decisions within this ADR:

- **Managed K8s distributions:** EKS on AWS, AKS on Azure, GKE on GCP (no self-managed control planes)
- **CNI:** Cilium (already selected for eBPF DSCP marking — consistent with existing investment)
- **Service mesh:** Cilium Service Mesh (no Istio — avoid layering complexity when Cilium covers both)
- **GitOps tool:** Flux CD v2 for declarative, git-driven deployments
- **Ingress:** NGINX Ingress Controller with custom DSCP annotation support
- **Container runtime:** containerd (default on managed K8s)
- **Storage:** Cloud-native CSI drivers (EBS CSI, Azure Disk CSI, GCE PD CSI) with snapshot support for TimescaleDB

## Alternatives Considered

| Alternative | Description | Pros | Cons | Outcome |
|---|---|---|---|---|
| **Kubernetes (managed)** | EKS/AKS/GKE managed Kubernetes clusters | Industry standard; CNCF graduated; massive ecosystem (CNI, CSI, operators); native Cilium support; RBAC built-in; declarative GitOps via Flux | Operational complexity; steep learning curve for dev teams; requires dedicated platform team | **Chosen** — best fit for multi-cloud, QoS-sensitive workloads with strong Cilium integration |
| **Nomad + Consul** | HashiCorp Nomad scheduler with Consul service mesh | Simpler architecture than K8s; lower resource overhead; good for batch workloads; native multi-cloud | Smaller ecosystem than K8s; no native Cilium integration; fewer managed offerings; smaller talent pool | Rejected — insufficient eBPF/Cilium integration for our DSCP marking requirements |
| **Docker Swarm** | Docker native orchestration | Familiar from current Docker Compose usage; simple to operate; low overhead | Near-abandoned project; no cloud provider managed offerings; no Cilium support; no GitOps ecosystem | Rejected — cannot meet multi-cloud, QoS, or scaling requirements |
| **AWS ECS + Azure Container Instances + GCP Cloud Run** | Per-cloud, serverless container platforms | No cluster management; pay-per-use; tight cloud integration | Vendor lock-in per cloud; inconsistent APIs across clouds; no unified Cilium/eBPF control plane; no cross-cloud service mesh | Rejected — violates multi-cloud portability principle |
| **Status quo (Docker Compose + scripts)** | Continue with current approach | Zero migration cost | Already failing: manual scaling, drift, no self-healing, cannot support 500K sessions/month | Rejected — current approach will not scale to business targets |

## Consequences

### Positive
- **Declarative infrastructure:** All VoxFlow components defined as YAML manifests in Git; single source of truth across 3 clouds
- **Unified Cilium/eBPF QoS plane:** Consistent DSCP marking, network policy, and observability across all clusters via a single CNI
- **Automated scaling:** HPA (Horizontal Pod Autoscaler) for media workers based on session count; KEDA for event-driven scaling of analytics pipeline
- **Self-healing:** Failed pods restart automatically; node failures trigger rescheduling; liveness/readiness probes prevent traffic to unhealthy instances
- **Multi-cloud portability:** Same manifests deploy to EKS, AKS, GKE — cloud-specific differences isolated to CSI drivers and LoadBalancer annotations
- **Rich operator ecosystem:** TimescaleDB operator, Redis operator, PostgreSQL operator for automated day-2 operations

### Negative
- **Operational complexity:** Requires dedicated platform engineering team (2-3 FTE) for cluster lifecycle management, upgrades, and security patching
  - *Mitigation:* Use managed K8s services to offload control plane operations; invest in training for existing infrastructure team
- **Cost increase:** Managed K8s control planes cost ~$0.10/hr per cluster × 9 clusters (3 clouds × 3 envs) ≈ $650/month in control plane fees alone
  - *Mitigation:* Consolidate dev/staging clusters where possible; reserved instance pricing for production nodes
- **Learning curve:** Development teams must learn Kubernetes concepts (Pods, Deployments, Services, Ingress, ConfigMaps, Secrets)
  - *Mitigation:* Internal K8s workshop series; provide Helm charts and developer CLI tooling; "paved road" deployment templates

### Neutral / Watchpoints
- Cilium Service Mesh is newer than Istio and has a smaller community; monitor maturity and stability in production before fully deprecating alternative mesh considerations
- K8s version upgrade cadence (3 releases/year) requires disciplined cluster lifecycle management — we must stay within n-1 version skew for managed K8s

## Compliance and Validation

- **Success criteria:** All 9 VoxFlow microservices running in K8s across all 3 clouds within 6 months
- **Performance:** 99th percentile media latency <50ms intra-pod; DSCP marking preserved through the CNI (validated via tcpdump on node interfaces)
- **Operational:** Zero-downtime deployments via rolling update strategy; rollback <5 minutes
- **Cost:** Monthly infrastructure cost deviation <15% from pre-K8s baseline after initial migration
- **Audit:** All cluster configurations stored in Git; Flux CD provides audit trail of all applied changes
- **Validation checkpoint:** Load test at 500K sessions/month equivalent traffic before production cutover

## References

- [CNCF Kubernetes Graduated Project Status](https://www.cncf.io/projects/kubernetes/)
- [Cilium CNI Documentation](https://docs.cilium.io/en/stable/)
- [VoxFlow QoS Architecture — Six-Class DSCP Model](../../docs/voxflow-qos-architecture.md)
- [ADR-003: Adopt Cilium as CNI for eBPF-Based DSCP Marking](adr-003-cilium-cni-ebpf-dscp.md) (hypothetical, for illustration)
- [Flux CD Documentation](https://fluxcd.io/docs/)
- POC results: Kubernetes vs Nomad comparative benchmark, February 2026 (internal Confluence)
- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
