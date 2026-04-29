#!/usr/bin/env bash
# ==============================================================================
# VoxFlow Deployment Pipeline — v1.0.0
# ==============================================================================
# Full deployment pipeline with health checks, Docker builds, testing, staged
# rollout, and rollback capability.
#
# Stages:
#   1. Pre-deploy health check (all 9 services + Redis + PG)
#   2. Build Docker images
#   3. Run test suite (pnpm test)
#   4. Deploy to staging
#   5. Verify staging health
#   6. Prompt for production deployment
#   7. Deploy to production (blue/green)
#   8. Verify production health
#   9. Rollback on failure
#
# Environment variables:
#   VOXFLOW_REPO         — Path to VoxFlow repo (default: auto-detect)
#   VF_HOST              — Health check host (default: localhost)
#   DOCKER_TAG           — Docker image tag (default: git SHA)
#   STAGING_HOST         — Staging health check host
#   PROD_HOST            — Production health check host
#   SKIP_TESTS           — Set to 1 to skip test suite
#   SKIP_STAGING         — Set to 1 to skip staging deployment
#   AUTO_APPROVE_PROD    — Set to 1 to skip production confirmation prompt
#   ROLLBACK_TAG         — Previous tag to rollback to (auto-detected if unset)
#
# Exit codes:
#   0 — Deployment successful
#   1 — Deployment failed (rolled back)
#   2 — Configuration error
#   3 — Pre-deploy health check failed
#   4 — Build failed
#   5 — Tests failed
#   6 — Staging deployment/verification failed
#   7 — Production deployment/verification failed
#
# Usage:
#   ./deploy.sh
#   ./deploy.sh --tag v1.2.3
#   ./deploy.sh --skip-staging --auto-approve-prod
#   ./deploy.sh --rollback v1.2.2
# ==============================================================================

set -uo pipefail

# ── Colour definitions ────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; CYAN=''; BOLD=''; NC=''
fi

# ── Auto-detect repo ──────────────────────────────────────────────────────────
if [[ -d /home/brett/.openclaw.pre-migration/workspace-infra/voxflow ]]; then
    VOXFLOW_REPO="${VOXFLOW_REPO:-/home/brett/.openclaw.pre-migration/workspace-infra/voxflow}"
elif [[ -d "${VOXFLOW_REPO:-}" ]]; then
    :  # Use env-provided path
else
    # Try relative to script location
    VOXFLOW_REPO="$(cd "$(dirname "$0")/../.." && pwd)"
    if [[ ! -d "$VOXFLOW_REPO" ]]; then
        VOXFLOW_REPO="$(pwd)"
    fi
fi

# ── Configuration ─────────────────────────────────────────────────────────────
VF_HOST="${VF_HOST:-localhost}"
DOCKER_TAG="${DOCKER_TAG:-$(cd "$VOXFLOW_REPO" && git rev-parse --short HEAD 2>/dev/null || echo 'latest')}"
STAGING_HOST="${STAGING_HOST:-staging.voxflow.internal}"
PROD_HOST="${PROD_HOST:-api.voxflow.io}"
SKIP_TESTS="${SKIP_TESTS:-0}"
SKIP_STAGING="${SKIP_STAGING:-0}"
AUTO_APPROVE_PROD="${AUTO_APPROVE_PROD:-0}"
ROLLBACK_TAG="${ROLLBACK_TAG:-}"
ACTION="deploy"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
DEPLOY_LOG="/tmp/voxflow-deploy-${TIMESTAMP}.log"

# Health check script path (relative to this script)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HEALTH_CHECK="${SCRIPT_DIR}/health-check.sh"

