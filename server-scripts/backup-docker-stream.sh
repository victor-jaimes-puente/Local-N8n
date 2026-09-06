#!/usr/bin/env bash
# ==============================================================================
# Local-N8n Root Backup Helper (/opt/scripts/backup-docker-stream.sh)
# ==============================================================================
# Principle of Least Privilege:
# Allows silver-worker to stream PostgreSQL dumps and named volumes
# without granting unrestricted access to /var/run/docker.sock.
# ==============================================================================
set -euo pipefail

case "${1:-}" in
    dump-db)
        POSTGRES_CONTAINER="$(docker ps -q -f "name=postgres" | head -n 1)"
        if [[ -z "${POSTGRES_CONTAINER}" ]]; then
            echo "ERROR: PostgreSQL container not found or not running." >&2
            exit 2
        fi
        docker exec -i "${POSTGRES_CONTAINER}" sh -c 'pg_dump -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-postgres}" -Fc -b'
        ;;
    list-volumes)
        docker volume ls -q
        ;;
    stream-volume)
        VOL_NAME="${2:-}"
        if [[ -z "${VOL_NAME}" || ! "${VOL_NAME}" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            echo "ERROR: Invalid or missing volume name: '${VOL_NAME}'" >&2
            exit 2
        fi
        docker run --rm -v "${VOL_NAME}:/data:ro" alpine tar -czf - -C /data .
        ;;
    clean-host-state)
        rm -f /tmp/host-state-backup.tar.gz
        ;;
    clean-sandbox-tls)
        rm -rf /home/silver-worker/Local-N8n/sandbox/.tls
        ;;
    *)
        echo "Usage: $0 {dump-db|list-volumes|stream-volume <volume_name>|clean-host-state|clean-sandbox-tls}" >&2
        exit 1
        ;;
esac
