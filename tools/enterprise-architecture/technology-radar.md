# Technology Radar Framework

## Overview

This Technology Radar provides a snapshot of our technology portfolio, organised into four rings that represent our adoption stance. It is maintained by the Enterprise Architecture function and reviewed quarterly. The radar is domain-structured (Infrastructure, Data, Application, Security, DevOps) with each domain having its own radar view.

**Purpose:**
- Guide technology selection for new projects
- Identify technology debt and obsolescence risks
- Align engineering teams on technology direction
- Surface emerging technologies for evaluation

**Update cadence:** Quarterly, aligned with PI planning. Each update is versioned (e.g., 2026-Q2).

---

## The Four Rings

### ADOPT
**Definition:** Technologies we have high confidence in. These are proven in our production environments, well-understood by our teams, and should be the default choice for new projects and initiatives.

**Criteria for Adopt:**
- Running in production across multiple services or clients for 6+ months
- Proven stability, performance, and security characteristics
- Active open-source community or commercially supported with clear roadmaps
- Sufficient internal expertise (3+ engineers proficient)
- Documented patterns, runbooks, and operational procedures exist
- Low operational toil and well-understood failure modes

**Action when something is in Adopt:** Use by default. Teams must justify deviation.

---

### TRIAL
**Definition:** Technologies we believe are ready for production use but haven't yet been proven at scale within our environment. These are actively being piloted in controlled projects. The goal is to gather real-world data to decide whether to promote to Adopt or relegate to Assess.

**Criteria for Trial:**
- Active pilot in at least one production or production-like project
- Strong technical merit but limited internal operational experience
- Active community or vendor backing with responsive support
- Addresses a genuine gap that Adopt-ring technologies cannot fill
- Risk understood and bounded (blast radius contained)

**Action when something is in Trial:** Use in constrained, non-critical-path projects. Must report outcomes to EA for ring decision within 2 quarters.

---

### ASSESS
**Definition:** Technologies that show promise and warrant investigation. These are on our radar as potentially interesting but haven't yet been validated. The goal is to understand capabilities, fit with our architecture, and readiness.

**Criteria for Assess:**
- Promising technology solving a relevant problem
- Gaining industry traction or mindshare
- No internal production usage yet
- May require upskilling or tooling investment
- Potential to disrupt or improve existing Adopt-ring choices

**Action when something is in Assess:** Time-boxed research spike (1-2 weeks). Produce a written assessment with recommendation: promote to Trial, remain in Assess, or move to Hold. No production use.

---

### HOLD
**Definition:** Technologies we recommend against using for new projects. This includes technologies being actively phased out, those that didn't meet our standards during Trial, or those that are obsolete/unsupported. Some technologies in Hold may still be in production — the Hold ring applies to *new* adoption.

**Criteria for Hold:**
- Deprecated by vendor or community (EOL announced or effectively abandoned)
- Failed Trial evaluation — didn't meet performance, security, or operational standards
- Superseded by a superior Adopt-ring alternative
- Legacy technology that must be maintained but shouldn't be expanded
- Technology that creates unacceptable vendor lock-in or licence risk
- Does not align with our architectural principles

**Action when something is in Hold:** Do not use for new projects. Plan migration for existing usage. No further investment without explicit EA exception.

---

## Example: Infrastructure Domain Technology Radar (2026-Q2)

### Domain: Infrastructure

---

### ADOPT

#### Docker (Container Runtime)
- **Classification:** Platform
- **Since:** 2018
- **Rationale:** Industry-standard container runtime. Used as the base container engine on all Kubernetes worker nodes. Mature tooling, massive ecosystem, well-understood security model. All VoxFlow microservices are packaged as Docker images.
- **Alternatives in lower rings:** Podman (Assess), containerd standalone (Trial)

#### Kubernetes (Container Orchestration)
- **Classification:** Platform
- **Since:** 2023
- **Rationale:** Adopted via ADR-001. Managed distributions (EKS, AKS, GKE) across all environments. Core platform for VoxFlow CPaaS deployment. Cilium CNI provides unified networking. Flux CD for GitOps.
- **Alternatives in lower rings:** Nomad (Hold — evaluated and rejected in ADR-001)

#### Terraform / OpenTofu (Infrastructure as Code)
- **Classification:** Tool
- **Since:** 2020
- **Rationale:** Declarative infrastructure provisioning across AWS, Azure, and GCP. All cloud resources defined as code. State stored in cloud-backed remote backends (S3 + DynamoDB, Azure Storage, GCS). Module registry for reusable infrastructure patterns.
- **Alternatives in lower rings:** Pulumi (Assess), Crossplane (Assess), CloudFormation/CDK (Hold — cloud-specific)

