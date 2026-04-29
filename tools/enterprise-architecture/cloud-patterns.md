# Cloud Architecture Patterns for QoS-Aware Multi-Cloud Platforms

## Overview

This document describes five cloud architecture patterns developed and applied across InfraForesight/VoxFlow consulting engagements. Each pattern addresses a recurring challenge in multi-cloud, QoS-sensitive infrastructure. These patterns are validated in production and form the backbone of InfraForesight's architectural intellectual property.

**Author:** Brett Moore, Principal Enterprise Architect
**Version:** 2026-Q2
**Related:** Six-Class DSCP Model (EF/46, AF41/34, CS3/24, AF21/18, AF31/26, BE/0)

---

## Pattern 1: Multi-Cloud QoS Federation

### Problem

Organisations operating across AWS, Azure, and GCP face inconsistent quality-of-service enforcement. Each cloud provider has its own QoS model (or none), making it impossible to guarantee end-to-end service quality for real-time applications like voice, video, and UCaaS. Without federation, premium services degrade to best-effort the moment traffic crosses a cloud boundary. This directly impacts SLAs for regulated industries (finance, healthcare, emergency services) and premium CPaaS offerings.

### Solution

Implement a **unified DSCP-based QoS fabric** using eBPF (via Cilium) at the workload level, combined with a federation gateway at each cloud's edge that preserves DSCP markings across cloud boundaries. The six-class DSCP model is enforced consistently regardless of which cloud the workload runs on.

Key components:
- **eBPF Classification Agent:** Runs on every K8s node (Cilium). Classifies all pod egress traffic and marks DSCP according to centralised policy.
- **Federation Gateway:** Lightweight VM or pod at each cloud's network edge that reads DSCP markings and maps them to cloud-specific QoS profiles or tunnel markings.
- **Policy Controller:** Central (Git-synced) controller that defines which microservice gets which DSCP class. Flux CD or custom operator ensures consistency across all clusters.
- **Cross-Cloud DSCP Passthrough:** Where cloud providers do not preserve DSCP, the federation gateway encapsulates traffic in a WireGuard or VXLAN tunnel, copying inner DSCP to outer header.

### Diagram (ASCII)

```
+------------------------------------------------------------------+
|                     MULTI-CLOUD QoS FABRIC                        |
+------------------------------------------------------------------+

   AWS VPC                          Azure VNet                     GCP VPC
+----------------+            +----------------+            +----------------+
|                |            |                |            |                |
|  Media Worker  |            |  Media Worker  |            |  Media Worker  |
|  (EF/46 DSCP)  |            |  (EF/46 DSCP)  |            |  (EF/46 DSCP)  |
|       |        |            |       |        |            |       |        |
|  [Cilium eBPF] |            |  [Cilium eBPF] |            |  [Cilium eBPF] |
|       |        |            |       |        |            |       |        |
|       v        |            |       v        |            |       v        |
| +-----------+  |            | +-----------+  |            | +-----------+  |
| | Federation|  |  WireGuard | | Federation|  |  WireGuard | | Federation|  |
| | Gateway   |<-|---Tunnel-->| | Gateway   |<-|---Tunnel-->| | Gateway   |  |
| | (DSCP     |  |  (DSCP on | | (DSCP     |  |  (DSCP on | | (DSCP     |  |
| |  preserve) |  |   outer) | |  preserve) |  |   outer) | |  preserve) |  |
| +-----------+  |            | +-----------+  |            | +-----------+  |
+----------------+            +----------------+            +----------------+
        |                            |                            |
        +----------------------------+----------------------------+
                                     |
                            +------------------+
                            | Policy Controller |
                            | (GitOps / Flux CD)|
                            | Six-Class DSCP    |
                            | Mapping Rules     |
                            +------------------+
```

### When to Use

- You run real-time workloads (voice, video, UCaaS) across 2+ cloud providers
- Your SLAs require end-to-end QoS guarantees regardless of cloud
- You need consistent DSCP classification across heterogeneous environments
- Your architecture mandates a single operational model (not per-cloud bespoke QoS)

### When NOT to Use

- Single-cloud deployments with consistent native QoS support
- Workloads without real-time sensitivity (batch processing, static content)
- Environments where DSCP marking is not supported end-to-end (use alternative like bandwidth reservation)

---

## Pattern 2: eBPF Traffic Engineering

### Problem

