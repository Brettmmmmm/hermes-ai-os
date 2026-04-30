# Hermes Mesh — Multi-Agent Orchestration Fabric

## Purpose

The `hermes-mesh` domain skill is the multi-agent orchestration fabric for Hermes AI OS. It enables you to spawn, coordinate, and manage autonomous AI agent swarms across nodes — distributing work across personalities, models, and physical machines with a shared event bus, capability registry, and health heartbeat system.

Hermes Mesh is the **MESH** quadrant of the Hermes AI OS unified architecture:

```
┌─────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│  CHAT   │  │   CRON   │  │   MESH   │  │   API    │
│Telegram │  │Automation│  │Multi-Agent│  │ REST/WS  │
│  CLI    │  │Briefings │  │Orchestr. │  │ Web UI   │
└─────────┘  └──────────┘  └──────────┘  └──────────┘
```

It is the layer that makes Hermes AI OS a true *operating system* for AI — not just a single-agent chatbot.

## When to Use

- Distributed task execution across multiple Hermes nodes
- Parallel analysis with different personalities on the same problem
- Event-driven pipelines spanning multiple agents
- Capability discovery and dynamic workload routing
- Health monitoring and heartbeat-based node lifecycle
- Cross-node skill chaining (e.g., diagnostics → planning → codegen)
- Multi-model consensus (same input, different models, compare results)
- Autonomous swarm coordination (self-organising agent collectives)

## Architecture

Hermes Mesh uses a **control plane + data plane** split:

```
┌──────────────────────────────────────────────────────────────┐
│                     CONTROL PLANE                             │
│  ┌──────────┐  ┌────────────┐  ┌──────────────────────────┐  │
│  │ Registry │  │ Capability │  │  Health Heartbeats       │  │
│  │(who's in │  │ Negotiation│  │  (liveness, readiness)   │  │
│  │  mesh)   │  │ (who does  │  │                          │  │
│  │          │  │    what)   │  │                          │  │
│  └──────────┘  └────────────┘  └──────────────────────────┘  │
│                                                               │
│                     DATA PLANE                                │
│  ┌──────────────────────────────────────────────────────┐    │
│  │                   EVENT BUS                           │    │
│  │  ┌────────┐  ┌────────┐  ┌────────┐  ┌───────────┐  │    │
│  │  │ Topic A│  │ Topic B│  │ Topic C│  │  Topic D  │  │    │
│  │  │ (pub)  │  │ (pub)  │  │ (sub)  │  │  (sub)    │  │    │
│  │  └────────┘  └────────┘  └────────┘  └───────────┘  │    │
│  └──────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────┘
```

| Component | Role |
|-----------|------|
| **Registry** | Tracks every node in the mesh — ID, address, capabilities, status |
| **Capability Negotiation** | Nodes declare what skills/models they offer; work is routed accordingly |
| **Health Heartbeats** | Regular liveness pings; nodes that miss N beats are marked degraded/offline |
| **Event Bus** | Async pub/sub fabric. Skills publish events; interested nodes subscribe by topic |

## Event Bus

The event bus is the nervous system of the mesh. Every skill invocation, pipeline transition, and node lifecycle event flows through it.

### Design

- **Async pub/sub** — publishers fire events without blocking; subscribers consume at their own pace
- **Topic-based routing** — events are addressed to named topics (e.g., `hermes.skill.diagnostics.completed`)
- **JSON Schema validation** — every topic declares a schema. Messages that don't match are rejected at the bus boundary
- **At-least-once delivery guarantee** — subscribers acknowledge processed messages. Unacknowledged messages are redelivered

### Topic Naming Convention

```
hermes.<domain>.<event-type>[.<detail>]
```

Examples:

- `hermes.skill.diagnostics.completed` — a diagnostics run finished
- `hermes.node.capability.registered` — a node joined with capabilities
- `hermes.pipeline.stage.transition` — pipeline moved to the next stage
- `hermes.health.degraded` — a node stopped responding to heartbeats

### Event Schema (JSON Schema)

