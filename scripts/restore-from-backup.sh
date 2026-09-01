#!/usr/bin/env bash
# ==============================================================================
# Local-N8n Restore & Verification Script (macOS / Local Workstation)
# ==============================================================================
# Description: Validates or restores PostgreSQL database dumps, Docker named
#              volumes, and configurations back to silver-worker over Meshnet.
# ==============================================================================

set -euo pipefail

REMOTE_HOST="${BACKUP_REMOTE_HOST:-silver-worker}"
REMOTE_USER="${BACKUP_REMOTE_USER:-silver-worker}"
REMOTE_DIR="${BACKUP_REMOTE_DIR:-/home/silver-worker/Local-N8n}"
SSH_PORT="${BACKUP_SSH_PORT:-22}"
CONNECT_TIMEOUT="${BACKUP_CONNECT_TIMEOUT:-15}"

BACKUP_ROOT="${BACKUP_DIR:-$HOME/Backups/Local-N8n}"
SSH_TARGET="${REMOTE_USER}@${REMOTE_HOST}"
SSH_OPTS=(-o "BatchMode=yes" -o "ConnectTimeout=${CONNECT_TIMEOUT}" -p "${SSH_PORT}")

usage() {
    echo "Usage: $0 [options] <target-file> [optional-target-volume-name]"
    echo ""
    echo "Commands:"
    echo "  --verify <file>                        Verify dump/tar archive integrity and catalog"
    echo "  --restore-db <file>                    Restore PostgreSQL database dump to silver-worker"
    echo "  --restore-volume <file> <volume-name>  Restore a volume tar.gz archive into a Docker named volume"
    echo "  --help                                 Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --verify ~/Backups/Local-N8n/db/n8n_db_20260901_033000.dump"
    echo "  $0 --verify ~/Backups/Local-N8n/archives/local-n8n-backup-20260901_033000.tar.gz"
    echo "  $0 --restore-db ~/Backups/Local-N8n/db/n8n_db_20260901_033000.dump"
    echo "  $0 --restore-volume ~/Backups/Local-N8n/volumes/vol_Local-N8n_n8n_storage_20260901_033000.tar.gz Local-N8n_n8n_storage"
    exit 1
}

if [[ $# -lt 2 ]]; then
    usage
fi

ACTION="$1"
TARGET_FILE="$2"

if [[ ! -f "${TARGET_FILE}" ]]; then
    echo "ERROR: File does not exist: ${TARGET_FILE}"
    exit 1
fi

case "${ACTION}" in
    --verify)
        echo "=== Verifying Backup Integrity ==="
        echo "File: ${TARGET_FILE}"
        
        if [[ "${TARGET_FILE}" =~ \.tar\.gz$ ]]; then
            echo "Testing tar.gz archive structure & contents..."
            tar -tzvf "${TARGET_FILE}"
            echo "[OK] Tar archive integrity verified."
            
            # Extract dump to inspect database objects if present
            TEMP_DIR="$(mktemp -d)"
            trap 'rm -rf "${TEMP_DIR}"' EXIT
            tar -xzf "${TARGET_FILE}" -C "${TEMP_DIR}"
            EXTRACTED_DUMP="$(find "${TEMP_DIR}" -name "*.dump" | head -n 1)"
            if [[ -n "${EXTRACTED_DUMP}" ]]; then
                echo "Inspecting embedded PostgreSQL dump catalog..."
                TARGET_FILE="${EXTRACTED_DUMP}"
            else
                echo "No embedded .dump file found in archive."
                exit 0
            fi
        fi

        if command -v pg_restore >/dev/null 2>&1; then
            echo "Running local pg_restore --list..."
            pg_restore --list "${TARGET_FILE}" | head -n 25
        else
            echo "Streaming dump header to silver-worker for pg_restore inspection..."
            ssh "${SSH_OPTS[@]}" "${SSH_TARGET}" "docker exec -i \$(docker ps -q -f 'name=postgres' | head -n 1) pg_restore --list" < "${TARGET_FILE}" | head -n 25
        fi
        echo "=== [SUCCESS] Backup verification completed successfully. ==="
        ;;

    --restore-db)
        echo "=================================================================="
        echo "                      DATABASE RESTORE"
        echo "=================================================================="
        echo "Target host: ${SSH_TARGET}"
        echo "Source file: ${TARGET_FILE}"
        echo ""
        read -r -p "WARNING: This will restore and overwrite the database on ${SSH_TARGET}. Proceed? (y/N) " confirm
        if [[ "${confirm}" != "y" && "${confirm}" != "Y" ]]; then
            echo "Restore cancelled by user."
            exit 0
        fi

        if [[ "${TARGET_FILE}" =~ \.tar\.gz$ ]]; then
            TEMP_DIR="$(mktemp -d)"
            trap 'rm -rf "${TEMP_DIR}"' EXIT
            tar -xzf "${TARGET_FILE}" -C "${TEMP_DIR}"
            TARGET_FILE="$(find "${TEMP_DIR}" -name "*.dump" | head -n 1)"
            if [[ -z "${TARGET_FILE}" ]]; then
                echo "ERROR: No .dump file found inside archive."
                exit 2
            fi
        fi

        echo "Stopping n8n and n8n-worker containers before database restoration..."
        ssh "${SSH_OPTS[@]}" "${SSH_TARGET}" "docker compose -f ${REMOTE_DIR}/compose.yaml stop n8n n8n-worker"

        echo "Streaming pg_restore to remote PostgreSQL container..."
        ssh "${SSH_OPTS[@]}" "${SSH_TARGET}" bash -s << 'REMOTE_RESTORE' < "${TARGET_FILE}"
set -euo pipefail
POSTGRES_CONTAINER="$(docker ps -q -f "name=postgres" | head -n 1)"
docker exec -i "${POSTGRES_CONTAINER}" sh -c 'pg_restore -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-postgres}" --clean --if-exists'
REMOTE_RESTORE

        echo "Restarting n8n and n8n-worker containers..."
        ssh "${SSH_OPTS[@]}" "${SSH_TARGET}" "docker compose -f ${REMOTE_DIR}/compose.yaml start n8n n8n-worker"

        echo "=== [SUCCESS] PostgreSQL database restored and services restarted. ==="
        ;;

    --restore-volume)
        if [[ $# -lt 3 ]]; then
            echo "ERROR: Missing target Docker volume name."
            echo "Usage: $0 --restore-volume <archive.tar.gz> <volume-name>"
            exit 1
        fi
        VOL_NAME="$3"
        echo "=================================================================="
        echo "                   DOCKER VOLUME RESTORE"
        echo "=================================================================="
        echo "Target Host:   ${SSH_TARGET}"
        echo "Source File:   ${TARGET_FILE}"
        echo "Target Volume: ${VOL_NAME}"
        echo ""
        read -r -p "WARNING: This will unpack data directly into Docker volume '${VOL_NAME}' on ${SSH_TARGET}. Proceed? (y/N) " confirm
        if [[ "${confirm}" != "y" && "${confirm}" != "Y" ]]; then
            echo "Restore cancelled by user."
            exit 0
        fi

        echo "Restoring volume archive into '${VOL_NAME}' via ephemeral alpine container..."
        ssh "${SSH_OPTS[@]}" "${SSH_TARGET}" "docker run --rm -i -v \"${VOL_NAME}:/data\" alpine tar -xzf - -C /data" < "${TARGET_FILE}"

        echo "=== [SUCCESS] Docker volume '${VOL_NAME}' restored successfully. ==="
        ;;

    *)
        usage
        ;;
esac
