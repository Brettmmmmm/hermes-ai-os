#!/usr/bin/env bash
# ==============================================================================
# Hermes Mesh Node Bootstrap — Idempotent Setup Script
#
# Bootstraps a Hermes mesh node by installing prerequisites, validating
# configuration, verifying Ollama connectivity, checking model availability,
# creating the runtime directory, and generating the mesh-node.env file.
#
# Usage: ./scripts/mesh-bootstrap.sh [--skip-install] [--force]
#   --skip-install   Skip OS package installation (prerequisites already met)
#   --force          Regenerate .env and runtime dir even if they already exist
#   --help, -h       Show this help message
# ==============================================================================

set -euo pipefail

# ─── Configuration ─────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="${REPO_ROOT}/config/hermes/mesh"
NODE_CAPS="${CONFIG_DIR}/node-caps.yaml"
EVENT_SCHEMA="${CONFIG_DIR}/event-schema.yaml"
RUNTIME_DIR="${REPO_ROOT}/.hermes/mesh"
ENV_FILE="${RUNTIME_DIR}/mesh-node.env"
OLLAMA_URL="${OLLAMA_URL:-http://127.0.0.1:11434}"
SKIP_INSTALL=false
FORCE=false

# ─── Parse arguments ───────────────────────────────────────
for arg in "$@"; do
    case "$arg" in
        --skip-install)  SKIP_INSTALL=true ;;
        --force)         FORCE=true ;;
        --help|-h)
            echo "Usage: $0 [--skip-install] [--force]"
            echo ""
            echo "  --skip-install   Skip OS package installation"
            echo "  --force          Regenerate .env and runtime dir even if they already exist"
            exit 0
            ;;
    esac
done

# ─── Color helpers ─────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

green()   { echo -e "${GREEN}$1${NC}"; }
red()     { echo -e "${RED}$1${NC}"; }
yellow()  { echo -e "${YELLOW}$1${NC}"; }
blue()    { echo -e "${BLUE}$1${NC}"; }
cyan()    { echo -e "${CYAN}$1${NC}"; }
bold()    { echo -e "${BOLD}$1${NC}"; }
header()  { echo ""; bold "━━━ $1 ━━━"; }
success() { echo ""; green "  ✓ $1"; }
warning() { yellow "  ⚠ $1"; }
failure() { red "  ✗ $1"; }

# ─── Log failure and exit ──────────────────────────────────
die() {
    echo ""; red "╔══════════════════════════════════════════════════════════╗"
    red "║  BOOTSTRAP FAILED: $1"
    red "╚══════════════════════════════════════════════════════════╝"
    exit 1
}

# ═══════════════════════════════════════════════════════════
#  STEP 0 — HEADER
# ═══════════════════════════════════════════════════════════
bold "╔══════════════════════════════════════════════════════════╗"
bold "║       HERMES MESH NODE BOOTSTRAP — $(date '+%Y-%m-%d %H:%M:%S')       ║"
bold "╚══════════════════════════════════════════════════════════╝"

# ═══════════════════════════════════════════════════════════
#  STEP 1 — DETECT OS AND INSTALL PREREQUISITES
# ═══════════════════════════════════════════════════════════
header "STEP 1: OS Detection & Prerequisites"

detect_os() {
    case "$(uname -s)" in
        Darwin)  echo "macos" ;;
        Linux)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                case "$ID" in
                    ubuntu|debian)       echo "debian" ;;
                    centos|rhel|fedora)  echo "rhel" ;;
                    *)                   echo "linux-unknown" ;;
                esac
            else
                echo "linux-unknown"
            fi
            ;;
        *)       echo "unknown" ;;
    esac
}

OS="$(detect_os)"
bold "  Detected OS: $(cyan "$OS")"

if $SKIP_INSTALL; then
    yellow "  Skipping package installation (--skip-install)"
