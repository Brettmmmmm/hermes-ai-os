# InfraForesight Consulting Proposal Template

> Use this template for all consulting engagements. Replace `{{VARIABLES}}` with client-specific content. Keep it direct — no consulting waffle.

---

## Proposal: {{ENGAGEMENT_NAME}}

**Prepared for:** {{CLIENT_NAME}}
**Date:** {{PROPOSAL_DATE}}
**Proposal reference:** {{PROPOSAL_REF}}
**Prepared by:** Brett Moore, CCIE — Enterprise Infrastructure Architect

---

## 1. Executive Summary

{{CLIENT_NAME}} is {{ONE_SENTENCE_WHO_ARE_THEY}}. They are experiencing {{CORE_PAIN_POINT_IN_ONE_SENTENCE}}.

This proposal outlines how InfraForesight will {{WHAT_YOU_WILL_DO_IN_ONE_SENTENCE}}, delivering {{PRIMARY_OUTCOME}}.

**Key benefits:**

- {{BENEFIT_1}}
- {{BENEFIT_2}}
- {{BENEFIT_3}}

**Estimated investment:** £{{INVESTMENT_RANGE}} (see Section 7 for tiered options)
**Target completion:** {{TIMELINE}}

---

## 2. Current State Assessment

### {{CURRENT_STATE_HEADING}}

{{DESCRIPTION_OF_EXISTING_SETUP — what infrastructure they have, what's working, what's not}}

### Pain Points Identified

1. **{{PAIN_POINT_1_NAME}}** — {{PAIN_POINT_1_DESCRIPTION}}
2. **{{PAIN_POINT_2_NAME}}** — {{PAIN_POINT_2_DESCRIPTION}}
3. **{{PAIN_POINT_3_NAME}}** — {{PAIN_POINT_3_DESCRIPTION}}

### Business Impact

