# LinkedIn Content Templates — Brett Moore

> 10 post templates for building Brett's professional brand.
> Post 2-3 times/week. Consistency beats perfection.
> Every post should either teach something, share a war story, or start a conversation.

---

## Post 1: Thought Leadership — Why QoS Still Matters in the Cloud Era

**Headline:** Your cloud provider preserves your DSCP bits. It doesn't act on them.

**Body:**

Here's something most cloud architects don't know until it bites them:

AWS preserves DSCP markings on your packets. Doesn't act on them.
Azure enforces DSCP — but only for Teams on Microsoft Peering.
GCP has "Application Awareness" — but you need to know how to configure it.

Every other packet? Best-effort. Competing with bulk data.

I spent 30 years designing QoS for carrier networks. Then I tried to do it in the cloud and hit a wall. That's why I built InfraForesight — a cross-cloud QoS fabric that actually enforces your traffic prioritisation.

The uncomfortable truth: cloud providers commoditised networking. They abstracted away the knobs that enterprise architects need for latency-sensitive workloads.

If your business runs on real-time traffic — voice, trading, SCADA, clinical video — you need to know where your QoS stops and what happens beyond that boundary.

I've written a deep-dive on the five enforcement points (socket → kernel → eBPF → interconnect → CPE). Link in comments.

**Hashtags:** #QoS #CloudArchitecture #NetworkEngineering #DevOps #CCIE

**Image suggestion:** Diagram showing the five enforcement layers with "QoS STOPS HERE" arrows at cloud boundaries.

---

## Post 2: Technical Deep-Dive — eBPF DSCP Marking at 10M+ PPS

**Headline:** How we mark 10 million packets per second with eBPF — and why it matters

**Body:**

At InfraForesight, we use Cilium eBPF to enforce DSCP marking at the Kubernetes pod egress. Here's why this is different from iptables:

iptables: sequential rule evaluation. Performance drops linearly as rules increase.
eBPF: compiled to native bytecode. Runs in kernel context. Constant time.

Our Cilium network policy does three things:
1. Classifies traffic by destination (VoIP → EF, analytics → BE)
2. Marks DSCP in the packet header (setsockopt wrapper in userspace is optional)
3. Exports per-class metrics to Prometheus

Result: 10M+ packets/sec per node with <0.1% CPU overhead.

The key insight: eBPF lets you enforce QoS at the container boundary without touching application code. Your developers don't need to know about TOS bits. The platform handles it.

Here's the architecture diagram and sample Cilium policy manifest → [link]

What are you using for container networking QoS? iptables? Calico? Nothing? I'm curious what the industry is actually running.

**Hashtags:** #eBPF #Cilium #Kubernetes #Networking #CloudNative #QoS

**Image suggestion:** Cilium eBPF flow diagram showing packet classification → DSCP marking → metric export.

---

## Post 3: Case Study — O2 National VoIP Migration

**Headline:** How we migrated 500+ enterprises off TDM to VoIP without dropping a call

**Body:**

In 2015, O2 had a problem: the PSTN was being sunset, and every enterprise customer was still on TDM voice circuits. We had 3 years to move everyone to VoIP.

Scale:
- 500+ enterprise customers
- 10,000+ circuits
- 0 tolerance for voice quality regression

My role: Enterprise Architect for the migration programme.

Three decisions that made it work:
1. **QoS model first** — We designed the six-class DSCP model before buying any kit. Voice got EF strict priority, period.
2. **Migration factory** — We didn't do bespoke per-customer. We built a repeatable process: survey → design → parallel run → cutover → verify. Each customer took 4 weeks, not 6 months.
3. **MOS measurement** — Every call measured. If MOS dropped below 4.0, we rolled back before the customer noticed.

Lesson: large-scale voice migration isn't a technology problem. It's a process design problem. The tech is straightforward if you get the QoS right. The hard part is making it repeatable and measurable.

I applied the same principles building VoxFlow years later — but now with eBPF and Kubernetes.

**Hashtags:** #VoIP #Migration #Telecoms #QoS #EnterpriseArchitecture #UCaaS

**Image suggestion:** Before/after architecture diagram showing TDM stack → VoIP stack with QoS overlay.

---

## Post 4: Industry Commentary — The CPaaS Race to the Bottom

**Headline:** The CPaaS API is a commodity. Quality isn't.

**Body:**

Twilio, Vonage, MessageBird, 8x8 — they're all racing to the bottom on per-minute pricing. £0.004/min. £0.003/min. Soon someone will do £0.001.

But here's what nobody talks about: none of them enforce QoS.

When you make a call through a standard CPaaS:
- Your voice packets compete with bulk API traffic
- Your MOS drops under congestion
- Your "99.99% SLA" covers platform uptime — not call quality