Traditional traffic engineering relies on overlay networks, SD-WAN appliances, or cloud-native load balancers that operate at Layer 3/4 with limited visibility into application behaviour. These approaches add latency, are expensive at scale, and cannot react to real-time congestion signals. In multi-tenant CPaaS environments, noisy-neighbour problems degrade premium tenants without a mechanism to identify and throttle the offending traffic at line rate.

### Solution

Use **eBPF programs attached to kernel hooks** (TC, XDP) on every K8s node to implement application-aware traffic engineering without overlay overhead. eBPF programs run in the kernel at line rate, can inspect/modify packets at L3-L7, and can react to real-time congestion metrics.

Key components:
- **eBPF Classifier:** Attached to TC (traffic control) hook. Identifies application flows by L7 metadata (SIP Call-ID, tenant ID, RTP SSRC). Assigns DSCP class based on business policy.
- **eBPF Bandwidth Manager:** Rate-limits per-tenant or per-class using EDT (Earliest Departure Time) scheduling. Replaces complex Linux tc qdisc hierarchies.
- **eBPF Load Balancer:** Replaces kube-proxy with eBPF-based service load balancing (Cilium). Latency-aware backend selection by tracking per-pod RTT in eBPF maps.
- **eBPF Observability:** Exports per-flow metrics (RTT, retransmissions, throughput, DSCP distribution) to Prometheus via Hubble.

### Diagram (ASCII)

```
+---------------------------------------------------------------------+
|                    eBPF TRAFFIC ENGINEERING                          |
+---------------------------------------------------------------------+

                        K8s Worker Node
+----------------------------------------------------------+
|                                                          |
|   Pod A (Tenant Gold)     Pod B (Tenant Silver)          |
|   SIP/RTP Traffic           SIP/RTP Traffic              |
|        |                         |                        |
|        v                         v                        |
|  +----------+              +----------+                   |
|  | veth pair|              | veth pair|                   |
|  +----+-----+              +----+-----+                   |
|       |                           |                       |
|       v                           v                       |
|  +--------------------------------------------------+    |
|  |            TC eBPF Program (Classifier)          |    |
|  |  - Inspect L7: SIP Call-ID, RTP SSRC             |    |
|  |  - Tenant lookup in eBPF map                     |    |
|  |  - Assign DSCP: Gold→EF, Silver→AF41             |    |
|  +-----------------------+--------------------------+    |
|                          |                               |
|                          v                               |
|  +--------------------------------------------------+    |
|  |         TC eBPF Program (Bandwidth Manager)      |    |
|  |  - EDT scheduler per DSCP class                  |    |
|  |  - Gold EF: guaranteed 100Mbps                   |    |
|  |  - Silver AF41: burstable 50Mbps                 |    |
|  +-----------------------+--------------------------+    |
|                          |                               |
|                          v                               |
|  +--------------------------------------------------+    |
|  |              Physical NIC (XDP hook)             |    |
|  |  - XDP eBPF: early drop for BE class under load  |    |
|  |  - Wire-speed processing (no kernel stack)       |    |
|  +-----------------------+--------------------------+    |
+--------------------------|-------------------------------+
                           |
                     [Cloud Network]
```

### When to Use

- You need per-tenant or per-application traffic shaping at K8s node level
- You require sub-millisecond traffic classification (overlay adds 5-10ms)
- Your workloads share physical NICs and you need kernel-level isolation
- You want to replace iptables-based K8s networking (performance gains)

### When NOT to Use

- Small clusters where iptables is adequate
- Environments where kernel version < 5.4 (eBPF limited)
- Organisations without kernel/eBPF expertise on the platform team

---

## Pattern 3: Cross-Cloud VPN Mesh

### Problem

Multi-cloud deployments require private, encrypted connectivity between VPCs/VNets across cloud providers. Cloud-native options (AWS TGW, Azure vWAN, GCP NCC) are provider-specific, expensive at scale, and do not preserve QoS markings. Traditional IPSec VPNs are complex to manage in mesh topologies (n×(n-1) tunnels) and add significant encryption latency — unacceptable for real-time media.

### Solution

Implement a **full-mesh WireGuard overlay** between cloud edges, managed as code. WireGuard provides kernel-level encryption at line rate with minimal latency overhead (~0.5ms). The mesh is self-configuring and can carry DSCP markings in the outer header. Combine with BGP (via FRRouting or GoBGP) for dynamic routing and failover.

