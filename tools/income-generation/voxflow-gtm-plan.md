# VoxFlow Go-to-Market Plan

> v0.1 — April 2026. This is the initial GTM framework for VoxFlow,
> the QoS-aware CPaaS built on the InfraForesight platform.
> Review and update quarterly.

---

## 1. Target Market Sizing

### Addressable Market

| Segment | Market Size (Global) | VoxFlow TAM | Rationale |
|---------|---------------------|-------------|-----------|
| CPaaS API (voice/SMS) | $12B (2026 est.) | $1.2B | QoS-differentiated API calls — 10% of CPaaS market will pay premium for guaranteed quality |
| UCaaS (enterprise voice) | $55B | $2.7B | Enterprise voice teams that need Teams Direct Routing + QoS — 5% of UCaaS market |
| Contact Centre (CCaaS) | $15B | $750M | Contact centres where voice quality drives revenue — 5% of CCaaS |
| IoT / M2M Voice | $3B | $300M | Voice-enabled IoT (lift alarms, emergency comms) — 10% of M2M voice |
| **Total Addressable Market** | **~$85B** | **~$4.95B** | Conservative estimate of QoS-sensitive segments |

### Beachhead Market (Year 1 Focus)

| Segment | Geography | Why |
|---------|-----------|-----|
| VoIP operators needing cloud migration | UK & Ireland | Brett's network, O2 experience, regulatory familiarity |
| Contact centres (100-500 seats) | UK | High voice quality sensitivity, measurable ROI |
| Fintech with voice features | London | Proximity, quality expectations, regulatory drivers |
| Teams Direct Routing resellers | UK/Europe | Channel partner play, Microsoft ecosystem adjacency |

### Year 1 Revenue Target

- Conservative: £120K ARR (5 enterprise customers at average £2K/mo)
- Ambitious: £500K ARR (20 enterprise + 2 large contact centres)
- Model: VoxFlow minutes + per-agent/month + setup fees

---

## 2. Competitive Positioning

### Positioning Statement

> VoxFlow is the only CPaaS that guarantees voice quality with contractual MOS SLAs — because it's the only CPaaS built on a cross-cloud QoS fabric.

### Competitor Comparison

| | VoxFlow | Twilio | Vonage (Ericsson) | MessageBird | 8x8 |
|--|---------|--------|-------------------|-------------|-----|
| **Core offering** | QoS-aware CPaaS | General CPaaS | CPaaS + UCaaS | Omnichannel CPaaS | UCaaS + CCaaS |
| **End-to-end DSCP QoS** | ✅ Full enforcement | ❌ Best-effort | ❌ Best-effort | ❌ Best-effort | ❌ Limited (own network only) |
| **MOS SLA** | ✅ Contractual | ❌ No voice quality SLA | ❌ Uptime only | ❌ No voice quality SLA | ❌ No voice quality SLA |
| **WhatsApp Voice** | ✅ | ✅ | ❌ | ✅ (via acquisition) | ❌ |
| **RCS Rich Messaging** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Teams Direct Routing** | ✅ | ❌ | Partial (via Ericsson) | ❌ | Partial |
| **Real-time AI (STT/Sentiment)** | ✅ Built-in | Partial (add-ons) | Partial | Partial | Limited |
| **Per-tenant QoS profiles** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Multi-cloud** | ✅ AWS+Azure+GCP | AWS primarily | Multiple | Multiple | Own infrastructure |
| **Per-minute voice** | £0.008/min (Standard) | £0.013/min | £0.012/min | £0.010/min | Bundled |
| **Revenue (approx)** | Pre-revenue | $4.5B | $1.6B | ~$500M | $750M |

### Competitive Advantages (Why We Win)

1. **QoS is the moat.** Nobody else has end-to-end DSCP enforcement. Building it requires deep networking knowledge + CCIE-level QoS expertise + multi-cloud engineering. The barrier to replication is high.

2. **Regulatory/compliance pull.** FCA, HIPAA, MiFID II environments need provable voice quality. VoxFlow provides audit-ready QoS logs. Competitors provide "trust us."

3. **Vertical specialisation over horizontal scale.** We don't need to compete with Twilio on SMS API pricing. We compete on voice quality for use cases where quality matters — trading floors, ambulance dispatch, premium contact centres.

4. **Single-vendor stack.** QoS fabric + CPaaS + AI from one provider. Competitors require cobbling together 3+ vendors.

### Competitive Disadvantages (Honest Assessment)

- No brand recognition. Twilio is a verb.
- Small team. Can't match feature velocity of 1,000-engineer organisations.
- No direct carrier interconnects yet. Minutes cost more initially.
- No existing customer base for case studies/social proof.

---

## 3. Pricing Strategy

### Core Pricing: Value-Based, Not Cost-Plus

Don't compete on per-minute price. Compete on quality guarantee.

