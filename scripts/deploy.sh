#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
ENV="${1:-dev}"
STACK="${2:-}"

usage() {
    cat << EOF
Usage: $0 <stack> [environment]

Deploy a Docker Compose stack.

Stacks:
  monitoring      - Prometheus, Grafana, Node Exporter, cAdvisor, Alertmanager
  logging         - Loki, Promtail, Grafana
  webapp          - Nginx, Node.js, PostgreSQL, Redis, Certbot
  dev-environment - PostgreSQL, Redis, MongoDB, Adminer, MailHog, MinIO, Portainer
  ci-cd           - Gitea, Woodpecker CI, PostgreSQL, Registry
  security        - Vaultwarden, CrowdSec, Authelia

Environments:
  dev             - Development settings (default)
  prod            - Production settings

Examples:
  $0 monitoring dev
  $0 webapp prod
  $0 dev-environment dev

EOF
    exit 1
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

if [ -z "$STACK" ]; then
    usage
fi

STACK_DIR="${REPO_DIR}/stacks/${STACK}"
if [ ! -d "$STACK_DIR" ]; then
    echo "Error: Stack '${STACK}' not found at ${STACK_DIR}"
    usage
fi

log "Deploying stack: ${STACK} (env: ${ENV})"

# Copy env file if it exists
ENV_FILE="${STACK_DIR}/.env.${ENV}"
if [ -f "$ENV_FILE" ]; then
    log "Using environment file: ${ENV_FILE}"
    cp "$ENV_FILE" "${STACK_DIR}/.env"
elif [ -f "${STACK_DIR}/.env" ]; then
    log "Using existing .env file"
else
    log "No .env file found, using defaults"
fi

# Deploy the stack
cd "$STACK_DIR"

case "$ENV" in
    dev)
        log "Starting in development mode..."
        docker compose up -d --remove-orphans
        ;;
    prod)
        log "Starting in production mode..."
        docker compose -f docker-compose.yml up -d --remove-orphans
        ;;
    *)
        echo "Error: Unknown environment '${ENV}'. Use 'dev' or 'prod'."
        exit 1
        ;;
esac

log "Waiting for health checks..."
sleep 5

# Show status
docker compose ps
log "Stack '${STACK}' deployed successfully"

# Show access information
case "$STACK" in
    monitoring)
        echo ""
        echo "Grafana:      http://localhost:3000"
        echo "Prometheus:   http://localhost:9090"
        echo "Alertmanager: http://localhost:9093"
        ;;
    logging)
        echo ""
        echo "Grafana: http://localhost:3000"
        echo "Nginx:   http://localhost:8080"
        ;;
    webapp)
        echo ""
        echo "Application: http://localhost"
        ;;
    dev-environment)
        echo ""
        echo "Adminer:     http://localhost:8080"
        echo "MailHog:     http://localhost:8025"
        echo "MinIO:       http://localhost:9001"
        echo "Portainer:   https://localhost:9443"
        ;;
    ci-cd)
        echo ""
        echo "Gitea:       http://localhost:3000"
        echo "Woodpecker:  http://localhost:8000"
        echo "Registry:    http://localhost:5000"
        ;;
    security)
        echo ""
        echo "Vaultwarden: http://localhost:8080"
        echo "Authelia:    http://localhost:9091"
        ;;
esac
