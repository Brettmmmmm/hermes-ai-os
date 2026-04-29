# CV Tailoring Guide — Brett Moore

> This guide helps you tailor your CV for specific job applications. Read before every application. Generic CVs get binned — targeted ones get calls.

---

## Professional Summary Template

Use this as your opening paragraph. Swap the bolded sections based on the role.

### Master Template

```
{{ROLE_TITLE}} with 30 years delivering enterprise infrastructure across
{{SECTOR}}. CCIE-certified in QoS — one of the rarest networking certifications
globally. Proven track record designing and operating {{SCALE}} deployments
including {{SIGNATURE_PROJECT}}. Deep expertise in {{PRIMARY_TECH_STACK}}.
Currently building {{RELEVANT_SIDE_PROJECT}} — {{SIDE_PROJECT_ONE_LINE}}.
Seeking {{ROLE_TYPE}} position where I can {{VALUE_PROPOSITION}}.

```

### Fill-in Options by Role Type

| Field | Cloud Architect | VoIP/UCaaS Architect | DevOps/SRE Lead | Enterprise Architect |
|-------|----------------|---------------------|-----------------|---------------------|
| SECTOR | financial services, telecoms, and SaaS | telecommunications and contact centres | SaaS, fintech, and cloud-native environments | FTSE 250, telecoms, and public sector |
| SCALE | national-scale | carrier-grade | production-critical (99.99% SLA) | multi-million-pound transformation programmes |
| SIGNATURE PROJECT | O2's national TDM-to-VoIP migration | O2's national TDM-to-VoIP migration + InfraForesight QoS Fabric | InfraForesight QoS Fabric (multi-cloud, Kubernetes) | O2's TDM-to-VoIP programme; multi-cloud architecture for InfraForesight |
| PRIMARY TECH STACK | AWS, Azure, GCP, Kubernetes, Terraform, Cilium, eBPF | SIP, RTP, FreeSWITCH, Kamailio, WebRTC, DSCP QoS, SBCs | Kubernetes, ArgoCD, Helm, Terraform, Prometheus, Cilium, eBPF | TOGAF, ArchiMate, MPLS, SD-WAN, multi-cloud, QoS, HLD/LLD |
| RELEVANT SIDE PROJECT | InfraForesight — QoS Fabric for cross-cloud traffic engineering | VoxFlow — QoS-aware CPaaS with end-to-end DSCP enforcement | InfraForesight — built CI/CD pipeline for 9-service K8s platform | InfraForesight/VoxFlow — built from HLD through to production |
| SIDE_PROJECT_ONE_LINE | cross-cloud traffic engineering platform with contractual SLA measurement | the only CPaaS platform with deterministic QoS from socket to CPE | automated deployment and monitoring of a multi-cloud QoS platform | end-to-end architecture from business case through to operations |
| ROLE_TYPE | a senior cloud architecture | a senior VoIP/UCaaS architecture | a technical leadership | an enterprise architecture |
| VALUE_PROPOSITION | bring deep network-to-cloud QoS expertise that cloud-native architects typically lack | bridge telecoms-grade QoS with modern cloud-native VoIP delivery | embed production engineering rigour with deep infrastructure understanding | translate complex infrastructure decisions into business-outcome architecture |

---

## Core Skills Matrix

### What to Emphasise by Role Type

This table tells you which skills to lead with, which to mention, and which to leave out entirely.