| Tier | Target Customer | Price | What's Included |
|------|----------------|-------|-----------------|
| **Developer** | Startups, PoCs | Free (5,000 min/mo) | API access, 5,000 minutes, best-effort QoS, community support |
| **Standard** | SMBs, small contact centres | £0.008/min + £150/agent/mo | Full QoS, MOS monitoring, email support, 99.9% SLA |
| **Premium** | Mid-market, regulated | £0.006/min + £350/agent/mo | Dedicated VPC, custom DSCP, P2 15-min support, 99.95% SLA, AI features |
| **Enterprise** | Large contact centres, trading | Custom annual (£50K+) | Dedicated + on-prem option, full remediation, P1 15-min, 99.99% SLA, fractional EA |

### Pricing Principles

- Per-minute covers variable costs (carrier interconnect, cloud egress)
- Per-agent covers platform costs (AI, monitoring, support)
- Enterprise annual covers dedicated infrastructure + professional services
- Never discount below Standard tier — the QoS guarantee costs real money to deliver
- Bundle AI features (STT, sentiment, assist) into Premium+ — don't nickel-and-dime

### Competitor Price Positioning

| | VoxFlow Standard | Twilio Elastic SIP | Vonage SIP Trunking |
|--|:--|:--|:--|
| Per-minute (UK local) | £0.008 | £0.005-£0.008 | £0.006-£0.010 |
| Per-minute (UK mobile) | £0.025 | £0.018 | £0.020 |
| QoS included | ✅ | ❌ | ❌ |
| MOS SLA | ✅ | ❌ | ❌ |

**Pricing message:** "We're slightly more expensive per minute. We're dramatically cheaper per customer-complaint-about-call-quality."

---

## 4. Channel Strategy

### Direct Sales (Year 1 Primary)

- Founder-led sales. Brett is the product's best salesperson — CCIE + 30 years + O2 story.
- Target: 10-15 customer conversations/month, converting to 2-3 paid trials
- No sales hire until ARR hits £250K

### Channel Partners (Year 1-2)

| Partner Type | Why | Target Partners |
|-------------|-----|-----------------|
| **MSPs with voice practice** | They already have customers who complain about call quality | Exponential-e, GCI, Maintel, 4Com |
| **Teams Direct Routing resellers** | Microsoft ecosystem play; they need QoS differentiation | Pure IP, CallTower, Nuwave |
| **Contact centre consultants** | They specify voice platforms for RFPs | Sabio, IP Integration, Odigo |
| **SD-WAN vendors** | QoS-aware SD-WAN + QoS-aware CPaaS = full stack | Aryaka, Cato Networks (reseller partnerships) |

### Partner Economics

- 15-20% recurring revenue share on referred customers
- Partner-branded QoS monitoring dashboard (white-label)
- Joint go-to-market: "SD-WAN + VoxFlow = guaranteed voice quality end to end"

### Self-Service (Year 2+)

- Developer portal with API docs, SDKs (Python, Node, Go), Postman collection
- Free tier with credit card signup (stripe)
- Self-serve upgrades: Standard → Premium from dashboard
- Content marketing: "Why your VoIP API needs QoS" blog series

---

## 5. 90-Day Launch Plan

### Days 1-30: Foundation

| Activity | Owner | Success Metric |
|----------|-------|---------------|
| Finalise API documentation and OpenAPI spec | Engineering | Dev portal live with 3 SDK examples |
| Complete FreeSWITCH + Kamailio QoS integration test | Engineering | End-to-end call with verified DSCP marking at all 5 layers |
| Set up Stripe billing (tiers, invoicing) | Brett | Can process a Standard subscription end-to-end |
| Create demo environment (3 scenarios: VoIP operator, contact centre, trading) | Engineering | 15-minute demo walkthrough ready |
| Publish 3 LinkedIn posts (Post 1, 2, 7 from linkedin-content.md) | Brett | 3 posts live, 1,000+ combined impressions |
| Identify 20 target companies for direct outreach | Brett | 20 companies in CRM with decision-maker names |

### Days 31-60: Early Pipeline

| Activity | Owner | Success Metric |
|----------|-------|---------------|
| Reach out to 20 target companies | Brett | 10 conversations booked |
| Deliver 5 VoxFlow demos | Brett | 3 positive follow-ups (trial request or deeper discussion) |
| Launch free developer tier | Engineering | 20 developer signups |
| Write 2 case-study-style blog posts (O2 migration, contact centre QoS story) | Brett | Published on infraforesight.com/blog |
| Approach 5 MSPs for partnership conversations | Brett | 2 partnership discussions advanced |
| Set up PagerDuty + alerting for production monitoring | Engineering | P1/P2 alert flow tested |

### Days 61-90: First Revenue