Nobody guarantees voice quality. They guarantee the API responds. That's not the same thing.

At VoxFlow, we built the opposite: a CPaaS that's QoS-first. Every packet classified. Every flow measured. MOS guaranteed by contract.

The market is splitting in two:
- Commodity CPaaS → cheap minutes, best-effort quality (fine for notifications)
- Quality CPaaS → higher cost, guaranteed MOS (essential for revenue-generating calls)

Pick your lane. But know which lane you're in.

**Hashtags:** #CPaaS #VoIP #UCaaS #Telecoms #QoS #VoiceQuality

**Image suggestion:** Split-screen comparison: "Commodity CPaaS" (cheap, best-effort) vs "Quality CPaaS" (priced higher, QoS-guaranteed).

---

## Post 5: Personal Brand — The CCIE QoS Story

**Headline:** I hold one of the rarest networking certifications in the world. Here's why.

**Body:**

Cisco's CCIE is famously difficult. The QoS track? It almost doesn't exist.

There are fewer than 200 active CCIE QoS certifications worldwide. When I earned mine, the lab exam was 8 hours. No internet. No notes. Build a QoS architecture from scratch to spec.

What it taught me:
- QoS isn't a feature. It's a system design discipline.
- You can't bolt it on afterwards. Classify, queue, shape, police — in that order.
- Every hop matters. One unmanaged queue in the path and your EF priority is worthless.

I've used that knowledge everywhere:
- O2's national VoIP migration
- InfraForesight QoS Fabric (socket → kernel → eBPF → interconnect → CPE)
- VoxFlow CPaaS (the only QoS-aware CPaaS on the market)

The CCIE isn't about Cisco. It's about understanding packet-level quality end to end. That's transferable to any stack.

If your organisation has latency-sensitive workloads and your cloud architecture doesn't address packet-level QoS — let's talk.

**Hashtags:** #CCIE #QoS #Networking #Career #CloudArchitecture #VoIP

**Image suggestion:** CCIE certificate (blurred number if needed) with overlay text: "One of <200 worldwide."

---

## Post 6: Hiring Announcement — InfraForesight is Growing

**Headline:** We're hiring. DevOps/infra engineers who understand networking.

**Body:**

InfraForesight is growing and we're looking for two engineers:

1. **Platform Engineer (Kubernetes)** — You'll own our multi-cloud K8s platform (AWS, Azure, GCP). Cilium, ArgoCD, Terraform, Prometheus. You understand networking at the container level.

2. **QoS Operations Engineer** — You'll monitor and maintain the QoS Fabric across customer deployments. You can read a DSCP marking, troubleshoot tc qdiscs, and write Grafana queries in your sleep.

What makes these roles different:
- We're building something that doesn't exist elsewhere — cross-cloud QoS enforcement with contractual SLAs
- You'll work directly with the founder (me) — flat structure, high autonomy
- Remote-first, UK-based team
- You'll learn eBPF, Cilium, and multi-cloud networking from someone who's been doing QoS for 30 years

Salary: £70K–£100K depending on experience, plus equity.

DM me or email brett@btfm.uk. No recruiters please.

**Hashtags:** #Hiring #DevOps #Kubernetes #PlatformEngineering #SRE #RemoteWork

**Image suggestion:** InfraForesight logo with "We're Hiring" overlay and role titles.

---

## Post 7: Technical Deep-Dive — The Six-Class DSCP Model

**Headline:** Why six QoS classes? (And why most enterprises only use two)

**Body:**

Most enterprise networks use two QoS classes: EF for voice, BE for everything else. That's 1990s thinking.

Here's the six-class model we use at InfraForesight:

| Class | DSCP | Priority | Example |
|-------|------|----------|---------|
| Real-Time Critical | EF (46) | Strict priority | Voice RTP, trading order flow |
| Real-Time Standard | AF41 (34) | CBWFQ 30% | Video, market data |
| Signaling | CS3 (24) | CBWFQ 10% | SIP, FIX heartbeats |
| Interactive | AF21 (18) | CBWFQ 15% | AI inference, WebSockets |
| Transactional | AF31 (26) | CBWFQ 10% | Trade confirmations, webhooks |
| Best Effort | BE (0) | WFQ remainder | Logs, analytics, bulk |

Why six? Because "voice vs. everything" breaks down when you have:
- Real-time video competing with voice
- AI inference competing with bulk data
- Signaling that must survive congestion to keep sessions alive

The model is application-agnostic. You map YOUR traffic to these classes based on latency sensitivity. VoIP shops map RTP → EF. Trading firms map order flow → EF. Same enforcement, different use case.

Does your organisation classify more than "voice and data"? I'd love to hear what models people are actually running in production.

**Hashtags:** #QoS #DSCP #NetworkEngineering #VoIP #CloudArchitecture #Latency