else
    case "$OS" in
        debian)
            echo "  Installing packages via apt..."
            sudo apt-get update -qq
            sudo apt-get install -y -qq python3 python3-pip jq
            pip3 install --quiet --user yamllint
            ;;
        rhel)
            echo "  Installing packages via dnf/yum..."
            if command -v dnf &>/dev/null; then
                sudo dnf install -y -q python3 python3-pip jq
            else
                sudo yum install -y -q python3 python3-pip jq
            fi
            pip3 install --quiet --user yamllint
            ;;
        macos)
            echo "  Installing packages via Homebrew..."
            if ! command -v brew &>/dev/null; then
                die "Homebrew not found. Install from https://brew.sh and retry."
            fi
            brew install python3 jq yamllint 2>/dev/null || true
            ;;
        *)
            yellow "  Unknown OS. Please install manually: python3, pip, yamllint, jq"
            ;;
    esac
    success "Prerequisites installed"
fi

# Verify each required tool
for tool in python3 pip3 jq yamllint; do
    if command -v "$tool" &>/dev/null; then
        success "$tool — $(command -v "$tool")"
    else
        # yamllint might be installed via pip --user, check common paths
        if [ "$tool" = "yamllint" ]; then
            if [ -x "$HOME/.local/bin/yamllint" ]; then
                export PATH="$HOME/.local/bin:$PATH"
                success "yamllint — $HOME/.local/bin/yamllint"
            else
                warning "yamllint not found — install with: pip3 install --user yamllint"
            fi
        elif [ "$tool" = "pip3" ]; then
            warning "pip3 not found — trying pip as fallback"
            if command -v pip &>/dev/null; then
                success "pip — $(command -v pip)"
            else
                warning "pip not found either — YAML parsing may fail"
            fi
        else
            warning "$tool not found in PATH"
        fi
    fi
done

# ═══════════════════════════════════════════════════════════
#  STEP 2 — VALIDATE CONFIG FILES
# ═══════════════════════════════════════════════════════════
header "STEP 2: Configuration Validation"

if [ ! -f "$NODE_CAPS" ]; then
    die "node-caps.yaml not found at: $NODE_CAPS"
fi
success "node-caps.yaml — $(cyan "$NODE_CAPS")"

if [ ! -f "$EVENT_SCHEMA" ]; then
    die "event-schema.yaml not found at: $EVENT_SCHEMA"
fi
success "event-schema.yaml — $(cyan "$EVENT_SCHEMA")"

# Yamllint check (non-fatal — emits warnings only)
echo "  Running yamllint..."
if command -v yamllint &>/dev/null; then
    yamllint "$NODE_CAPS" 2>&1 || warning "node-caps.yaml has lint warnings"
    yamllint "$EVENT_SCHEMA" 2>&1 || warning "event-schema.yaml has lint warnings"
else
    warning "yamllint not available — skipping lint check"
fi

# ═══════════════════════════════════════════════════════════
#  STEP 3 — CHECK OLLAMA CONNECTIVITY
# ═══════════════════════════════════════════════════════════
header "STEP 3: Ollama Connectivity"

echo "  Probing: $(cyan "$OLLAMA_URL/api/tags")"

OLLAMA_RESPONSE=$(curl -sf --max-time 10 "${OLLAMA_URL}/api/tags" 2>&1) || {
    red ""
    red "  Cannot reach Ollama at ${OLLAMA_URL}"
    red "  Ensure Ollama is running: ollama serve"
    die "Ollama connectivity check failed"
}

success "Ollama is running"
echo "  Response: $(echo "$OLLAMA_RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
models = [m.get('name','?') for m in data.get('models',[])]
print(f'{len(models)} model(s) available')
" 2>/dev/null || echo "connected (model list parse skipped)")"

# ═══════════════════════════════════════════════════════════
#  STEP 4 — LOAD NODE CAPABILITIES AND PRINT SUMMARY
# ═══════════════════════════════════════════════════════════
header "STEP 4: Node Capabilities"

# Parse node-caps.yaml with Python (std lib only — no PyYAML needed for basic extraction)
echo "  Parsing: $(cyan "$NODE_CAPS")"