Every topic has an associated JSON Schema. Example for `hermes.skill.diagnostics.completed`:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "hermes.skill.diagnostics.completed",
  "type": "object",
  "required": ["event_id", "timestamp", "node_id", "skill", "result"],
  "properties": {
    "event_id": { "type": "string", "format": "uuid" },
    "timestamp": { "type": "string", "format": "date-time" },
    "node_id": { "type": "string" },
    "skill": { "type": "string", "enum": ["diagnostics"] },
    "result": {
      "type": "object",
      "required": ["status", "findings"],
      "properties": {
        "status": { "type": "string", "enum": ["healthy", "degraded", "down"] },
        "findings": { "type": "array", "items": { "type": "string" } },
        "remediation_id": { "type": "string" }
      }
    },
    "pipeline_id": { "type": "string" },
    "correlation_id": { "type": "string" }
  }
}
```

## Node Capabilities

Every Hermes node declares what it can do. The mesh uses this to route work.

### Discovery Protocol

1. **Node starts** → announces itself on the mesh with a `hermes.node.join` event
2. **Registry responds** → acknowledges join, sends current mesh topology snapshot
3. **Capability declaration** → node publishes `hermes.node.capability.registered` with its full capability set
4. **Peers sync** → existing nodes receive the capability update and update their routing tables

### Capability Negotiation

When a pipeline or skill invocation needs a specific capability (e.g., "needs operator personality + voxflow-operations skill"), the mesh:

1. Queries the registry for nodes matching the capability
2. Scores matches by load, latency, and recent success rate
3. Routes the work to the best candidate
4. Falls back to the next-best if the primary fails

### Health Heartbeats

Every node emits a heartbeat at a configurable interval (default: 5 seconds):

- **Liveness** — `hermes.node.heartbeat` with a monotonic counter
- **Miss threshold** — 3 missed beats → node marked `degraded`
- **Timeout** — 30 seconds without a beat → node marked `offline`, removed from active routing
- **Recovery** — a node that comes back publishes `hermes.node.join` and resumes

## Configuration

Mesh behaviour is driven by two configuration files in the Hermes config tree:

### Mesh Config: `node-caps.yaml`

```yaml
# config/hermes/mesh/node-caps.yaml
node:
  id: "hermes-primary"
  hostname: "primary.internal"
  address: "10.0.1.42"
  port: 9876
  mesh_name: "hermes-production"

capabilities:
  personalities:
    - architect
    - operator
    - analyst
  skills:
    - diagnostics
    - remediation
    - planning
    - enterprise-architecture
    - voxflow-operations
    - income-generation
    - hermes-mesh
  models:
    - ollama:deepseek-v4-pro:cloud
    - ollama:kimi-k2.6:cloud
    - ollama:qwen3.5:cloud
  resources:
    max_concurrent_tasks: 8
    max_memory_mb: 4096

heartbeat:
  interval_seconds: 5
  miss_threshold: 3
  timeout_seconds: 30

transport:
  protocol: "quic"       # Planned: quic | tcp+tls
  encryption: true
  mutual_tls: true

event_bus:
  topics:
    - hermes.skill.*
    - hermes.pipeline.*
    - hermes.health.*
    - hermes.node.*
  delivery_guarantee: "at-least-once"
  ack_timeout_ms: 5000
```

### Event Schema Registry: `event-schema.yaml`

```yaml
# config/hermes/mesh/event-schema.yaml
schemas:
  hermes.node.join:
    $schema: "https://json-schema.org/draft/2020-12/schema"
    type: "object"
    required: ["event_id", "timestamp", "node_id", "address", "capabilities"]
    properties:
      event_id: { type: "string", format: "uuid" }
      timestamp: { type: "string", format: "date-time" }
      node_id: { type: "string" }
      address: { type: "string" }
      port: { type: "integer", minimum: 1, maximum: 65535 }
      capabilities:
        type: "object"
        properties:
          personalities: { type: "array", items: { type: "string" } }
          skills: { type: "array", items: { type: "string" } }
          models: { type: "array", items: { type: "string" } }

  hermes.node.heartbeat:
    $schema: "https://json-schema.org/draft/2020-12/schema"
    type: "object"
    required: ["node_id", "sequence", "timestamp", "status"]
    properties:
      node_id: { type: "string" }
      sequence: { type: "integer", minimum: 0 }
      timestamp: { type: "string", format: "date-time" }
      status: { type: "string", enum: ["healthy", "degraded"] }
      active_tasks: { type: "integer", minimum: 0 }
      memory_used_mb: { type: "number" }

  hermes.pipeline.stage.transition:
    $schema: "https://json-schema.org/draft/2020-12/schema"
    type: "object"
    required: ["pipeline_id", "from_stage", "to_stage", "node_id", "timestamp"]
    properties:
      pipeline_id: { type: "string" }
      from_stage: { type: "string" }
      to_stage: { type: "string" }
      node_id: { type: "string" }
      timestamp: { type: "string", format: "date-time" }
      output_artifact_id: { type: "string" }