#### Cilium (CNI / eBPF Networking)
- **Classification:** Platform
- **Since:** 2024
- **Rationale:** eBPF-based CNI selected as part of K8s adoption. Provides: DSCP marking for VoxFlow six-class QoS model, network policy enforcement, Hubble observability, and service mesh capabilities. Replaces legacy iptables-based K8s networking. Key enabler for QoS Federation pattern.
- **Alternatives in lower rings:** Calico (Hold — no native eBPF DSCP), Flannel (Hold — insufficient features)

#### Prometheus + Grafana (Observability)
- **Classification:** Platform
- **Since:** 2022
- **Rationale:** Metrics collection and visualisation stack. Prometheus for time-series metrics with Alertmanager for alerting. Grafana for dashboards across infrastructure, application, and business metrics. VoxFlow session metrics, QoS DSCP distribution graphs, and latency heatmaps all in Grafana.
- **Alternatives in lower rings:** Datadog (Hold — cost at scale), VictoriaMetrics (Assess — Prometheus-compatible long-term storage)

---

### TRIAL

#### Cilium eBPF (for Advanced Traffic Engineering)
- **Classification:** Technique
- **Since:** 2025-Q4
- **Rationale:** Beyond basic CNI, trialling advanced eBPF programs for per-packet QoS classification, latency-aware load balancing, and bandwidth management. Being piloted on a subset of media worker pods. Goal: validate that eBPF programs can enforce six-class DSCP at line rate without adding latency.
- **Promotion criteria:** Consistent <1ms eBPF program execution time; no throughput degradation; successful load test at 500K sessions/month equivalent

#### TimescaleDB (Time-Series Database)
- **Classification:** Data Store
- **Since:** 2025-Q3
- **Rationale:** PostgreSQL extension providing hypertables for time-series data. Piloting as the analytics store for VoxFlow CDRs and QoS metrics. Currently running alongside legacy PostgreSQL for comparison. Compression and automatic partitioning reduce storage footprint vs raw Postgres.
- **Promotion criteria:** Query performance comparison vs PostgreSQL for 90-day CDR windows; compression ratio >10:1; operational stability for 3 months continuous production

#### Flux CD (GitOps Deployments)
- **Classification:** Tool
- **Since:** 2025-Q4
- **Rationale:** GitOps controller for Kubernetes. Replacing manual kubectl apply and legacy CI/CD deployment scripts. All cluster state declared in Git repositories. Automated drift detection and reconciliation. Currently deployed in staging environment only.
- **Promotion criteria:** Zero failed deployments over 30 days; DR exercise demonstrating cluster rebuild from Git within 4 hours; developer satisfaction survey >80% positive

#### SPIFFE/SPIRE (Workload Identity)
- **Classification:** Standard
- **Since:** 2026-Q1
- **Rationale:** CNCF-graduated identity framework for service-to-service authentication. Piloting as replacement for static API keys and mTLS certificate management across VoxFlow microservices. Integrates with Cilium for identity-aware network policy.
- **Promotion criteria:** Successful mTLS rotation without application restart; latency overhead <1ms for identity verification; integration validated across all 9 microservices

---

### ASSESS

#### CRDTs (Conflict-Free Replicated Data Types)
- **Classification:** Technique
- **Rationale:** Data structures that enable multi-master replication without conflict resolution. Potential for: multi-region session state synchronisation, distributed QoS policy configuration, and edge-local billing counters. Relevant to VoxFlow's multi-cloud presence but significant maturity questions.
- **Assessment focus:** Evaluate CRDT libraries (Automerge, Yjs); test concurrent edit scenarios for policy config; assess operational complexity vs eventual consistency approaches
- **Recommendation expected:** 2026-Q3

#### WebAssembly (Wasm) on Kubernetes
- **Classification:** Platform
- **Rationale:** Running Wasm workloads via K8s (Krustlet, SpinKube). Potential for: lightweight QoS policy evaluation at the edge, fast-start signalling functions, sandboxed customer extension points. Cold start in microseconds vs milliseconds for containers is compelling for signalling workloads.
- **Assessment focus:** WasmEdge vs Wasmtime runtime comparison; CNI integration (Cilium compatibility); memory safety guarantees for tenant isolation
- **Recommendation expected:** 2026-Q4

#### OpenTelemetry (OTel) Collector
- **Classification:** Standard
- **Rationale:** CNCF-incubating observability framework. Evaluating as unified telemetry pipeline (traces, metrics, logs) to replace fragmented collection agents. Vendor-neutral protocol; potential to simplify multi-cloud observability.
- **Assessment focus:** OTel Collector performance vs Prometheus direct scrape; Cilium Hubble integration; tail sampling for high-volume CDR traces
- **Recommendation expected:** 2026-Q3

#### Kamailio v6.0 (Next-Gen SIP Server)
- **Classification:** Platform
- **Rationale:** Upcoming major version of Kamailio signalling server. Promises improved WebSocket handling and HTTP/3 support. Currently running Kamailio v5.x in Adopt. v6.0 is in release candidate; need to assess migration path and breaking changes.
- **Assessment focus:** API compatibility with existing VoxFlow Kamailio config; performance benchmark vs v5.x; WebSocket reconnection behaviour
- **Recommendation expected:** 2026-Q4 (post-GA release)