| Skill | Infrastructure Architect | Cloud Platform Architect | DevOps/SRE Lead | Enterprise Architect | VoIP/UCaaS Architect | AI/ML Infra Engineer |
|-------|:---:|:---:|:---:|:---:|:---:|:---:|
| Cross-cloud QoS / DSCP | LEAD | LEAD | Secondary | LEAD | LEAD | LEAD |
| eBPF / Cilium | Secondary | LEAD | LEAD | Mention | Mention | LEAD |
| MPLS / SD-WAN | LEAD | Secondary | — | LEAD | Mention | Secondary |
| Kubernetes | Secondary | LEAD | LEAD | Mention | Secondary | LEAD |
| Terraform / IaC | Secondary | LEAD | LEAD | — | Secondary | LEAD |
| FreeSWITCH / Kamailio | — | — | — | — | LEAD | — |
| SIP / RTP / WebRTC | Mention | — | — | Mention | LEAD | — |
| TOGAF / ArchiMate | Mention | — | — | LEAD | — | — |
| CCIE QoS | LEAD | LEAD | Secondary | LEAD | LEAD | Secondary |
| HLD / LLD Design | LEAD | LEAD | — | LEAD | LEAD | Secondary |
| CI/CD Pipelines | — | Secondary | LEAD | — | Secondary | Secondary |
| Observability (Prometheus/Grafana) | Secondary | Secondary | LEAD | Mention | Secondary | LEAD |
| Python / Golang | — | Secondary | Secondary | — | — | Secondary |
| Contact Centre (Genesys/Amazon Connect) | Secondary | — | — | Secondary | LEAD | — |
| TimescaleDB / PostgreSQL | — | Secondary | Secondary | — | Mention | Secondary |
| GCP Application Awareness | Secondary | Secondary | — | Secondary | Note | Secondary |
| BGP / Routing | LEAD | Secondary | — | LEAD | Secondary | — |
| Regulatory compliance (FCA/MiFID) | Secondary | Mention | — | LEAD | — | — |

**Key:** LEAD = Make this one of the first things they see. Secondary = Include but don't lead. Mention = One line, contextual only. — = Don't waste space.

---

## Experience Bullet Rewriter

### Methodology

For each bullet on your CV, decide: what does THIS hiring manager care about?

Rule of thumb: rewrite every bullet to answer "so what?" for the specific role. A VoIP architect doesn't care about your Terraform module structure. A DevOps lead doesn't care about your SIP routing logic.

### Rewrite Process

1. Write the generic bullet (what you actually did)
2. Identify the role-specific lens (what they care about)
3. Rewrite using their terminology and their success metrics

---

## Before/After Examples

### Example 1: Generic → Cloud Architect

**Generic bullet (what you wrote):**

> Designed and deployed QoS policies across the network to prioritise voice traffic.

**Cloud Architect rewrite:**

> Designed cross-cloud QoS enforcement architecture spanning AWS Direct Connect and Azure ExpressRoute with five-layer DSCP marking (socket → kernel → eBPF → cloud interconnect → CPE), delivering guaranteed EF priority for latency-sensitive workloads under congestion.

**Why this works:** The cloud architect hiring manager hears: "This person understands cloud networking, not just on-prem QoS. They can design across providers. They know eBPF. They think in layers."

---

### Example 2: Generic → VoIP/UCaaS Architect

**Generic bullet (same starting point):**

> Designed and deployed QoS policies across the network to prioritise voice traffic.

**VoIP/UCaaS Architect rewrite:**

> Architected end-to-end QoS for carrier-grade VoIP — enforced DSCP EF marking from FreeSWITCH media servers through Kamailio SIP routers, kernel tc HTB queuing, and automated Cisco MQC CPE policies — delivering MOS 4.2+ across 10,000+ concurrent sessions.

**Why this works:** The VoIP architect hiring manager hears: "This person speaks VoIP — FreeSWITCH, Kamailio, MOS scores. They understand what good voice quality means at scale. They don't just know QoS theory — they've applied it to voice specifically."

---

### Example 3: Generic → DevOps/SRE Lead

**Generic bullet:**

> Migrated legacy on-premise infrastructure to cloud platforms.

**DevOps/SRE Lead rewrite:**