**Image suggestion:** The six-class table rendered as a clean visual diagram with colour-coded priority bands.

---

## Post 8: War Story — The Contact Centre QoS Nightmare

**Headline:** "The calls sound fine until 9:30am." — A QoS detective story

**Body:**

Client: a 500-seat contact centre doing £2M/day in telesales.
Symptom: "Calls sound terrible, but only between 9:30am and 10:15am."

Network team checked: QoS configured. Voice on EF. Bandwidth fine. No drops. No errors. Everything "looks green."

I drove up to their data centre.

The problem? A backup job kicked off at 9:30am. It ran on the same VLAN. Same subnet. Same switch. No QoS on the backup server.

The backup wasn't going over the WAN (where QoS was enforced). It was LAN-to-LAN on the same switch fabric, saturating the uplink that carried the voice VLAN's inter-switch traffic. The QoS policy only covered WAN egress.

Fix: two commands. Applied QoS to the switch uplink port. 10 minutes.

Diagnosis? Two weeks.

Lesson: QoS is end-to-end. "The network has QoS" means nothing unless you've verified every hop — including the ones that "don't matter" on the diagram. The hop you skip is the one that breaks.

**Hashtags:** #QoS #Troubleshooting #ContactCentre #NetworkEngineering #WarStories

**Image suggestion:** Simplified network diagram with a red circle around "the hop we forgot to QoS."

---

## Post 9: Thought Leadership — AI Infrastructure Needs QoS

**Headline:** Your GPU cluster is useless if the network drops packets between nodes

**Body:**

Everyone's talking about AI compute: H100s, TPU v5s, InfiniBand fabrics. But here's the bottleneck nobody mentions:

Distributed training sends gigabytes of gradients between nodes every iteration. If one packet drops at 400 Gbps, the entire training step waits for TCP retransmission. Your $30K GPU sits idle.

InfiniBand has credit-based flow control to prevent this. But most cloud AI training runs on Ethernet — no flow control, no congestion management, best-effort.

Where QoS fits:
- RDMA over Converged Ethernet (RoCE) needs PFC (Priority Flow Control) — a QoS mechanism
- Gradient synchronisation needs guaranteed bandwidth, not "whatever's left"
- Inference serving needs bounded latency — EF-class priority for real-time predictions

The same DSCP model that works for VoIP works for AI infrastructure. EF for gradient sync. AF41 for model serving. BE for checkpoint uploads.

I'm exploring this intersection right now — applying 30 years of QoS architecture to AI infrastructure. If you're building AI training or inference platforms and hitting network bottlenecks, I want to talk to you.

**Hashtags:** #AI #MachineLearning #GPU #Infrastructure #Networking #QoS #MLOps

**Image suggestion:** Diagram showing distributed training nodes connected by QoS-enforced fabric, highlighting the gradient sync path.

---

## Post 10: Personal — What I Actually Do (The Elevator Pitch)

**Headline:** What do you do? — The question I've finally figured out how to answer.

**Body:**

For 25 years, when someone asked "what do you do?" I'd mumble something about networks. Then I realised: I do one specific thing that almost nobody else does.

I make cloud infrastructure treat important packets with priority — and I guarantee it with measurement.

That sounds abstract until you put it in context:
- A trading firm: their order flow packets arrive before market data packets, every time, guaranteed.
- A hospital: their remote surgery video feed doesn't stutter when someone runs a backup.
- A contact centre: agents never say "you're breaking up" because of network congestion.

I do this at five layers: the application socket, the Linux kernel, Kubernetes eBPF, cloud interconnect, and customer-premise equipment.

I've been doing this for 30 years. CCIE in QoS. Built O2's national VoIP platform. Now I'm building InfraForesight to do it as a managed service.

So: I make important packets go first. With proof.

That's my elevator pitch. What's yours?

**Hashtags:** #PersonalBrand #ElevatorPitch #QoS #CloudComputing #Infrastructure #CCIE

**Image suggestion:** Simple visual: five layers stacked vertically with "important packets go FIRST" arrow going through them.

---

## Posting Strategy

| Day | Post Type | Example |
|-----|-----------|---------|
| Monday | Thought leadership | Post 1, 4, or 9 |
| Wednesday | Technical deep-dive | Post 2 or 7 |
| Friday | War story / personal | Post 8 or 10 |

**Cadence:** 2-3x/week. Don't go daily — you'll burn out and quality drops.

**Engagement rules:**
- Reply to every comment within 24 hours
- Engage with 5 other people's posts per day (not just yours)
- DM anyone who comments meaningfully — start a conversation, don't pitch immediately

**What NOT to post:**
- "Happy to announce..." posts (unless it's genuinely major — product launch, funding)
- Motivational quotes
- Political opinions
- Anything you wouldn't say to a client over coffee