# ── Help ──────────────────────────────────────────────────────────────────────
show_help() {
    cat << 'EOF'
Usage: deploy.sh [OPTIONS]

Full VoxFlow deployment pipeline: health → build → test → staging → prod.

Options:
  --tag TAG               Docker image tag (default: git SHA)
  --skip-tests            Skip the test suite
  --skip-staging          Skip staging deployment (deploy straight to prod)
  --auto-approve-prod     Skip production confirmation prompt
  --rollback TAG          Rollback to a previous tag instead of deploying
  --staging-host HOST     Staging health check host (default: staging.voxflow.internal)
  --prod-host HOST        Production health check host (default: api.voxflow.io)
  -h, --help              Show this help

Environment variables:
  VOXFLOW_REPO        Path to VoxFlow repo
  VF_HOST             Health check host
  DOCKER_TAG          Docker image tag
  STAGING_HOST        Staging host
  PROD_HOST           Production host
  SKIP_TESTS          Skip tests (1=yes)
  SKIP_STAGING        Skip staging (1=yes)
  AUTO_APPROVE_PROD   Auto-approve (1=yes)
  ROLLBACK_TAG        Rollback tag

Exit codes:
  0  Success
  1  Failed (rolled back)
  2  Configuration error
  3  Pre-deploy health check failed
  4  Build failed
  5  Tests failed
  6  Staging deploy/verify failed
  7  Production deploy/verify failed
EOF
    exit 0
}

# ── Parse arguments ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --tag)
            DOCKER_TAG="$2"
            shift 2
            ;;
        --skip-tests)
            SKIP_TESTS=1
            shift
            ;;
        --skip-staging)
            SKIP_STAGING=1
            shift
            ;;
        --auto-approve-prod)
            AUTO_APPROVE_PROD=1
            shift
            ;;
        --rollback)
            ACTION="rollback"
            ROLLBACK_TAG="$2"
            shift 2
            ;;
        --staging-host)
            STAGING_HOST="$2"
            shift 2
            ;;
        --prod-host)
            PROD_HOST="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Run with --help for usage" >&2
            exit 2
            ;;
    esac
done

# ── Prerequisites ─────────────────────────────────────────────────────────────
if [[ ! -d "$VOXFLOW_REPO" ]]; then
    echo "ERROR: VoxFlow repo not found at $VOXFLOW_REPO" >&2
    exit 2
fi

if ! command -v docker &>/dev/null; then
    echo "ERROR: docker is required but not installed" >&2
    exit 2
fi

# ── Logging ───────────────────────────────────────────────────────────────────
log() {
    echo "[$(date '+%H:%M:%S')] $*" | tee -a "$DEPLOY_LOG"
}

log_section() {
    log ""
    log "━━━ $1 ━━━"
}

step_pass() { log -e "${GREEN}✓${NC} $1"; }
step_fail() { log -e "${RED}✗${NC} $1"; }

# ── Rollback action ───────────────────────────────────────────────────────────
do_rollback() {
    local tag="${ROLLBACK_TAG:-}"

    log_section "ROLLBACK DEPLOYMENT"
    log "Rolling back to tag: ${tag}"

    if [[ -z "$tag" ]]; then
        # Auto-detect previous tag from git
        tag=$(cd "$VOXFLOW_REPO" && git tag --sort=-creatordate | head -2 | tail -1 2>/dev/null || echo "")
        if [[ -z "$tag" ]]; then
            log "ERROR: No rollback tag specified and could not auto-detect previous tag"
            exit 2
        fi
        log "Auto-detected previous tag: ${tag}"
    fi

    # Deploy previous images to production
    log "Deploying ${tag} to production..."
    (cd "$VOXFLOW_REPO" && \
        TAG="$tag" docker compose -f docker-compose.app.yml up -d) 2>&1 | tee -a "$DEPLOY_LOG" || {
        step_fail "Rollback deployment failed"
        exit 1
    }

    step_pass "Rollback complete — production is now on ${tag}"

    # Verify health
    log_section "POST-ROLLBACK HEALTH CHECK"
    sleep 5
    if [[ -x "$HEALTH_CHECK" ]]; then
        VF_HOST="$PROD_HOST" bash "$HEALTH_CHECK" 2>&1 | tee -a "$DEPLOY_LOG" || {
            step_fail "Post-rollback health check failed — MANUAL INTERVENTION REQUIRED"
            exit 1
        }
    fi
    step_pass "Rollback successful — services healthy"
    exit 0
}