Key components:
- **WireGuard Mesh Controller:** Custom controller or Kilo/Netmaker that discovers cloud edges, provisions WireGuard peers, and manages key rotation.
- **BGP Route Reflector:** Each cloud edge runs FRRouting or GoBGP. Exchanges routes learned from the local cloud with peers in other clouds. Enables dynamic path selection and failover.
- **DSCP Transparency:** WireGuard outer header copies the DSCP field from the inner IP header. Intermediate cloud networks respect markings if configured.
- **Health Check and Failover:** BFD (Bidirectional Forwarding Detection) for sub-second failure detection. Route withdrawal triggers automatic re-routing.

### Diagram (ASCII)

```
+-------------------------------------------------------------------+
|                      CROSS-CLOUD VPN MESH                          |
+-------------------------------------------------------------------+

    AWS Region (eu-west-1)                 Azure Region (westeurope)
+---------------------------+         +----------------------------+
|                           |         |                            |
|  +--------------------+   |         |   +--------------------+   |
|  | WireGuard Endpoint |   |         |   | WireGuard Endpoint |   |
|  | 10.255.0.1         |<--|---------|-->| 10.255.0.2         |   |
|  | FRRouting BGP      |   |  WG Tun |   | FRRouting BGP      |   |
|  +---------+----------+   |         |   +---------+----------+   |
|            |              |         |             |              |
|     +------+------+       |         |      +------+------+       |
|     |             |       |         |      |             |       |
|     v             v       |         |      v             v       |
| +--------+  +--------+    |         | +--------+  +--------+     |
| | K8s    |  | RTP    |    |         | | K8s    |  | RTP    |     |
| | Pods   |  | Media  |    |         | | Pods   |  | Media  |     |
| |10.1.x  |  |10.2.x  |    |         | |10.3.x  |  |10.4.x  |     |
| +--------+  +--------+    |         | +--------+  +--------+     |
+---------------------------+         +----------------------------+
            |                                      |
            |              WireGuard                |
            +--------------------------------------+
            |                                      |
            |      GCP Region (europe-west1)        |
            |  +----------------------------+      |
            |  |                            |      |
            +->| WireGuard Endpoint         |<-----+
               | 10.255.0.3                 |
               | FRRouting BGP              |
               +---------+------------------+
                         |
                  +------+------+
                  |             |
                  v             v
              +--------+  +--------+
              | K8s    |  | RTP    |
              | Pods   |  | Media  |
              |10.5.x  |  |10.6.x  |
              +--------+  +--------+
               +----------------------------+

   BGP Overlay Network: 10.255.0.0/24 (WireGuard tunnel IPs)
   K8s Pod Networks:    10.1.0.0/16, 10.3.0.0/16, 10.5.0.0/16
   Media Networks:      10.2.0.0/16, 10.4.0.0/16, 10.6.0.0/16
```

### When to Use

- You run workloads across 3+ cloud providers or regions
- You need private, encrypted inter-cloud traffic without cloud-vendor lock-in
- DSCP/QoS preservation across cloud boundaries is required
- You need lower latency than IPSec (WireGuard: ~0.5ms vs IPSec: ~3-5ms)

### When NOT to Use

- Single cloud provider (use native VPC peering or Transit Gateway)
- Only 2 clouds in 2 regions (a single point-to-point tunnel may suffice)
- Throughput >10Gbps per tunnel (WireGuard has scaling limits at very high throughput)

---

## Pattern 4: Hybrid SIP/VoIP Architecture

### Problem

Telecom operators and enterprises migrating from on-premises PBX/IMS infrastructure to cloud-native CPaaS face a hybrid reality: existing SIP trunks, physical SBCs (Session Border Controllers), and legacy endpoints must coexist with cloud-native signalling (Kamailio) and media (FreeSWITCH) platforms. A "big bang" migration is impossible due to regulatory constraints, hardware lifecycle, and business continuity. The challenge is to route and process SIP traffic across on-prem and cloud deployments transparently, while maintaining QoS.

### Solution

Deploy a **tiered SIP fabric** where an intelligent routing layer (Kamailio dispatchers + DNS SRV) directs sessions to the appropriate backend based on tenant, geography, and capacity. The cloud layer runs containerised FreeSWITCH + Kamailio on K8s with eBPF QoS. The on-prem layer runs existing SBCs and PBX systems. A session border gateway bridges the two worlds, handling transcoding and protocol interworking where necessary.