NODE_ID=$(python3 -c "
import sys, re

with open('$NODE_CAPS') as f:
    content = f.read()

# Extract node_id (simple YAML top-level key)
m = re.search(r'^node_id:\s+(.+)$', content, re.MULTILINE)
if m:
    print(m.group(1).strip().strip('\"').strip(\"'\"))

# Fallback to hostname
if not m:
    import socket
    print(socket.gethostname())
")

NODE_TYPE=$(python3 -c "
import re
with open('$NODE_CAPS') as f:
    content = f.read()
m = re.search(r'^node_type:\s+(.+)$', content, re.MULTILINE)
print(m.group(1).strip()) if m else print('worker')
")

MESH_VERSION=$(python3 -c "
import re
with open('$NODE_CAPS') as f:
    content = f.read()
m = re.search(r'^version:\s+(.+)$', content, re.MULTILINE)
print(m.group(1).strip()) if m else print('1')
")

HEARTBEAT=$(python3 -c "
import re
with open('$NODE_CAPS') as f:
    content = f.read()
m = re.search(r'^heartbeat_interval_seconds:\s+(.+)$', content, re.MULTILINE)
print(m.group(1).strip()) if m else print('30')
")

DISCOVERY_ENDPOINTS=$(python3 -c "
import re
with open('$NODE_CAPS') as f:
    content = f.read()
# Extract discovery_endpoints list entries
in_block = False
endpoints = []
for line in content.split('\n'):
    if 'discovery_endpoints:' in line and not line.strip().startswith('#'):
        in_block = True
        continue
    if in_block:
        m = re.match(r'\s+-\s+(.+)$', line)
        if m:
            endpoints.append(m.group(1).strip())
        elif line.strip() and not line.strip().startswith('#'):
            # A non-list, non-comment line ends the block
            if not re.match(r'\s+-\s+', line):
                break
print(','.join(endpoints) if endpoints else 'http://localhost:9080/.well-known/hermes-mesh')
")

bold "  ──────────────────────────────────────────────"
bold "  Node Identity"
bold "  ──────────────────────────────────────────────"
echo   "    Node ID:        $(green "$NODE_ID")"
echo   "    Node Type:      $(cyan "$NODE_TYPE")"
echo   "    Mesh Version:   v${MESH_VERSION}"
echo   "    Heartbeat:      ${HEARTBEAT}s"
echo ""
bold "  ──────────────────────────────────────────────"
bold "  Capabilities"
bold "  ──────────────────────────────────────────────"

python3 -c "
import re

with open('$NODE_CAPS') as f:
    content = f.read()

# Find the capabilities block
caps_section = re.search(r'^capabilities:(.*?)(?=^[a-z_]+:|\Z)', content, re.MULTILINE | re.DOTALL)
if not caps_section:
    print('  (no capabilities defined)')
    sys.exit(0)

caps_text = caps_section.group(1)

# Split into individual capability entries (each starts with '  - id:')
entries = re.split(r'\n  - id:', caps_text)
entries = ['  - id:' + e for e in entries[1:]]  # first split fragment is before first entry

for entry in entries:
    id_m = re.search(r'id:\s+(.+)$', entry, re.MULTILINE)
    name_m = re.search(r'name:\s+\"(.+?)\"', entry)
    conc_m = re.search(r'max_concurrency:\s+(\d+)', entry)
    cpu_m = re.search(r'cpu_cores:\s+(\d+)', entry)
    mem_m = re.search(r'memory_gb:\s+(\d+)', entry)
    gpu_m = re.search(r'gpu_available:\s+(true|false)', entry)

    # Extract supported_models list
    models_block = re.search(r'supported_models:(.*?)(?=\n  [a-z_]+:|\n\Z)', entry, re.DOTALL)
    models = []
    if models_block:
        for line in models_block.group(1).split('\n'):
            m = re.match(r'\s+-\s+(.+)$', line)
            if m:
                models.append(m.group(1).strip())

    cap_id = id_m.group(1).strip() if id_m else '?'
    cap_name = name_m.group(1) if name_m else cap_id
    concurrency = conc_m.group(1) if conc_m else '?'
    cpu = cpu_m.group(1) if cpu_m else '?'
    mem = mem_m.group(1) if mem_m else '?'
    gpu = gpu_m.group(1) if gpu_m else 'false'

    gpu_icon = '🎮' if gpu == 'true' else '🖥️'
    print(f'    {gpu_icon} {cap_name} (id: {cap_id})')
    print(f'       Concurrency: {concurrency}  |  CPU: {cpu} cores  |  RAM: {mem} GB  |  GPU: {gpu}')
    print(f'       Models: {len(models)} — {\", \".join(models[:4])}{\" +{0}\".format(len(models)-4) if len(models) > 4 else \"\"}')

print()
print(f'  Total capabilities: {len(entries)}')
" 2>/dev/null || warning "Could not parse capabilities (Python error)"

# ═══════════════════════════════════════════════════════════
#  STEP 5 — VERIFY MODELS ARE AVAILABLE IN OLLAMA
# ═══════════════════════════════════════════════════════════
header "STEP 5: Model Availability Check"

# Collect all unique models from node-caps.yaml
REQUIRED_MODELS=$(python3 -c "
import re

with open('$NODE_CAPS') as f:
    content = f.read()

# Extract all model names from supported_models blocks
models = set()
for match in re.finditer(r'-\s+(.+)$', content, re.MULTILINE):
    model = match.group(1).strip()
    # Only match lines that look like model names (colon-separated ollama format)
    if ':' in model and not model.startswith('#') and not model.startswith('http'):
        models.add(model)

for m in sorted(models):
    print(m)
")

if [ -z "$REQUIRED_MODELS" ]; then
    warning "No models found in capabilities — skipping check"
else
    echo "  Models declared in capabilities: $(echo "$REQUIRED_MODELS" | wc -l)"
    echo ""

    # Get installed models from Ollama
    INSTALLED_MODELS=$(curl -sf --max-time 10 "${OLLAMA_URL}/api/tags" 2>/dev/null | \
        python3 -c "
import sys, json
data = json.load(sys.stdin)
for m in data.get('models', []):
    print(m.get('name', ''))
" 2>/dev/null)

    MISSING=0
    PRESENT=0

    while IFS= read -r model; do
        [ -z "$model" ] && continue
        # Strip ollama: prefix if present
        clean_model="${model#ollama:}"
        if echo "$INSTALLED_MODELS" | grep -qFx "$clean_model" 2>/dev/null; then
            success "$model"
            ((PRESENT++)) || true
        else
            failure "$model — not pulled. Run: ollama pull $clean_model"
            ((MISSING++)) || true
        fi
    done <<< "$REQUIRED_MODELS"

    echo ""
    echo "  Models present: $(green "$PRESENT")  |  Missing: $(red "$MISSING")"

    if [ "$MISSING" -gt 0 ]; then
        warning "Some models need to be pulled before this node is fully operational."
        echo "  Pull all missing models with:"
        while IFS= read -r model; do
            [ -z "$model" ] && continue
            clean_model="${model#ollama:}"
            if ! echo "$INSTALLED_MODELS" | grep -qFx "$clean_model" 2>/dev/null; then
                echo "    ollama pull $clean_model"
            fi
        done <<< "$REQUIRED_MODELS"
    fi
fi

# ═══════════════════════════════════════════════════════════
#  STEP 6 — CREATE RUNTIME DIRECTORY
# ═══════════════════════════════════════════════════════════
header "STEP 6: Runtime Directory"

if [ -d "$RUNTIME_DIR" ] && ! $FORCE; then
    success "Runtime directory already exists: $(cyan "$RUNTIME_DIR")"
else
    mkdir -p "$RUNTIME_DIR"
    success "Created: $(cyan "$RUNTIME_DIR")"
fi

# Set permissions: owner rwx, group rx, others nothing (700)
chmod 700 "$RUNTIME_DIR" 2>/dev/null || true

# Create subdirectories
for subdir in logs tasks; do
    mkdir -p "${RUNTIME_DIR}/${subdir}"
    success "Subdirectory: ${RUNTIME_DIR}/${subdir}"
done

echo ""
echo "  Directory tree:"
echo "    ${RUNTIME_DIR}/"
echo "    ├── logs/"
echo "    ├── tasks/"
echo "    └── mesh-node.env"

# ═══════════════════════════════════════════════════════════
#  STEP 7 — GENERATE mesh-node.env
# ═══════════════════════════════════════════════════════════
header "STEP 7: Environment File"

if [ -f "$ENV_FILE" ] && ! $FORCE; then
    success "mesh-node.env already exists — $(cyan "$ENV_FILE")"
    echo ""
    echo "  Current contents:"
    while IFS= read -r line; do
        echo "    $line"
    done < "$ENV_FILE"
else
    cat > "$ENV_FILE" <<EOF
# ==============================================================================
# Hermes Mesh Node — Environment Configuration
# AUTO-GENERATED by mesh-bootstrap.sh at $(date -Iseconds)
# DO NOT commit this file — it contains node-specific runtime configuration.
# ==============================================================================

# Node identity
NODE_ID=${NODE_ID}
NODE_TYPE=${NODE_TYPE}
MESH_VERSION=${MESH_VERSION}

# Transport
HEARTBEAT_INTERVAL_SECONDS=${HEARTBEAT}
OLLAMA_ENDPOINT=${OLLAMA_URL}

# Discovery — comma-separated peer endpoints
DISCOVERY_ENDPOINTS=${DISCOVERY_ENDPOINTS}

# Runtime paths
RUNTIME_DIR=${RUNTIME_DIR}
LOG_DIR=${RUNTIME_DIR}/logs
TASK_DIR=${RUNTIME_DIR}/tasks
EOF

    chmod 600 "$ENV_FILE"
    success "Generated: $(cyan "$ENV_FILE")"

    echo ""
    echo "  Contents:"
    while IFS= read -r line; do
        # Skip blank lines and comments for cleaner display
        [[ -z "$line" || "$line" =~ ^#.* ]] && continue
        echo "    $line"
    done < "$ENV_FILE"
fi

# ═══════════════════════════════════════════════════════════
#  STEP 8 — SUCCESS MESSAGE & NEXT STEPS
# ═══════════════════════════════════════════════════════════
echo ""
green "╔══════════════════════════════════════════════════════════╗"
green "║                                                          ║"
green "║    ✓  HERMES MESH NODE BOOTSTRAPPED SUCCESSFULLY         ║"
green "║                                                          ║"
green "╚══════════════════════════════════════════════════════════╝"

echo ""
bold "  📋 Node Summary"
bold "  ──────────────────────────────────────────────"
echo   "    Node ID:         $(green "$NODE_ID")"
echo   "    Node Type:       $(cyan "$NODE_TYPE")"
echo   "    Mesh Version:    v${MESH_VERSION}"
echo   "    Config:          $(cyan "$NODE_CAPS")"
echo   "    Runtime:         $(cyan "$RUNTIME_DIR")"
echo   "    Env File:        $(cyan "$ENV_FILE")"
echo   "    Discovery:       ${DISCOVERY_ENDPOINTS}"

echo ""
bold "  🚀 Next Steps"
bold "  ──────────────────────────────────────────────"
echo   "    1. Source the env:  $(cyan "source ${ENV_FILE}")"
echo   "    2. Pull missing models (if any) — see model list above"
echo   "    3. Start the mesh daemon (future: hermesctl mesh start)"
echo   "    4. Check logs:      $(cyan "tail -f ${RUNTIME_DIR}/logs/mesh.log")"
echo   "    5. Health probe:    $(cyan "curl http://127.0.0.1:11434/api/tags")"
echo ""

# ═══════════════════════════════════════════════════════════
#  EXIT
# ═══════════════════════════════════════════════════════════
exit 0
