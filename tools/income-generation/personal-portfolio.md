# Brett Moore — Personal Portfolio & Capability Statement

> This is your elevator pitch in document form. Use for: about pages, bio sections,
> speaking proposals, consulting one-pagers, and "tell me about yourself."

---

## Who I Am

I'm Brett Moore. I make important network packets go first — and I prove it.

**Location:** Northampton, UK
**Email:** brett@btfm.uk
**GitHub:** github.com/Brettmmmmm
**Website:** infraforesight.com

---

## The One-Sentence Pitch

I'm one of very few engineers worldwide who understands cross-cloud QoS enforcement at every layer — from the application socket through the Linux kernel, Kubernetes eBPF, cloud interconnect, and customer-premise equipment — and I've built the platform to prove it.

---

## Why I'm Different

Most cloud architects understand cloud networking. Most network engineers understand enterprise QoS. Almost nobody understands both — and fewer still understand how to enforce deterministic quality across cloud boundaries.

I've spent 30 years at the intersection.

- **CCIE in QoS** — fewer than 200 active worldwide. 8-hour lab exam. No notes. Build a QoS architecture to spec from scratch.
- **Cross-cloud infrastructure** — not just one provider. I design and operate across AWS, Azure, and GCP simultaneously.
- **Five-layer QoS enforcement** — socket (setsockopt), kernel (tc HTB), container (Cilium eBPF), cloud interconnect (provider QoS APIs), CPE (auto-generated switch config). I've implemented all five in production.
- **Business outcome architecture** — I don't just draw diagrams. I connect infrastructure decisions to revenue, regulatory compliance, and operational cost.

---

## Key Achievements

### O2 National TDM-to-VoIP Migration (2015-2018)

Designed and governed the architectural migration of O2's entire enterprise voice estate from traditional TDM circuits to SIP-based VoIP. 500+ enterprise customers, 10,000+ circuits, zero voice quality regression.

**What made it work:**
- Six-class DSCP model designed before any hardware procurement
- Repeatable migration factory: survey → design → parallel run → cutover → verify
- MOS measurement on every call with automatic rollback triggers
- Programme completed on time, within budget, no customer churn from quality issues

### InfraForesight QoS Fabric (2024-Present)

Built the industry's first cross-cloud traffic engineering platform with contractual application-layer SLAs.

**Architecture:**
- Five enforcement points: socket → kernel → eBPF → cloud interconnect → CPE
- Six-class DSCP model, application-agnostic, customisable per tenant
- Continuous quality measurement: MOS, R-factor, jitter, latency at 5-second granularity
- Policy drift detection every 60 seconds with auto-remediation
- Deployed across AWS, Azure, and GCP simultaneously
- Multi-tenant with dedicated VPC options for regulated customers

### VoxFlow — QoS-Aware CPaaS (2025-Present)

The only CPaaS platform with end-to-end DSCP enforcement. Built on the InfraForesight fabric.

**What makes it unique:**
- 9 microservices across multi-cloud Kubernetes (EKS, AKS, GKE)
- Cilium eBPF for pod-level DSCP marking at 10M+ packets/second
- FreeSWITCH + Kamailio for media and signalling with native QoS integration
- TimescaleDB hypertables for real-time QoS telemetry
- WhatsApp Voice Calling, RCS Rich Messaging, Teams Direct Routing
- Real-time AI: STT, sentiment analysis, agent assist — all latency-guaranteed
- Open CPaaS API with per-tenant QoS profiles

### Hermes AI OS (2025-Present)

Configuration-driven multi-agent AI orchestration system. 10 personalities, 8 skills, 4 domain skills, skill packs, structured output policy enforcement. Built because existing agent frameworks don't provide enterprise-grade determinism.

---

## Technology Stack

### Core Networking
Cisco IOS/IOS-XE/NX-OS, Juniper JunOS, Arista EOS, MPLS, SD-WAN, BGP, OSPF, QoS (DSCP, CBWFQ, LLQ, WRED, policing/shaping), SIP, RTP, WebRTC, Carrier interconnection, SBCs

### Cloud Infrastructure
AWS (VPC, Direct Connect, Transit Gateway, EKS), Azure (VNet, ExpressRoute, AKS), GCP (VPC, Cloud Interconnect, Application Awareness, GKE), Multi-cloud architecture

### Kubernetes & Platform
Kubernetes (EKS/AKS/GKE), Cilium eBPF, Helm, ArgoCD/Flux, Terraform, Crossplane, Istio, Prometheus, Grafana, AlertManager, Loki, Tempo

### Voice & UC
FreeSWITCH, Kamailio, Asterisk, Cisco Unified Communications, Microsoft Teams Direct Routing, Operator Connect, Genesys, Amazon Connect, Oracle/Ribbon/AudioCodes SBCs, RTCP-XR, MOS measurement

### Development & Automation
Golang, Python, TypeScript/Node.js, Bash, PowerShell, Git, CI/CD (GitHub Actions, ArgoCD), PostgreSQL, TimescaleDB, Redis

### Architecture Governance
TOGAF, ArchiMate, HLD/LLD, Architecture Decision Records (ADR), Technology Radar, Architecture Review Board, RFP/I evaluation

---

## Certifications

- **CCIE — Quality of Service** (one of <200 active worldwide)
- **CCIE — Routing & Switching** (written)
- Additional Cisco specialisations across routing, switching, and voice technologies

---

## Notable Projects

| Project | Role | Scale | Technologies |
|---------|------|-------|-------------|
| O2 National VoIP Migration | Enterprise Architect | 500+ enterprises, 10K+ circuits | SIP, DSCP QoS, Carrier interconnect |
| InfraForesight QoS Fabric | Founder / Architect | Multi-cloud platform | eBPF, Cilium, K8s, AWS/Azure/GCP |
| VoxFlow CPaaS | Founder / Architect | 9 microservices, multi-cloud K8s | FreeSWITCH, Kamailio, DSCP, AI/ML |
| Hermes AI OS | Creator / Architect | Multi-agent platform | LLM orchestration, structured output |
| Fractional EA engagements | Enterprise Architect | Multiple organisations | TOGAF, HLD/LLD, governance |

---

## What I'm Looking For

I'm seeking opportunities where QoS and infrastructure architecture create measurable business value:

1. **Consulting engagements** — QoS fabric deployment, VoIP architecture, cloud networking design, TDM migration advisory
2. **Fractional Enterprise Architect roles** — 2-8 days/month, architecture governance, HLD/LLD, technology strategy
3. **Full-time roles** — Infrastructure Architect, Cloud Platform Architect, or Enterprise Architect at organisations where infrastructure quality matters
4. **VoxFlow customers** — Organisations that need guaranteed voice quality and are willing to pay for it

---

## How to Work With Me

**Consulting:** brett@btfm.uk — I typically respond within 24 hours. Mention what problem you're trying to solve.

**VoxFlow/InfraForesight:** infraforesight.com or hello@infraforesight.com

**LinkedIn:** Connect and send a note. I respond to everyone who isn't an automated recruiter message.

**My commitment:** If you have a latency-sensitive workload crossing cloud boundaries, I will tell you honestly whether I can help. If I can't, I'll tell you who can.

---

*"I built InfraForesight because I kept hitting the same wall: the QoS stops at the cloud boundary. Every enterprise with latency-sensitive workloads deserves deterministic quality — not best-effort hope."* — Brett Moore