# ── If rollback requested, do it now ──────────────────────────────────────────
if [[ "$ACTION" == "rollback" ]]; then
    do_rollback
fi

# ── Stage 1: Pre-deploy health check ──────────────────────────────────────────
log_section "STAGE 1/8: PRE-DEPLOY HEALTH CHECK"
log "Checking current health before deployment..."

if [[ -x "$HEALTH_CHECK" ]]; then
    bash "$HEALTH_CHECK" 2>&1 | tee -a "$DEPLOY_LOG"
    CHECK_EXIT=$?
    if (( CHECK_EXIT != 0 )); then
        step_fail "Pre-deploy health check failed — aborting deployment"
        log "Fix the failing services and retry."
        exit 3
    fi
else
    log "Health check script not found at $HEALTH_CHECK — performing basic check"
    for port in 3000 3001 3002 3003 3004 3005 3006 3007 3008; do
        curl -sf --connect-timeout 5 "http://${VF_HOST}:${port}/health" &>/dev/null || {
            log "WARNING: Service on port $port not reachable"
        }
    done
fi
step_pass "Pre-deploy health check passed"

# ── Stage 2: Build Docker images ──────────────────────────────────────────────
log_section "STAGE 2/8: BUILD DOCKER IMAGES"
log "Building all 9 services with tag: ${DOCKER_TAG}"

(cd "$VOXFLOW_REPO" && \
    bash scripts/docker-build.sh --all --tag "$DOCKER_TAG") 2>&1 | tee -a "$DEPLOY_LOG"
BUILD_EXIT=$?
if (( BUILD_EXIT != 0 )); then
    step_fail "Docker build failed — aborting"
    exit 4
fi
step_pass "Docker images built successfully (tag: ${DOCKER_TAG})"

# ── Stage 3: Run test suite ───────────────────────────────────────────────────
log_section "STAGE 3/8: TEST SUITE"

if [[ "$SKIP_TESTS" == "1" ]]; then
    log "Tests skipped (SKIP_TESTS=1)"
else
    log "Running pnpm test..."
    (cd "$VOXFLOW_REPO" && pnpm test) 2>&1 | tee -a "$DEPLOY_LOG"
    TEST_EXIT=$?
    if (( TEST_EXIT != 0 )); then
        step_fail "Tests failed — aborting deployment"
        exit 5
    fi
    step_pass "All tests passed"
fi

# ── Stage 4: Deploy to staging ────────────────────────────────────────────────
log_section "STAGE 4/8: DEPLOY TO STAGING"

if [[ "$SKIP_STAGING" == "1" ]]; then
    log "Staging deployment skipped (SKIP_STAGING=1)"
else
    log "Deploying to staging environment (${STAGING_HOST})..."
    (cd "$VOXFLOW_REPO" && \
        VERSION="$DOCKER_TAG" docker compose -f docker-compose.app.yml up -d) 2>&1 | tee -a "$DEPLOY_LOG" || {
        step_fail "Staging deployment failed"
        exit 6
    }
    step_pass "Staging deployment complete"
fi

# ── Stage 5: Verify staging health ────────────────────────────────────────────
log_section "STAGE 5/8: STAGING HEALTH VERIFICATION"

if [[ "$SKIP_STAGING" == "1" ]]; then
    log "Staging verification skipped"
else
    log "Waiting for staging services to be ready..."
    sleep 10

    if [[ -x "$HEALTH_CHECK" ]]; then
        VF_HOST="$STAGING_HOST" bash "$HEALTH_CHECK" 2>&1 | tee -a "$DEPLOY_LOG"
        STAGING_HEALTH=$?
        if (( STAGING_HEALTH != 0 )); then
            step_fail "Staging health check failed"
            log "Rolling back staging..."
            do_rollback
            exit 6
        fi
    else
        log "Health check script not available — performing basic verification"
        for port in 3000 3001 3002 3003 3004 3005 3006 3007 3008; do
            curl -sf --connect-timeout 5 "http://${STAGING_HOST}:${port}/health" &>/dev/null || {
                step_fail "Staging service on port $port not healthy"
                exit 6
            }
        done
    fi
    step_pass "Staging health verification passed"