| Activity | Owner | Success Metric |
|----------|-------|---------------|
| Convert 2-3 trials to paid Standard/Premium | Brett | First paying customers (target: £2K/mo ARR) |
| Document QoS enforcement for first customer (case study material) | Brett | 1 published case study with customer permission |
| Iterate pricing based on first customer feedback | Brett | Pricing page updated |
| Publish 6 LinkedIn posts during this period | Brett | Consistent posting cadence (2x/week) |
| Attend 1 industry event (UC Expo, Comms Council UK, or similar) | Brett | 10+ new contacts |
| Review 90-day metrics, plan next 90 days | Brett | GTM plan v0.2 drafted |

### Key Metrics Dashboard (Track Weekly)

| Metric | Week 1 Target | Week 12 Target |
|--------|--------------|----------------|
| LinkedIn profile views/week | 50 | 300 |
| Inbound enquiries/week | 0 | 5 |
| Demos delivered | 0 | 12 (cumulative) |
| Active trials | 0 | 5 |
| Paying customers | 0 | 3 |
| MRR | £0 | £6,000 |
| Partner discussions advanced | 0 | 3 |

---

## 6. Key Partnerships Needed

### Immediate (First 90 Days)

| Partnership | Why | Approach |
|------------|-----|----------|
| **Carrier interconnect provider** | Need competitive termination rates for UK/Europe minutes | BT Wholesale, Gamma, AQL — negotiate wholesale SIP trunk pricing |
| **Microsoft Teams certification** | Teams Direct Routing requires certified SBCs | Partner with an already-certified SBC vendor (AudioCodes, Ribbon, Oracle) for initial offering; pursue direct certification longer term |
| **Payment processor** | Billing, invoicing, subscription management | Stripe (already planned) — set up early, test pricing tiers |

### Medium-Term (6-12 Months)

| Partnership | Why | Approach |
|------------|-----|----------|
| **SD-WAN vendor technical alliance** | "QoS from branch to cloud" joint proposition | Approach Aryaka and Cato Networks — their architecture already has cloud PoPs where VoxFlow could sit |
| **WhatsApp Business API partner** | Already integrated via VoxFlow; formalise | Meta's Business Solution Provider programme — apply, get listed |
| **GCP partner programme** | Cloud credits, marketplace listing, co-marketing | Apply for Google Cloud Partner Advantage; VoxFlow is built on GCP Application Awareness |
| **Contact centre platform integration** | Genesys AppFoundry / Amazon Connect marketplace | Build certified integrations; list VoxFlow as a "QoS voice carrier" option |

### Long-Term (12-24 Months)

| Partnership | Why | Approach |
|------------|-----|----------|
| **System integrator (Accenture, Capgemini, Atos)** | Enterprise deal flow; they win the digital transformation RFP, VoxFlow gets specified in the voice workstream | Build relationships with SIs' telecoms/voice practice leads |
| **AWS/Azure marketplace listing** | Procurement simplicity for enterprise buyers | List VoxFlow on AWS Marketplace and Azure Marketplace; requires SOC2 or equivalent compliance |

---

## 7. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|:---:|:---:|------------|
| No product-market fit — nobody cares about QoS-guaranteed voice | Medium | Critical | Free developer tier lets us test demand with zero customer commitment. Pivot to QoS Fabric infra-only if CPaaS doesn't land. |
| Twilio/Vonage add QoS features | Medium | High | They can't match the networking depth quickly — but they can confuse the market. Build switching costs through custom QoS profiles and audit trails. |
| Single-founder dependency | High | Medium | Brett is the CCIE, the architect, the salesperson, and the brand. Document everything. Identify which functions can be delegated first. |
| Cash burn before revenue | High | High | Keep burn minimal (£3K-£5K/mo cloud costs). Consider fractional EA consulting in parallel for income during build. |
| Regulatory/compliance overhead | Low | Medium | OFCOM general conditions, GDPR, potentially FCA if serving financial services. Engage compliance consultant for audit prep by month 6. |

---

## 8. Key Assumptions to Validate

These assumptions underpin the entire GTM plan. Test early.

1. **Customers will pay a premium for guaranteed voice quality.** Validated by: conversion rate from free tier to Standard, willingness to pay in enterprise conversations.

2. **The six-class DSCP model maps to real customer traffic patterns.** Validated by: trial customer feedback, support ticket volume about classification.

3. **Channel partners will sell a differentiated CPaaS.** Validated by: MSP partnership conversations, first joint pipeline deal.

4. **Developer experience matters more than brand for early adopters.** Validated by: developer signup conversion, time-to-first-call, API docs feedback.

5. **Enterprise buyers will accept a startup as their voice infrastructure provider.** Validated by: enterprise pipeline progression, procurement friction, RFP inclusion rate.

---

*Review this GTM plan monthly. What you learn about the market in month 1 will invalidate half of this document. That's fine — iterate fast.*