{{QUANTIFIED_IMPACT — what's this costing them? Revenue loss, SLA misses, regulatory risk, latency dollars}}

---

## 3. Proposed Solution

### Solution Overview

{{HIGH_LEVEL_DESCRIPTION — what we're building}}

This is built on the **InfraForesight QoS Fabric**, a managed cross-cloud traffic engineering platform with five enforcement points and contractual SLA measurement.

### Why This Approach

{{WHY_THIS_ARCHITECTURE — what makes it the right call over alternatives}}

### Architecture Diagram (Conceptual)

```
{{ASCII_OR_MERMAID_ARCHITECTURE_DIAGRAM}}
```

---

## 4. Technical Approach

### Enforcement Points Deployed

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Application Socket | `setsockopt(IP_TOS)` | Mark at source |
| Linux Kernel | tc HTB + u32/flower classifiers | Host-level queuing |
| Kubernetes | Cilium eBPF at pod egress | Container QoS |
| Cloud Interconnect | Provider-specific QoS | Backbone priority |
| Customer CPE | Auto-generated Cisco MQC / Juniper / Arista | Edge enforcement |

### QoS Classification Model

{{CUSTOM_OR_STANDARD_DSCP_MAPPING — use the six-class model unless they need something custom}}

### Integration Points

{{EXISTING_SYSTEMS_WE_MUST_INTEGRATE_WITH — firewalls, SD-WAN, monitoring, ITSM}}

### Monitoring & SLA Framework

- Real-time MOS/R-factor monitoring (ITU-T G.107 E-Model)
- Policy drift detection every 60 seconds
- DSCP re-marking detection at transit boundaries
- Dashboards: Prometheus + Grafana
- Alerting: AlertManager → {{THEIR_INCIDENT_TOOL}}

---

## 5. Deliverables

| # | Deliverable | Description | Acceptance Criteria |
|---|------------|-------------|---------------------|
| 1 | {{DELIVERABLE_1_NAME}} | {{DELIVERABLE_1_DESCRIPTION}} | {{DELIVERABLE_1_CRITERIA}} |
| 2 | {{DELIVERABLE_2_NAME}} | {{DELIVERABLE_2_DESCRIPTION}} | {{DELIVERABLE_2_CRITERIA}} |
| 3 | {{DELIVERABLE_3_NAME}} | {{DELIVERABLE_3_DESCRIPTION}} | {{DELIVERABLE_3_CRITERIA}} |
| 4 | {{DELIVERABLE_4_NAME}} | {{DELIVERABLE_4_DESCRIPTION}} | {{DELIVERABLE_4_CRITERIA}} |
| 5 | {{DELIVERABLE_5_NAME}} | {{DELIVERABLE_5_DESCRIPTION}} | {{DELIVERABLE_5_CRITERIA}} |

---

## 6. Timeline

| Phase | Activity | Duration | Milestone |
|-------|----------|----------|-----------|
| Phase 1 | {{PHASE_1_NAME}} | {{PHASE_1_DURATION}} | {{PHASE_1_MILESTONE}} |
| Phase 2 | {{PHASE_2_NAME}} | {{PHASE_2_DURATION}} | {{PHASE_2_MILESTONE}} |
| Phase 3 | {{PHASE_3_NAME}} | {{PHASE_3_DURATION}} | {{PHASE_3_MILESTONE}} |
| Phase 4 | {{PHASE_4_NAME}} | {{PHASE_4_DURATION}} | {{PHASE_4_MILESTONE}} |

**Total estimated duration:** {{TOTAL_DURATION}} from project kick-off

---

## 7. Investment

### Option 1: {{TIER_1_NAME}} — Recommended

£{{TIER_1_PRICE}} | {{TIER_1_DURATION}}

- {{TIER_1_FEATURE_1}}
- {{TIER_1_FEATURE_2}}
- {{TIER_1_FEATURE_3}}
- SLA: {{TIER_1_SLA}}

### Option 2: {{TIER_2_NAME}}

£{{TIER_2_PRICE}} | {{TIER_2_DURATION}}

- {{TIER_2_FEATURE_1}}
- {{TIER_2_FEATURE_2}}
- {{TIER_2_FEATURE_3}}
- SLA: {{TIER_2_SLA}}

### Option 3: {{TIER_3_NAME}} — Enterprise

Custom annual engagement

- {{TIER_3_FEATURE_1}}
- {{TIER_3_FEATURE_2}}
- {{TIER_3_FEATURE_3}}
- SLA: {{TIER_3_SLA}}

> **Pricing notes:** All prices exclude VAT. Cloud infrastructure costs (compute, transit, interconnect) are billed separately. Payment terms: {{PAYMENT_TERMS}}.

---

## 8. About InfraForesight

InfraForesight is led by **Brett Moore**, one of a handful of engineers worldwide holding CCIE certification in QoS. Brett has:

- **30 years** in enterprise infrastructure engineering
- **10 years** as Enterprise Architect designing HLD/LLD for national-scale deployments
- Designed O2's **national TDM-to-VoIP migration** for all enterprise customers
- Built the **InfraForesight QoS Fabric** — the only cross-cloud traffic engineering platform with contractual application-layer SLAs
- Expertise spanning: MPLS, SD-WAN, contact centres, Kubernetes networking, eBPF, multi-cloud VoIP, and UCaaS

InfraForesight exists because enterprises with latency-sensitive workloads deserve deterministic quality across cloud boundaries — not "best effort and hope."

**Contact:** brett@btfm.uk | infraforesight.com

---

## 9. Next Steps

1. **{{NEXT_STEP_1}}** — {{NEXT_STEP_1_ACTION}}
2. **{{NEXT_STEP_2}}** — {{NEXT_STEP_2_ACTION}}
3. **{{NEXT_STEP_3}}** — {{NEXT_STEP_3_ACTION}}

To accept this proposal, {{ACCEPTANCE_INSTRUCTIONS}}.

---

*© {{CURRENT_YEAR}} InfraForesight. Confidential — prepared exclusively for {{CLIENT_NAME}}.*

---

---

---

# EXAMPLE: Filled-Out Proposal

> This is a real-feeling example showing how the template renders when filled in.

---

## Proposal: QoS Fabric Implementation for Financial Trading Firm

**Prepared for:** Meridian Capital Markets LLP
**Date:** 29 April 2026
**Proposal reference:** IF-PROP-2026-0429-MCM
**Prepared by:** Brett Moore, CCIE — Enterprise Infrastructure Architect

---

## 1. Executive Summary

Meridian Capital Markets LLP is a London-based algorithmic trading firm executing ~200,000 orders/day across European equity and FX markets. They are experiencing unpredictable latency spikes during market-open congestion that cause order-flow jitter exceeding their 50-microsecond tolerance.

This proposal outlines how InfraForesight will deploy the QoS Fabric across Meridian's AWS trading infrastructure and Equinix LD4 colocation, delivering deterministic sub-50μs jitter on order flow with contractual enforcement and continuous measurement.

**Key benefits:**

- Order flow (EF priority) isolated from market data, analytics, and bulk traffic — guaranteed wire-speed priority under congestion
- Continuous jitter measurement with per-flow granularity via QoS probes — no more "users reported it"
- FCA-compliant audit trail proving best-execution infrastructure quality
- Zero trading application changes required — DSCP marking operates below the application layer

**Estimated investment:** £65,000–£180,000 (see Section 7 for tiered options)
**Target completion:** 8–12 weeks

---

## 2. Current State Assessment

### Existing Infrastructure

Meridian runs a colocated trading stack at Equinix LD4 with Arista 7280R switches, AWS us-east-1 for backtesting and analytics, and a 10 Gbps AWS Direct Connect between them. Trading applications are C++ running on bare-metal Linux. Market data arrives via Solace pub/sub. Order flow goes through Ullink gateways to exchange matching engines.

### Pain Points Identified

1. **No cloud-side QoS** — AWS Direct Connect preserves DSCP bits but AWS does not act on them. When backtesting jobs saturate the Direct Connect link, order flow packets queue behind bulk data transfers.
2. **No jitter measurement** — Meridian has PTP-synchronised timestamping on the trading engine but no in-path QoS telemetry. When latency spikes, they cannot determine whether the cause is network, application, or exchange-side.
3. **Manual CPE QoS config** — Arista QoS policies on the LD4 switches are hand-maintained. When they add a new trading strategy (new IP/port), someone must remember to update the QoS ACL. This has been missed twice in the last quarter.

### Business Impact

At Meridian's average trade value of £85,000 with a 2.3bp capture rate, every millisecond of excess latency above the 50μs threshold costs approximately £195 per trade in adverse selection. During the March 2026 market-open congestion event (which lasted 18 minutes), estimated slippage was £47,000.

---

## 3. Proposed Solution

### Solution Overview

Deploy the InfraForesight QoS Fabric across Meridian's trading infrastructure with three enforcement points:
- **Layer 2 — Linux kernel:** tc HTB qdisc with u32 classifiers on each trading host, enforcing EF strict-priority for order flow
- **Layer 4 — Cloud interconnect:** QoS-aware Direct Connect with per-class bandwidth guarantees
- **Layer 5 — Customer CPE:** Auto-generated Arista MQC policies with automated drift detection and remediation

This is built on the InfraForesight QoS Fabric, a managed cross-cloud traffic engineering platform with contractual SLA measurement.

### Why This Approach

- Meridian cannot move their trading engine (bare-metal, latency-sensitive, FCA-regulated location)
- Adding application-level QoS awareness would require trading code changes — weeks of dev + regression testing
- InfraForesight operates below the application — `setsockopt(IP_TOS)` marking is done via system-level configuration, not code changes
- The auto-generated CPE config eliminates the "forgot to update the ACL" failure mode
- Continuous jitter measurement with per-flow granularity gives Meridian something they've never had: proof

---

## 4. Technical Approach

### Enforcement Points Deployed

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Application Socket | `setsockopt(IP_TOS)` via LD_PRELOAD wrapper | Mark order flow packets EF (46) at socket creation |
| Linux Kernel | tc HTB + u32 classifiers on trading hosts | Host-level strict-priority queuing for EF traffic |
| Cloud Interconnect | AWS Direct Connect with per-QoS-queue shaping | Prevent backtesting traffic from queueing behind order flow |
| Customer CPE | Auto-generated Arista MQC policies | Edge enforcement with automated drift detection |

### QoS Classification Model

| Class | DSCP | Application | BW Guarantee |
|-------|------|-------------|-------------|
| Real-Time Critical (EF) | 46 | Order flow, execution acknowledgements | Strict priority, 20% cap |
| Real-Time Standard (AF41) | 34 | Market data feeds (L1/L2) | CBWFQ 40% |
| Signaling (CS3) | 24 | Session setup, FIX session heartbeats | CBWFQ 10% |
| Transactional (AF31) | 26 | Trade confirmations, clearing messages | CBWFQ 10% |
| Interactive (AF21) | 18 | ML pricing models, risk calculations | CBWFQ 10% |
| Best Effort (BE) | 0 | Backtesting, analytics, logs | WFQ remaining |

### Integration Points

- **Arista 7280R switches at LD4** — QoS Fabric pushes config via eAPI
- **AWS Direct Connect** — QoS Fabric manages per-class bandwidth shaping via AWS API
- **Existing monitoring** — Feed into Meridian's Grafana instance; AlertManager → PagerDuty
- **FCA compliance** — QoS Fabric provides tamper-evident QoS audit logs with SHA-256 chain of custody

### Monitoring & SLA Framework

- Per-flow jitter measurement with PTP-correlated timestamps at 100ms granularity
- Policy drift detection every 60 seconds — SHA-256 hash of switch QoS config vs known-good
- Auto-remediation: if drift detected, re-push known-good config within 30 seconds
- SLA: EF-class jitter ≤ 50μs for 99.95% of 5-minute windows (measured, contractual)

---

## 5. Deliverables

| # | Deliverable | Description | Acceptance Criteria |
|---|------------|-------------|---------------------|
| 1 | QoS Fabric HLD | High-level design covering all four enforcement points, classification model, and SLA framework | Signed off by Meridian Head of Infrastructure and CTO |
| 2 | Kernel QoS deployment | tc HTB + u32 classifier rollout across 24 trading hosts (LD4 + AWS) | `tc -s qdisc show` verifies HTB hierarchy; EF class shows 0 drops under load test |
| 3 | CPE automation pipeline | Auto-generated Arista MQC policies + eAPI push pipeline + drift detection | Policy applies within 60s of source-of-truth change; drift auto-remediates within 30s |
| 4 | Monitoring & SLA dashboard | Grafana dashboards for per-flow jitter, class utilisation, drift events | Dashboards accessible; AlertManager fires test alert → PagerDuty |
| 5 | Operational handover | Documentation, runbooks, training session for Meridian ops team | Ops team can add a new trading strategy to QoS classification without InfraForesight assistance |
| 6 | FCA audit pack | Tamper-evident QoS logs with chain-of-custody for best-execution compliance | Audit pack passes mock FCA desk review |

---

## 6. Timeline

| Phase | Activity | Duration | Milestone |
|-------|----------|----------|-----------|
| Phase 1 | Discovery & HLD | Weeks 1–2 | HLD signed off |
| Phase 2 | Kernel QoS + CPE pipeline build | Weeks 3–5 | Pipeline deploying to test switch |
| Phase 3 | Staging deployment & load test | Weeks 6–7 | Load test: 0 EF drops at 2x peak order flow |
| Phase 4 | Production rollout (LD4 then AWS) | Weeks 8–10 | All 24 hosts + 4 switches live |
| Phase 5 | Monitoring, handover, audit pack | Weeks 11–12 | Operations handover complete |

**Total estimated duration:** 12 weeks from project kick-off

---

## 7. Investment

### Option 1: Core QoS Fabric — Recommended

£65,000 | Fixed price — 12 weeks

- All 6 deliverables listed in Section 5
- 4 enforcement points (socket, kernel, interconnect, CPE)
- Drift detection + alerting (no auto-remediation)
- SLA: EF jitter ≤ 50μs, alerting only (P2, 1-hour response)
- 30 days post-go-live support

### Option 2: QoS Fabric + Auto-Remediation

£115,000 | Fixed price — 14 weeks

- Everything in Option 1, plus:
- Auto-remediation within 30 seconds of policy drift detection
- SLA: 99.95% (P2, 15-minute response, auto-remediate)
- 90 days post-go-live support
- Quarterly QoS health check for 12 months

### Option 3: QoS Fabric Enterprise — Embedded

£180,000/year | Annual engagement

- Everything in Option 2, plus:
- Dedicated QoS Fabric instance (not shared tenancy)
- Custom DSCP classification model (up to 12 classes)
- SLA: 99.99% (P1, 15-minute response, auto-remediate)
- Brett Moore as fractional EA — 4 days/month embedded with Meridian architecture team
- Priority feature requests for QoS Fabric roadmap

> **Pricing notes:** All prices exclude VAT. AWS Direct Connect and Equinix cross-connect costs are billed separately. Payment terms: 30% on signing, 40% at staging sign-off, 30% on production go-live.

---

## 8. About InfraForesight

InfraForesight is led by **Brett Moore**, one of a handful of engineers worldwide holding CCIE certification in QoS. Brett has:

- **30 years** in enterprise infrastructure engineering
- **10 years** as Enterprise Architect designing HLD/LLD for national-scale deployments
- Designed O2's **national TDM-to-VoIP migration** for all enterprise customers
- Built the **InfraForesight QoS Fabric** — the only cross-cloud traffic engineering platform with contractual application-layer SLAs
- Expertise spanning: MPLS, SD-WAN, contact centres, Kubernetes networking, eBPF, multi-cloud VoIP, and UCaaS

InfraForesight exists because enterprises with latency-sensitive workloads deserve deterministic quality across cloud boundaries — not "best effort and hope."

**Contact:** brett@btfm.uk | infraforesight.com

---

## 9. Next Steps

1. **Discovery Workshop (2 hours)** — Brett walks through the QoS Fabric with Meridian's infrastructure team, maps traffic flows, confirms classification model. No cost, no commitment.
2. **Paid Proof of Concept (1 week, £4,500)** — Deploy kernel QoS + monitoring on 2 trading hosts at LD4. Measure before/after jitter under production load. If results don't meet the 50μs target, Meridian pays nothing further.
3. **Contract & Kick-off** — If PoC succeeds, sign full engagement and schedule Phase 1 start.

To accept this proposal, email brett@btfm.uk with the subject "IF-PROP-2026-0429-MCM ACCEPTED" and your preferred tier.

---

*© 2026 InfraForesight. Confidential — prepared exclusively for Meridian Capital Markets LLP.*