Key components:
- **Signalling Routing Layer:** Kamailio instances (on K8s) with dispatcher module. Tenant- or number-range-based routing to cloud media workers or on-prem SBCs.
- **Session Border Gateway:** FreeSWITCH or dedicated SBC acting as protocol interworking function between cloud-native (WebSocket/SIP over TLS) and legacy (SIP over UDP/TCP).
- **Media Path Optimisation:** RTCP-based QoS reporting. Direct media path between endpoints where possible (bypass media worker). Fallback to media relay where NAT/firewall requires it.
- **Numbering and Dial Plan:** Centralised ENUM/LNP database. Cloud-native version on Redis/PostgreSQL; synchronised with on-prem via API or file transfer.

### Diagram (ASCII)

```
+-------------------------------------------------------------------+
|                   HYBRID SIP/VoIP ARCHITECTURE                     |
+-------------------------------------------------------------------+

                   +---------------------------------------+
                   |         Cloud-Native Layer            |
                   |  (K8s across AWS/Azure/GCP)           |
                   |                                       |
   SIP Endpoint    |  +----------+      +------------+     |
   (WebRTC/        |  | Kamailio |----->| FreeSWITCH |     |
    WebSocket) ------>| (Sig Rtng)|      | (Media Wkr)|     |
                   |  +----+-----+      +------+-----+     |
                   |       |                   |           |
                   |       | QoS: CS3/24       | EF/46     |
                   |       |                   |           |
                   +-------+-------------------+-----------+
                           |                   |
                    +------+------+     +------+------+
                    | Cilium eBPF |     | Cilium eBPF |
                    | DSCP Mark   |     | DSCP Mark   |
                    +------+------+     +------+------+
                           |                   |
                           +---------+---------+
                                     |
                            +--------+--------+
                            | Session Border   |
                            | Gateway (SBC)    |
                            | - Transcoding    |
                            | - Protocol I/W   |
                            | - NAT traversal  |
                            +--------+--------+
                                     |
                     Public/Private Interconnect
                                     |
                   +-----------------+------------------+
                   |         On-Premises Layer           |
                   |                                    |
      PSTN  <----->|  +----------+     +-----------+    |
                   |  | Legacy    |    | Legacy PBX |    |
                   |  | SBC/IMS   |<-->| / IP-PSTN |    |
                   |  +----------+     +-----------+    |
                   |          |                         |
                   +----------+-------------------------+
                              |
                        Legacy SIP Endpoints
                        (Desk Phones, Gateways)
```

### When to Use

- You are migrating from on-prem telecom infrastructure to cloud-native CPaaS
- You have regulatory or hardware lifecycle constraints preventing big-bang migration
- You need to support both WebRTC/WebSocket endpoints and legacy SIP desk phones
- Your routing logic depends on tenant, number range, or geographic affinity

### When NOT to Use

- Greenfield CPaaS with no legacy integration requirements
- Pure on-prem deployment (no cloud component)
- Environments where all endpoints speak the same SIP dialect (no interworking needed)

---

## Pattern 5: Observability Fabric

### Problem

Multi-cloud, QoS-sensitive platforms generate telemetry from multiple sources: eBPF flow logs (Hubble), application metrics (Prometheus), SIP/CDR data (TimescaleDB), infrastructure metrics (cloud APIs), and distributed traces (OpenTelemetry). Each cloud provider offers its own observability stack (CloudWatch, Azure Monitor, Cloud Monitoring), creating fragmentation. Correlating a single SIP session across these silos — from Kubernetes pod through cloud network to end-user experience — is nearly impossible, making troubleshooting slow and SLA reporting unreliable.

### Solution

Build an **Observability Fabric** — a unified telemetry pipeline that collects, normalises, and correlates data from all sources into a single queryable plane. It is cloud-agnostic, vendor-neutral, and designed to answer cross-cutting questions like "show me every packet DSCP marking, application metric, and infrastructure event for SIP session X across all clouds."