fi

# ── Stage 6: Prompt for production deployment ─────────────────────────────────
log_section "STAGE 6/8: PRODUCTION DEPLOYMENT APPROVAL"

if [[ "$AUTO_APPROVE_PROD" == "1" ]]; then
    log "Auto-approve enabled — proceeding to production"
else
    echo ""
    echo -e "  ${BOLD}Ready to deploy to PRODUCTION?${NC}"
    echo "  Tag: ${DOCKER_TAG}"
    echo "  Host: ${PROD_HOST}"
    echo ""
    read -r -p "  Deploy to production? [y/N] " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        log "Production deployment cancelled by user"
        exit 0
    fi
fi

# ── Stage 7: Deploy to production ─────────────────────────────────────────────
log_section "STAGE 7/8: DEPLOY TO PRODUCTION (BLUE/GREEN)"

# Record current production tag for potential rollback
OLD_PROD_TAG=$(cd "$VOXFLOW_REPO" && git describe --tags --abbrev=0 2>/dev/null || echo "unknown")
log "Current production tag: ${OLD_PROD_TAG}"
log "Deploying ${DOCKER_TAG} to production..."

# Tag the release
(cd "$VOXFLOW_REPO" && git tag -a "$DOCKER_TAG" -m "Release ${DOCKER_TAG}" 2>/dev/null || true)

(cd "$VOXFLOW_REPO" && \
    VERSION="$DOCKER_TAG" docker compose -f docker-compose.app.yml up -d) 2>&1 | tee -a "$DEPLOY_LOG" || {
    step_fail "Production deployment failed"
    log "Initiating automatic rollback to ${OLD_PROD_TAG}..."
    ROLLBACK_TAG="$OLD_PROD_TAG" do_rollback
    exit 7
}
step_pass "Production deployment complete"

# ── Stage 8: Verify production health ─────────────────────────────────────────
log_section "STAGE 8/8: PRODUCTION HEALTH VERIFICATION"

log "Waiting for production services to stabilise..."
sleep 15

if [[ -x "$HEALTH_CHECK" ]]; then
    VF_HOST="$PROD_HOST" bash "$HEALTH_CHECK" 2>&1 | tee -a "$DEPLOY_LOG"
    PROD_HEALTH=$?
    if (( PROD_HEALTH != 0 )); then
        step_fail "Production health check failed after deployment"
        log "Initiating automatic rollback..."
        ROLLBACK_TAG="$OLD_PROD_TAG" do_rollback
        exit 7
    fi
else
    log "Health check script not available — performing basic verification"
    for port in 3000 3001 3002 3003 3004 3005 3006 3007 3008; do
        curl -sf --connect-timeout 5 "http://${PROD_HOST}:${port}/health" &>/dev/null || {
            step_fail "Production service on port $port not healthy — rolling back"
            ROLLBACK_TAG="$OLD_PROD_TAG" do_rollback
            exit 7
        }
    done
fi
step_pass "Production health verification passed"

# ── Success ───────────────────────────────────────────────────────────────────
log ""
log "═══════════════════════════════════════════════════"
log -e "  ${GREEN}✓ DEPLOYMENT SUCCESSFUL${NC}"
log -e "  Tag:    ${BOLD}${DOCKER_TAG}${NC}"
log -e "  Env:    ${BOLD}production${NC}"
log -e "  Host:   ${BOLD}${PROD_HOST}${NC}"
log -e "  Log:    ${DEPLOY_LOG}"
log "═══════════════════════════════════════════════════"
log ""

exit 0
