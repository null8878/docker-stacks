#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="${BACKUP_DIR:-/tmp/docker-backups}"
DATE=$(date +%Y%m%d_%H%M%S)

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

mkdir -p "${BACKUP_DIR}/${DATE}"

# Backup PostgreSQL databases
backup_postgres() {
    local container=$1
    local user=$2
    local db=$3
    local outfile="${BACKUP_DIR}/${DATE}/${container}_${db}.sql.gz"

    log "Backing up PostgreSQL: ${container} (${db})"
    docker exec "$container" pg_dump -U "$user" "$db" 2>/dev/null | gzip > "$outfile"
    log "Saved: ${outfile} ($(du -h "$outfile" | cut -f1))"
}

# Backup Redis
backup_redis() {
    local container=$1
    local outfile="${BACKUP_DIR}/${DATE}/${container}_dump.rdb"

    log "Backing up Redis: ${container}"
    docker exec "$container" redis-cli BGSAVE >/dev/null 2>&1
    sleep 2
    docker cp "${container}:/data/dump.rdb" "$outfile" 2>/dev/null || true
    log "Saved: ${outfile}"
}

# Backup MongoDB
backup_mongo() {
    local container=$1
    local outfile="${BACKUP_DIR}/${DATE}/${container}_dump.gz"

    log "Backing up MongoDB: ${container}"
    docker exec "$container" mongodump --archive --gzip 2>/dev/null > "$outfile"
    log "Saved: ${outfile} ($(du -h "$outfile" | cut -f1))"
}

# Backup Docker volumes
backup_volume() {
    local volume=$1
    local outfile="${BACKUP_DIR}/${DATE}/${volume}.tar.gz"

    log "Backing up volume: ${volume}"
    docker run --rm \
        -v "${volume}:/source:ro" \
        -v "${BACKUP_DIR}/${DATE}:/backup" \
        alpine tar czf "/backup/${volume}.tar.gz" -C /source . 2>/dev/null
    log "Saved: ${outfile} ($(du -h "$outfile" | cut -f1))"
}

log "Starting backup to ${BACKUP_DIR}/${DATE}"

# Detect and backup running PostgreSQL containers
for container in $(docker ps --format '{{.Names}}' | grep -i postgres 2>/dev/null || true); do
    user=$(docker exec "$container" printenv POSTGRES_USER 2>/dev/null || echo "postgres")
    db=$(docker exec "$container" printenv POSTGRES_DB 2>/dev/null || echo "postgres")
    backup_postgres "$container" "$user" "$db"
done

# Detect and backup running Redis containers
for container in $(docker ps --format '{{.Names}}' | grep -i redis 2>/dev/null || true); do
    backup_redis "$container"
done

# Detect and backup running MongoDB containers
for container in $(docker ps --format '{{.Names}}' | grep -i mongo 2>/dev/null || true); do
    backup_mongo "$container"
done

# Backup named volumes with data
for volume in $(docker volume ls --format '{{.Name}}' | grep -E '(postgres|redis|mongo|minio|gitea|vaultwarden|grafana|prometheus|loki|portainer)' 2>/dev/null || true); do
    backup_volume "$volume"
done

# Create archive of all backups
log "Creating final archive..."
cd "${BACKUP_DIR}"
tar czf "backup_${DATE}.tar.gz" "$DATE"
rm -rf "$DATE"

TOTAL_SIZE=$(du -h "${BACKUP_DIR}/backup_${DATE}.tar.gz" | cut -f1)
log "Backup complete: ${BACKUP_DIR}/backup_${DATE}.tar.gz (${TOTAL_SIZE})"

# Cleanup old backups (keep last 7)
cd "${BACKUP_DIR}"
ls -t backup_*.tar.gz 2>/dev/null | tail -n +8 | xargs rm -f 2>/dev/null || true
log "Old backups cleaned (keeping last 7)"