> Led migration of 30+ services from bare-metal to multi-cloud Kubernetes (AWS EKS, Azure AKS, GCP GKE) with GitOps-driven deployment via ArgoCD, infrastructure-as-code via Terraform, and zero-downtime cutover verified by Prometheus SLO monitoring.

**Why this works:** Tools, numbers, methodology. DevOps leads hire on specific stack knowledge and evidence of production rigour. "Cloud platforms" is too vague — name the services.

---

### Example 4: Generic → Enterprise Architect

**Generic bullet:**

> Delivered infrastructure roadmaps for clients.

**Enterprise Architect rewrite:**

> Defined 3-year infrastructure strategy for £40M transformation programme — ArchiMate-modelled AS-IS/TO-BE states, TOGAF ADM governance, technology radar refresh, and C-suite quarterly steering. Programme delivered 23% opex reduction against board commitment.

**Why this works:** Enterprise architects are hired on governance, methodology, and business impact. Show frameworks, show financial impact, show you operate at board level.

---

## Project Highlight Selector

Pick the right project to feature prominently based on the role. Don't list all projects — lead with the one that's most relevant.

| Project | Best for These Roles | Lead With |
|---------|---------------------|-----------|
| **O2 National VoIP Migration** | Enterprise Architect, VoIP/UCaaS Architect, Infrastructure Architect | "Led the architectural design of O2's national TDM-to-VoIP migration programme affecting 500+ enterprise customers. Designed SIP trunking architecture, QoS model, and migration factory process." |
| **InfraForesight QoS Fabric** | Cloud Platform Architect, Infrastructure Architect, AI/ML Infra Engineer | "Built InfraForesight — a cross-cloud traffic engineering platform with five-layer QoS enforcement. Deployed across AWS/Azure/GCP with contractual SLA measurement." |
| **VoxFlow CPaaS** | VoIP/UCaaS Architect, DevOps/SRE Lead | "Architected and built VoxFlow — a QoS-aware CPaaS platform (9 microservices, multi-cloud K8s) — the only CPaaS with end-to-end DSCP enforcement." |
| **Hermes AI OS** | AI/ML Infra Engineer, DevOps/SRE Lead | "Designed Hermes AI OS — a configuration-driven multi-agent orchestration system with skill routing, domain-specific models, and structured output policy." |
| **Fractional EA Advisory** | Enterprise Architect | "Fractional Enterprise Architect for multiple organisations — delivering TOGAF-aligned architecture governance, HLD/LLD design, and technology strategy at board level." |

---

## Quick Tailoring Checklist

Before submitting, verify:

- [ ] Professional summary mentions the exact role title somewhere
- [ ] Top 3 skills in the skills section match the top 3 in the job description
- [ ] First project highlighted is the most relevant one (see selector above)
- [ ] At least 2 bullet points use the hiring manager's terminology (not generic)
- [ ] The CCIE credential is visible in the first third of the CV (it's rare, don't bury it)
- [ ] Any mention of "30 years experience" is paired with a specific modern technology in the same sentence (avoids "old-school" perception)
- [ ] Contact details: brett@btfm.uk, GitHub: github.com/Brettmmmmm, Northampton UK

---

## Anti-Patterns — What NOT To Do

- ❌ "I have 30 years of experience in IT infrastructure." — Generic. Reads as "I'm old."
- ❌ Listing every technology you've ever touched. The CV is a highlight reel, not an inventory.
- ❌ "Responsible for..." — Passive, bureaucratic. Use "Designed...", "Built...", "Led..."
- ❌ Bullet points longer than 2 lines. If it takes 3 lines, split it into 2 bullets.
- ❌ "Team player with excellent communication skills." — Every CV says this. Prove it with examples instead.
- ❌ 4-page CV. Keep it to 2 pages (3 absolute max for EA roles). You're not a graduate — nobody reads past page 2.

---

*Use this guide for every application. Spending 15 minutes tailoring a CV increases callback rate by 400%. Not doing it is the most expensive time-save you'll ever make.*