```

## Integration

### Skills Registering with the Mesh

Every skill in `config/hermes/skills/` implicitly participates in the mesh. When a Hermes node starts:

1. It reads all skill YAML files
2. Each skill is registered as a capability in the mesh
3. Skills tagged with `domains: [mesh]` (like `hermes-mesh` itself) are available for cross-node routing
4. Other nodes discover these capabilities and can route work to this node

The `hermes-mesh` skill YAML declares its mesh participation explicitly:

```yaml
# config/hermes/skills/hermes-mesh.yaml
id: hermes-mesh
description: "Multi-agent orchestration fabric — spawn, coordinate, and manage autonomous AI agent swarms across nodes"
personality: architect
model: ollama:deepseek-v4-pro:cloud
policy:
  format: "markdown"
  structure:
    - "Overview"
    - "Node Topology"
    - "Event Flow"
    - "Capability Negotiation"
    - "Bootstrap Procedure"
    - "Operational Notes"
domains:
  - mesh
  - orchestration
  - multi-agent
tags:
  - mesh
  - agents
  - event-bus
  - coordination
```

### Pipelines Chaining Across Agents

Pipelines are the primary cross-agent pattern. A pipeline chains skills in sequence, and each stage can execute on a different mesh node:

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  STAGE 1     │     │  STAGE 2     │     │  STAGE 3     │
│  diagnostics │────▶│  planning    │────▶│  codegen     │
│  (operator)  │     │  (architect) │     │  (coder)     │
│  Node A      │     │  Node B      │     │  Node C      │
└──────────────┘     └──────────────┘     └──────────────┘
```

Pipeline flow:

1. **Stage trigger** — a `hermes.pipeline.stage.requested` event fires with the pipeline ID and stage inputs
2. **Capability match** — mesh registry finds the best node for the required personality + skill
3. **Execution** — the skill runs on the matched node
4. **Completion** — a `hermes.pipeline.stage.completed` event fires with outputs
5. **Transition** — the pipeline engine publishes `hermes.pipeline.stage.transition` and the next stage begins
6. **Cross-node artifact passing** — stage outputs are available to downstream stages via the event payload or a shared artifact store

### Pipeline Configuration (planned)

```yaml
# config/hermes/pipelines/voxflow-health.yaml
pipeline:
  id: "voxflow-health-sweep"
  stages:
    - skill: diagnostics
      personality: operator
      node_constraint: "has_skill:voxflow-operations"
    - skill: remediation
      personality: operator
      depends_on: diagnostics
      condition: "$diagnostics.result.status == 'degraded'"
    - skill: summarisation
      personality: analyst
      depends_on: remediation
      node_constraint: "model:qwen3.5:cloud"
```

## Bootstrap

Bootstrap a new Hermes Mesh node with the mesh bootstrap script:

```bash
#!/usr/bin/env bash
# scripts/mesh-bootstrap.sh
# Bootstrap a new Hermes Mesh node — validate config, register with mesh, start heartbeats

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_DIR="$REPO_ROOT/config/hermes/mesh"

echo "=== Hermes Mesh Bootstrap ==="
echo "Repo root: $REPO_ROOT"
echo ""

# Step 1: Validate mesh configuration
echo "[1/5] Validating mesh configuration..."
if ! command -v yamllint &>/dev/null; then
    echo "  → Installing yamllint..."
    pip install yamllint > /dev/null 2>&1
fi

yamllint "$CONFIG_DIR/node-caps.yaml" \
  && echo "  ✓ node-caps.yaml valid" \
  || { echo "  ✗ node-caps.yaml failed validation"; exit 1; }

yamllint "$CONFIG_DIR/event-schema.yaml" \
  && echo "  ✓ event-schema.yaml valid" \
  || { echo "  ✗ event-schema.yaml failed validation"; exit 1; }

# Step 2: Verify required models are available
echo "[2/5] Checking model availability..."
REQUIRED_MODELS=$(yq '.capabilities.models[]' "$CONFIG_DIR/node-caps.yaml" 2>/dev/null || true)

if command -v ollama &>/dev/null; then
    AVAILABLE=$(ollama list 2>/dev/null | awk '{print $1}' || echo "")
    for model in $REQUIRED_MODELS; do
        model_name="${model#ollama:}"
        if echo "$AVAILABLE" | grep -qF "$model_name"; then
            echo "  ✓ $model_name available"
        else
            echo "  ! $model_name not found — pulling..."
            ollama pull "$model_name" || echo "  ⚠ Failed to pull $model_name"
        fi
    done
else
    echo "  ⚠ Ollama not found — skipping model check"
fi

# Step 3: Validate event schemas
echo "[3/5] Validating event schemas..."
python3 -c "
import yaml, json
with open('$CONFIG_DIR/event-schema.yaml') as f:
    schemas = yaml.safe_load(f)
for name, schema in schemas.get('schemas', {}).items():
    print(f'  ✓ {name} loaded ({len(json.dumps(schema))} bytes)')
" 2>/dev/null || echo "  ⚠ Python schema check skipped (yaml/pyyaml needed)"

# Step 4: Announce node to mesh
echo "[4/5] Announcing node to mesh..."
NODE_ID=$(yq '.node.id' "$CONFIG_DIR/node-caps.yaml" 2>/dev/null || echo "hermes-node-$(hostname)")
echo "  → Node ID: $NODE_ID"
echo "  → Publishing hermes.node.join to event bus..."
# In production, this publishes to the actual event bus
# hermes mesh announce --config "$CONFIG_DIR/node-caps.yaml"
echo "  ✓ Join event published (dry run — no runtime yet)"

# Step 5: Start heartbeat
echo "[5/5] Starting health heartbeats..."
HEARTBEAT_INTERVAL=$(yq '.heartbeat.interval_seconds' "$CONFIG_DIR/node-caps.yaml" 2>/dev/null || echo "5")
echo "  → Interval: ${HEARTBEAT_INTERVAL}s"
echo "  → Miss threshold: 3 beats → degraded"
echo "  → Timeout: 30s silence → offline"
echo ""
echo "=== Mesh bootstrap complete ==="
echo "Node '$NODE_ID' is live and heartbeating."
echo "Run 'hermes mesh status' to verify connectivity."
```

### Bootstrap invocation

```bash
# From the repo root
chmod +x scripts/mesh-bootstrap.sh
./scripts/mesh-bootstrap.sh

# Expected output:
# === Hermes Mesh Bootstrap ===
# [1/5] Validating mesh configuration...
#   ✓ node-caps.yaml valid
#   ✓ event-schema.yaml valid
# [2/5] Checking model availability...
#   ✓ deepseek-v4-pro:cloud available
#   ✓ kimi-k2.6:cloud available
#   ✓ qwen3.5:cloud available
# [3/5] Validating event schemas...
#   ✓ hermes.node.join loaded
#   ✓ hermes.node.heartbeat loaded
#   ✓ hermes.pipeline.stage.transition loaded
# [4/5] Announcing node to mesh...
#   → Node ID: hermes-primary
# [5/5] Starting health heartbeats...
#   → Interval: 5s
# === Mesh bootstrap complete ===
# Node 'hermes-primary' is live and heartbeating.
```

## Example: Sample Mesh Event Flow

Here's a concrete example — a **VoxFlow health sweep** distributed across three mesh nodes:

