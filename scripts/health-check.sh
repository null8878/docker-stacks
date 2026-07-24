#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TOTAL=0
HEALTHY=0
UNHEALTHY=0
STARTING=0

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

check_service() {
    local container=$1
    local status
    local health

    TOTAL=$((TOTAL + 1))

    status=$(docker inspect --format='{{.State.Status}}' "$container" 2>/dev/null || echo "not_found")
    health=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null || echo "none")

    if [ "$status" = "running" ]; then
        if [ "$health" = "healthy" ]; then
            HEALTHY=$((HEALTHY + 1))
            printf "  ${GREEN}✓${NC} %-30s running/healthy\n" "$container"
        elif [ "$health" = "starting" ]; then
            STARTING=$((STARTING + 1))
            printf "  ${YELLOW}~${NC} %-30s running/starting\n" "$container"
        else
            UNHEALTHY=$((UNHEALTHY + 1))
            printf "  ${RED}✗${NC} %-30s running/${health}\n" "$container"
        fi
    elif [ "$status" = "not_found" ]; then
        printf "  ${RED}✗${NC} %-30s not found\n" "$container"
        UNHEALTHY=$((UNHEALTHY + 1))
    else
        UNHEALTHY=$((UNHEALTHY + 1))
        printf "  ${RED}✗${NC} %-30s %s\n" "$container" "$status"
    fi
}

log "Health Check — $(date)"
echo ""

# Monitoring stack
echo "=== Monitoring Stack ==="
for c in prometheus grafana node-exporter cadvisor alertmanager; do
    check_service "$c"
done
echo ""

# Logging stack
echo "=== Logging Stack ==="
for c in loki promtail grafana-logging nginx-example; do
    check_service "$c"
done
echo ""

# Web app stack
echo "=== Web App Stack ==="
for c in webapp-nginx webapp-app webapp-postgres webapp-redis; do
    check_service "$c"
done
echo ""

# Dev environment
echo "=== Dev Environment ==="
for c in dev-postgres dev-redis dev-mongo dev-adminer dev-mailhog dev-minio dev-portainer; do
    check_service "$c"
done
echo ""

# CI/CD stack
echo "=== CI/CD Stack ==="
for c in gitea cicd-postgres woodpecker-server woodpecker-agent cicd-registry; do
    check_service "$c"
done
echo ""

# Security stack
echo "=== Security Stack ==="
for c in vaultwarden crowdsec authelia; do
    check_service "$c"
done
echo ""

# Summary
echo "============================================="
echo "Total: ${TOTAL}  |  ${GREEN}Healthy: ${HEALTHY}${NC}  |  ${YELLOW}Starting: ${STARTING}${NC}  |  ${RED}Unhealthy: ${UNHEALTHY}${NC}"
echo "============================================="

if [ "$UNHEALTHY" -gt 0 ]; then
    exit 1
fi