Key components:
- **Collection Layer:** OpenTelemetry Collector as the unified ingestion agent deployed as DaemonSet on every K8s node. Receives logs, metrics, traces via OTLP. Also scrapes Prometheus endpoints and tails Hubble flow logs.
- **Normalisation Layer:** Stream processor (e.g., Apache Flink or lightweight Go processor) that enriches telemetry with business context: tenant ID, session ID, QoS class, cloud provider, region. Normalises all timestamps to UTC.
- **Storage Layer:** Tiered storage: hot (TimescaleDB — recent CDRs and metrics, 7 days), warm (S3/Parquet via Trino — 90 days), cold (glacier — compliance retention).
- **Query Layer:** Grafana as the single pane of glass. Pre-built dashboards: "Per-Session QoS Trace", "Cross-Cloud Latency Heatmap", "DSCP Distribution by Tenant", "SLA Compliance Dashboard".
- **Alerting Layer:** Prometheus Alertmanager with cross-cloud correlation rules. Example: alert if EF-class packet drop correlates with CloudWatch CPU spike and a Kubernetes pod restart in the same correlation window.

### Diagram (ASCII)

```
+-------------------------------------------------------------------+
|                       OBSERVABILITY FABRIC                         |
+-------------------------------------------------------------------+

   TELEMETRY SOURCES                         FABRIC LAYERS
+---------------------+            +-------------------------------+
|                     |            |                               |
| Cilium Hubble       |----------->|  +----------------------+    |
| (eBPF flow logs,    |   OTLP     |  | OpenTelemetry        |    |
|  DSCP per flow)     |            |  | Collector (DaemonSet)|    |
|                     |            |  +----------+-----------+    |
+---------------------+            |             |                |
+---------------------+            |             v                |
|                     |            |  +----------------------+    |
| Prometheus Endpoints|----------->|  | Stream Processor     |    |
| (App metrics,       |   Scrape   |  | (Enrichment/Context) |    |
|  pod resources)     |            |  | - Add Tenant ID      |    |
|                     |            |  | - Add Session ID     |    |
+---------------------+            |  | - Normalise TS (UTC) |    |
                                   |  +----------+-----------+    |
+---------------------+            |             |                |
|                     |            |             v                |
| Cloud APIs          |----------->|  +----------------------+    |
| (AWS CloudWatch,    |   Pull     |  | Tiered Storage       |    |
|  Azure Monitor,     |            |  | HOT: TimescaleDB 7d  |    |
|  GCP Monitoring)    |            |  | WARM: S3/Trino 90d  |    |
|                     |            |  | COLD: Glacier >90d  |    |
+---------------------+            |  +----------+-----------+    |
                                   |             |                |
+---------------------+            |             v                |
|                     |            |  +----------------------+    |
| OpenTelemetry SDKs  |----------->|  | Grafana Dashboards   |    |
| (Distributed traces,|   OTLP     |  | + Alertmanager Rules |    |
|  app-level spans)   |            |  | Single Query Plane   |    |
|                     |            |  +----------------------+    |
+---------------------+            +-------------------------------+

   CONSUMERS:
   +----------------------+    +-------------------+    +------------+
   | SRE / Operations     |    | Architecture Team |    | Customers  |
   | (Incident response,  |    | (SLA compliance,  |    | (Tenant-   |
   |  per-session trace)  |    |  capacity plan.)  |    |  scoped    |
   +----------------------+    +-------------------+    |  dashboards|
                                                        +------------+
```

### When to Use

- You run workloads across 2+ cloud providers with fragmented native observability
- You need per-session correlation across network (flow logs), application (metrics), and infrastructure (events)
- You have SLA reporting requirements that span cloud boundaries
- Your troubleshooting MTTD (Mean Time to Detect) is too high due to siloed tools

### When NOT to Use

- Single cloud provider (native tools may suffice)
- Application-only monitoring without network-level QoS requirements
- Small-scale deployments where a single Prometheus/Grafana instance covers all needs

---

## Pattern Selection Guide

| Pattern | Primary Domain | Key Technology | QoS Impact |
|---|---|---|---|
| Multi-Cloud QoS Federation | Multi-cloud networking | eBPF, Cilium, DSCP | End-to-end QoS consistency |
| eBPF Traffic Engineering | K8s networking | eBPF (TC/XDP), Cilium | Per-packet QoS enforcement at line rate |
| Cross-Cloud VPN Mesh | Inter-cloud connectivity | WireGuard, BGP, FRRouting | Low-latency encrypted QoS-preserving mesh |
| Hybrid SIP/VoIP Architecture | Telecom/CPaaS | Kamailio, FreeSWITCH, SBC | QoS bridging between cloud-native and legacy |
| Observability Fabric | Observability | OpenTelemetry, TimescaleDB, Grafana | QoS visibility and SLA validation |

---

*Version: 2026-Q2 | Author: Brett Moore, Principal Enterprise Architect | InfraForesight*