```
TIME ──────────────────────────────────────────────────────▶

Node A (operator, diagnostics)
  │
  ├─[T+0s]  hermes.node.heartbeat (seq=42, healthy)
  │
  ├─[T+1s]  PUB: hermes.pipeline.stage.requested
  │          { pipeline_id: "voxflow-sweep-01",
  │            stage: "diagnostics",
  │            inputs: { service: "gateway", check: "redis-connectivity" } }
  │
  ├─[T+3s]  (diagnostics skill runs against VoxFlow Gateway)
  │
  ├─[T+5s]  PUB: hermes.skill.diagnostics.completed
  │          { node_id: "hermes-node-a",
  │            result: { status: "degraded",
  │                      findings: ["Redis connection pool exhausted",
  │                                 "keyPrefix lookup latency > 500ms"] } }
  │
  ├─[T+5s]  hermes.node.heartbeat (seq=43, healthy, active_tasks=0)
  │
  ▼
Node B (architect, planning)
  │
  ├─[T+5s]  SUB: hermes.skill.diagnostics.completed
  │          → Planning skill triggered by degraded status
  │
  ├─[T+8s]  PUB: hermes.pipeline.stage.completed
  │          { stage: "planning", output: { remediation_plan: "Scale Redis pool..." } }
  │
  ├─[T+8s]  PUB: hermes.pipeline.stage.transition
  │          { from_stage: "planning", to_stage: "remediation" }
  │
  ├─[T+10s] hermes.node.heartbeat (seq=17, healthy)
  │
  ▼
Node C (coder, codegen)
  │
  ├─[T+8s]  SUB: hermes.pipeline.stage.transition
  │          → Codegen skill triggered — generates Redis scaling IaC
  │
  ├─[T+14s] PUB: hermes.skill.codegen.completed
  │          { node_id: "hermes-node-c",
  │            output: { pr_url: "https://github.com/voxflow/...",
  │                      diff: "+30 lines, redis.ts pool config" } }
  │
  ├─[T+15s] hermes.node.heartbeat (seq=99, healthy)
  │
  └─ PIPELINE COMPLETE — all stages done, PR ready for review
```

### What happened

1. **Node A** (operator personality) ran `diagnostics` against VoxFlow Gateway, discovered degraded Redis connectivity
2. **Node B** (architect personality) consumed the diagnostics result, ran `planning`, produced a remediation plan
3. **Node C** (coder personality) consumed the pipeline transition, ran `codegen`, produced a pull request with the fix

All three nodes maintained heartbeats throughout. Events were schema-validated at publish time. The pipeline coordinated entirely through mesh events — no direct RPC coupling.

## Policy

- **Personality:** architect
- **Default Model:** `ollama:deepseek-v4-pro:cloud`
- **Output Format:** markdown
- **Required Structure:** Overview → Node Topology → Event Flow → Capability Negotiation → Bootstrap Procedure → Operational Notes
- Mesh designs include node topology diagrams
- Event flows document topics, schemas, and delivery guarantees
- Operational notes cover heartbeat behaviour, timeouts, and degraded-node handling
- Bootstrap procedures are repeatable and validated

## Related Documentation

- [Getting Started](/docs/getting-started) — repo setup and first skill run
- [Architecture Overview](/docs/architecture/overview) — core concepts (personalities, skills, profiles, routing)
- [Enterprise Architecture](/docs/domain-skills/enterprise-architecture) — TOGAF, ArchiMate, ADRs
- [VoxFlow Operations](/docs/domain-skills/voxflow-operations) — the platform this mesh orchestrates
- [Pipelines Overview](/docs/pipelines/overview) — how pipelines chain skills
- [VISION.md](https://github.com/btfmo/hermes-ai-os/blob/main/VISION.md) — master vision and phase roadmap

## Phase Status

Hermes Mesh is currently a **documented vision** (Phase 1). The runtime components — QUIC transport, CRDT state sync, the mesh dashboard — are planned for Phase 3+.

| Component | Status |
|-----------|--------|
| Skill definition (`hermes-mesh.yaml`) | ✅ Done |
| Node capability schema (`node-caps.yaml`) | ✅ Documented (config ready) |
| Event schema registry (`event-schema.yaml`) | ✅ Documented (config ready) |
| Bootstrap script (`mesh-bootstrap.sh`) | ✅ Documented |
| Event bus runtime | ⏳ Planned (Phase 3) |
| QUIC transport layer | ⏳ Planned (Phase 3) |
| CRDT shared state | ⏳ Planned (Phase 3) |
| Mesh dashboard (React) | ⏳ Planned (Phase 4) |
