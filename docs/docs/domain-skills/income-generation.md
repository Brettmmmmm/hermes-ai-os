# Income Generation Skill

## Purpose

The `income-generation` skill is the revenue engine for Hermes AI OS. It automates everything that generates income: consulting proposals, job matching and applications, CV optimization, competitive intelligence, personal brand building, and go-to-market automation for VoxFlow/InfraForesight.

## Brett's Value Proposition

Brett Moore — Enterprise Infrastructure Architect — is hired for:

1. **QoS Architecture** — Cross-vendor DSCP policy translation, SLA enforcement at network layer
2. **Multi-Cloud Infrastructure** — AWS/Azure/GCP with Pulumi IaC, cross-cloud VPN mesh
3. **VoIP/CPaaS Systems** — FreeSWITCH, Kamailio, SIP, WebRTC, HEP capture
4. **AI/ML Operations** — Ollama, multi-model orchestration, agent-based automation
5. **Observability** — Grafana, TimescaleDB, Vector, eBPF monitoring
6. **Enterprise Architecture** — TOGAF, capability-based planning, ADRs

## When to Use

- Generate consulting proposals from capability descriptions
- Match job listings to Brett's profile with scoring
- Tailor CVs for specific roles
- Research companies (funding, tech stack, culture)
- Generate personal brand assets (portfolio, capability statements)
- Competitive intelligence for VoxFlow go-to-market
- Pricing model analysis for CPaaS offerings

## Inputs

| Input | Type | Required | Description |
|-------|------|----------|-------------|
| `task` | string | yes | One of: `proposal`, `match`, `tailor-cv`, `company-research`, `brand-assets`, `competitive-intel`, `pricing-analysis` |
| `client` | string | for `proposal` | Client name |
| `need` | string | for `proposal` | Client's stated need or problem |
| `jobs` | string | for `match` | Job listing text or scan results |
| `cv_context` | string | for `match`, `tailor-cv` | Role focus (e.g., "enterprise architect", "cloud platform lead") |
| `role` | string | no | Specific target role |
| `company` | string | for `company-research` | Company name |
| `url` | string | no | Job listing or company URL |

## Outputs

All outputs follow the enforced structure: **Opportunity → Analysis → Recommendation → Action Plan → Metrics**

### Consulting Proposal Output
- Executive summary (2-3 sentences)
- Current state assessment
- Proposed solution (architecture, approach)
- Technical methodology and timeline
- Deliverables list
- Phased investment projection
- About InfraForesight section

### Job Match Output
- Role match score (with breakdown)
- Tech stack alignment assessment
- Key qualifications overlap
- Gaps to address in CV
- Recommended application strategy
- Company context (if researched)

### CV Tailoring Output
- Updated professional summary (mirrors job language)
- Reordered skills section
- Reframed experience bullets
- Adjusted project highlights

## Policy

- **Personality:** analyst
- **Default Model:** ollama:kimi-k2.6:cloud
- **Output Format:** markdown
- **Required Structure:** Opportunity → Analysis → Recommendation → Action Plan → Metrics
- Proposals are client-specific, not template garbage
- Job matches include rationale, not just keyword hits
- CV changes are justified by job requirements
- Competitive intelligence is actionable, not just data dumps

## Example Usage

```bash
# Generate a consulting proposal
hermes run --skill income-generation \
  --input '{
    "task": "proposal",
    "client": "TelecomCo",
    "need": "QoS policy federation across AWS, Azure, and GCP for enterprise UCaaS"
  }'

# Match job listings against profile
hermes run --skill income-generation \
  --input '{
    "task": "match",
    "jobs": "<paste job listings>",
    "cv_context": "enterprise infrastructure architect"
  }'

# Tailor CV for a specific role
hermes run --skill income-generation \
  --input '{
    "task": "tailor-cv",
    "role": "Lead Cloud Platform Architect",
    "cv_context": "multi-cloud kubernetes pulumi"
  }'

# Research a company before applying
hermes run --skill income-generation \
  --input '{
    "task": "company-research",
    "company": "AcmeCorp"
  }'

# Competitive intelligence for VoxFlow
hermes run --skill income-generation \
  --input '{
    "task": "competitive-intel",
    "scope": "CPaaS QoS offerings"
  }'
```

## Job Scoring Criteria

| Criterion | Weight | How Scored |
|-----------|--------|------------|
| Role match | 30% | Title keyword alignment |
| Tech stack match | 25% | AWS, K8s, Pulumi, SIP, Grafana overlap |
| Location/Remote | 20% | UK/EU remote-friendly |
| Seniority level | 15% | Lead/Principal/Architect level |
| Industry fit | 10% | Telecom, CPaaS, Enterprise SaaS |

## Target Roles

- Senior/Lead Infrastructure Architect
- Cloud Platform Architect (AWS/Azure/GCP)
- DevOps/SRE Lead
- Enterprise Architect
- VoIP/UCaaS Platform Architect
- AI/ML Infrastructure Engineer
- CPaaS Technical Lead