---

### HOLD

#### FTP / FTPS (File Transfer Protocol)
- **Classification:** Protocol
- **Rationale:** Legacy protocol for file-based CDR delivery to wholesale customers. Plain FTP transmits credentials in cleartext; FTPS is complex to configure and firewall-unfriendly. Remains in production for backward compatibility with 3 wholesale partners.
- **Migration plan:** Migrate partners to SFTP (SSH File Transfer Protocol) or S3 pre-signed URLs. Target retirement: 2027-Q1.

#### Docker Swarm
- **Classification:** Platform
- **Rationale:** Previously evaluated in ADR-001. Near-abandoned project; no cloud provider managed offerings; no Cilium support. Rejected in favour of Kubernetes.
- **Action:** No new deployments. Existing Swarm usage in legacy staging environment to be migrated to K8s.

#### Calico (CNI)
- **Classification:** Platform
- **Rationale:** Legacy CNI used in early K8s experiments. Does not provide native eBPF-based DSCP marking (relies on iptables). Superseded by Cilium.
- **Action:** No new clusters to use Calico. Existing clusters to be migrated as part of standard cluster refresh cycle.

#### CentOS (Operating System)
- **Classification:** Platform
- **Rationale:** Red Hat ended CentOS Linux support in June 2024 (replaced by CentOS Stream with rolling releases). All our K8s nodes run Ubuntu LTS or Flatcar Container Linux. Several legacy VMs still on CentOS 7 (EOL).
- **Action:** Migrate remaining CentOS 7 VMs to Rocky Linux 9 or Ubuntu 24.04 LTS. Target completion: 2026-Q4.

#### SNMPv2 (Monitoring Protocol)
- **Classification:** Protocol
- **Rationale:** Legacy monitoring protocol still used by some network hardware for bandwidth and interface statistics. Insecure (community strings in cleartext), inefficient polling model, limited data types. All new monitoring uses Prometheus exporters or streaming telemetry.
- **Action:** Continue to maintain SNMPv2 where hardware doesn't support modern alternatives. No new SNMP-based monitoring to be built. Prefer NETCONF/YANG or gNMI for new hardware.

---

## Radar Summary Matrix

| Technology         | Ring   | Domain        | Since    | Trend       |
|--------------------|--------|---------------|----------|-------------|
| Docker             | ADOPT  | Infrastructure | 2018    | Stable      |
| Kubernetes         | ADOPT  | Infrastructure | 2023    | Growing     |
| Terraform/OpenTofu | ADOPT  | Infrastructure | 2020    | Stable      |
| Cilium (CNI)       | ADOPT  | Infrastructure | 2024    | Growing     |
| Prometheus+Grafana | ADOPT  | Infrastructure | 2022    | Stable      |
| Cilium eBPF Adv.   | TRIAL  | Infrastructure | 2025-Q4 | Rising      |
| TimescaleDB        | TRIAL  | Data          | 2025-Q3 | Rising      |
| Flux CD            | TRIAL  | DevOps        | 2025-Q4 | Rising      |
| SPIFFE/SPIRE       | TRIAL  | Security      | 2026-Q1 | Rising      |
| CRDTs              | ASSESS | Data          | 2026    | New         |
| Wasm on K8s        | ASSESS | Infrastructure | 2026    | New         |
| OpenTelemetry      | ASSESS | Observability | 2026    | Rising fast |
| Kamailio v6.0      | ASSESS | Infrastructure | 2026    | Pending GA  |
| FTP/FTPS           | HOLD   | Infrastructure | Legacy  | Declining   |
| Docker Swarm       | HOLD   | Infrastructure | Legacy  | Dead        |
| Calico (CNI)       | HOLD   | Infrastructure | Legacy  | Declining   |
| CentOS             | HOLD   | Infrastructure | Legacy  | Dead        |
| SNMPv2             | HOLD   | Infrastructure | Legacy  | Declining   |

---

## How to Use This Radar

1. **Starting a new project:** Default to ADOPT ring technologies. If an ADOPT technology does not fit, consult EA before reaching into TRIAL.
2. **Evaluating a new technology:** Propose it for the ASSESS ring via the EA intake process. Provide a one-page rationale.
3. **Promoting from TRIAL to ADOPT:** Run a production pilot for 3+ months. Present evidence to the Architecture Review Board.
4. **Moving something to HOLD:** Propose with a migration plan for existing usage. EA reviews quarterly.
5. **Exceptions:** Documented via an ADR and approved by the Principal Enterprise Architect.

---

*Version: 2026-Q2 | Last Updated: 2026-04-28 | Maintained by: Enterprise Architecture*
