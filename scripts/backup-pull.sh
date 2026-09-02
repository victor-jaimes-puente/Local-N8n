#!/usr/bin/env bash
# ==============================================================================
# Local-N8n Zero-Trust Pull Backup Script (macOS / Local Workstation)
# ==============================================================================
# Description: Connects to silver-worker over NordVPN Meshnet via SSH,
#              streams PostgreSQL database dump directly to local disk,
#              streams compressed Docker named volumes (n8n_storage, etc.),
#              syncs configuration files via rsync, packages a verified archive,
#              and prunes archives past the retention window.
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# Configuration Defaults (Override via environment variables if desired)
# ------------------------------------------------------------------------------
REMOTE_HOST="${BACKUP_REMOTE_HOST:-100.116.224.88}"
REMOTE_USER="${BACKUP_REMOTE_USER:-silver-worker}"
REMOTE_DIR="${BACKUP_REMOTE_DIR:-/home/silver-worker/Local-N8n}"
SSH_PORT="${BACKUP_SSH_PORT:-22}"
CONNECT_TIMEOUT="${BACKUP_CONNECT_TIMEOUT:-15}"
SSH_KEY="${BACKUP_SSH_KEY:-$HOME/.ssh/id_ed25519}"

BACKUP_ROOT="${BACKUP_DIR:-$HOME/Backups/Local-N8n}"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-14}"

# Docker named volume patterns to discover and stream
DEFAULT_VOLUMES=("n8n_storage" "n8n_local_files" "caddy_data")
IFS=',' read -r -a TARGET_VOLUMES <<< "${BACKUP_VOLUMES:-n8n_storage,n8n_local_files,caddy_data}"

TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
DATE_STAMP="$(date +"%Y-%m-%d")"

DB_BACKUP_DIR="${BACKUP_ROOT}/db"
VOLUMES_BACKUP_DIR="${BACKUP_ROOT}/volumes"
CONFIG_BACKUP_DIR="${BACKUP_ROOT}/config"
ARCHIVE_DIR="${BACKUP_ROOT}/archives"
LOG_DIR="${BACKUP_ROOT}/logs"
LOG_FILE="${LOG_DIR}/backup_${DATE_STAMP}.log"

SSH_TARGET="${REMOTE_USER}@${REMOTE_HOST}"
SSH_OPTS=(-o "BatchMode=yes" -o "ConnectTimeout=${CONNECT_TIMEOUT}" -p "${SSH_PORT}")

if [[ -f "${SSH_KEY}" ]]; then
    SSH_OPTS+=(-i "${SSH_KEY}")
fi

# ------------------------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------------------------
log() {
    local level="$1"
    shift
    local msg="[$(date +'%Y-%m-%d %H:%M:%S')] [${level}] $*"
    echo "${msg}"
    if [[ -d "${LOG_DIR}" ]]; then
        echo "${msg}" >> "${LOG_FILE}"
    fi
}

log_info()    { log "INFO" "$@"; }
log_warn()    { log "WARN" "$@"; }
log_error()   { log "ERROR" "$@"; }
log_success() { log "SUCCESS" "$@"; }

cleanup_on_error() {
    local exit_code=$?
    if [[ ${exit_code} -ne 0 ]]; then
        log_error "Backup process aborted unexpectedly with exit code ${exit_code}."
    fi
}
trap cleanup_on_error EXIT

# ------------------------------------------------------------------------------
# Pre-Flight Validation
# ------------------------------------------------------------------------------
mkdir -p "${DB_BACKUP_DIR}" "${VOLUMES_BACKUP_DIR}" "${CONFIG_BACKUP_DIR}/latest" "${ARCHIVE_DIR}" "${LOG_DIR}"

log_info "================================================================="
log_info "Starting Local-N8n Zero-Trust Pull Backup: ${TIMESTAMP}"
log_info "Target Host: ${SSH_TARGET}:${REMOTE_DIR}"
log_info "Destination: ${BACKUP_ROOT}"
log_info "================================================================="

# Check SSH Connectivity
log_info "Verifying SSH connectivity to ${SSH_TARGET}..."
if ! ssh "${SSH_OPTS[@]}" "${SSH_TARGET}" "echo 'SSH connection verified'" >/dev/null 2>&1; then
    log_error "Cannot reach ${SSH_TARGET} over SSH/Meshnet. Please check network/Meshnet tunnel."
    exit 1
fi
log_success "SSH connection established successfully."

# ------------------------------------------------------------------------------
# 1. Stream PostgreSQL Live Database Dump (Zero Server Disk Footprint)
# ------------------------------------------------------------------------------
DUMP_FILENAME="n8n_db_${TIMESTAMP}.dump"
LOCAL_DUMP_PATH="${DB_BACKUP_DIR}/${DUMP_FILENAME}"

log_info "Streaming live PostgreSQL pg_dump over SSH tunnel..."

# Query postgres container name or id and execute pg_dump directly to stream
ssh "${SSH_OPTS[@]}" "${SSH_TARGET}" bash -s << 'REMOTE_COMMAND' > "${LOCAL_DUMP_PATH}"
set -euo pipefail
POSTGRES_CONTAINER="$(docker ps -q -f "name=postgres" | head -n 1)"
if [[ -z "${POSTGRES_CONTAINER}" ]]; then
    echo "ERROR: PostgreSQL container is not running on remote host." >&2
    exit 2
fi

# Run pg_dump inside the container and stream binary custom format (-Fc) to stdout
docker exec -i "${POSTGRES_CONTAINER}" sh -c 'pg_dump -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-postgres}" -Fc -b'
REMOTE_COMMAND

# Verify dump file was generated and is not zero bytes
if [[ ! -s "${LOCAL_DUMP_PATH}" ]]; then
    log_error "PostgreSQL dump file is empty or missing: ${LOCAL_DUMP_PATH}"
    rm -f "${LOCAL_DUMP_PATH}"
    exit 3
fi

DUMP_SIZE="$(du -h "${LOCAL_DUMP_PATH}" | cut -f1)"
log_success "PostgreSQL dump streamed successfully (${DUMP_SIZE}): ${LOCAL_DUMP_PATH}"

# ------------------------------------------------------------------------------
# 2. Stream Docker Named Volumes via Read-Only Ephemeral Containers
# ------------------------------------------------------------------------------
log_info "Streaming Docker named volumes over SSH..."

# Query existing docker volumes on the remote host
REMOTE_VOLUME_LIST="$(ssh "${SSH_OPTS[@]}" "${SSH_TARGET}" "docker volume ls -q")"

CURRENT_VOLUME_FILES=()

for VOL_PATTERN in "${TARGET_VOLUMES[@]}"; do
    MATCHED_VOL="$(echo "${REMOTE_VOLUME_LIST}" | grep -E "(^|_)${VOL_PATTERN}$" | head -n 1 || true)"
    
    if [[ -z "${MATCHED_VOL}" ]]; then
        log_warn "Volume matching '${VOL_PATTERN}' not found on ${SSH_TARGET}. Skipping."
        continue
    fi

    VOL_ARCHIVE_NAME="vol_${MATCHED_VOL}_${TIMESTAMP}.tar.gz"
    LOCAL_VOL_PATH="${VOLUMES_BACKUP_DIR}/${VOL_ARCHIVE_NAME}"

    log_info "Streaming volume '${MATCHED_VOL}' to ${VOL_ARCHIVE_NAME}..."

    ssh "${SSH_OPTS[@]}" "${SSH_TARGET}" \
        "docker run --rm -v \"${MATCHED_VOL}:/data:ro\" alpine tar -czf - -C /data ." > "${LOCAL_VOL_PATH}"

    if [[ ! -s "${LOCAL_VOL_PATH}" ]]; then
        log_warn "Volume archive for ${MATCHED_VOL} is empty or failed to stream. Removing."
        rm -f "${LOCAL_VOL_PATH}"
    else
        VOL_SIZE="$(du -h "${LOCAL_VOL_PATH}" | cut -f1)"
        log_success "Volume '${MATCHED_VOL}' streamed successfully (${VOL_SIZE})."
        CURRENT_VOLUME_FILES+=("${VOL_ARCHIVE_NAME}")
    fi
done

# ------------------------------------------------------------------------------
# 3. Sync Configuration and Definition Files
# ------------------------------------------------------------------------------
log_info "Pulling server configuration files via rsync..."

SSH_RSYNC_CMD="ssh -o BatchMode=yes -o ConnectTimeout=${CONNECT_TIMEOUT} -p ${SSH_PORT}"
if [[ -f "${SSH_KEY}" ]]; then
    SSH_RSYNC_CMD="${SSH_RSYNC_CMD} -i ${SSH_KEY}"
fi

rsync -avz --delete \
    -e "${SSH_RSYNC_CMD}" \
    --exclude '.git' \
    --exclude '.DS_Store' \
    --exclude '*.log' \
    --exclude 'node_modules' \
    --exclude '.env' \
    "${SSH_TARGET}:${REMOTE_DIR}/" \
    "${CONFIG_BACKUP_DIR}/latest/" >> "${LOG_FILE}" 2>&1

log_success "Configuration synchronization complete."

# ------------------------------------------------------------------------------
# 3.5 Phase 2: Host Configuration State Backup
# ------------------------------------------------------------------------------
log_info "Triggering host state gathering on the server..."

HOST_BACKUP_DIR="${BACKUP_ROOT}/host_state"
mkdir -p "${HOST_BACKUP_DIR}"
HOST_ARCHIVE_NAME="host-state-${TIMESTAMP}.tar.gz"
LOCAL_HOST_BACKUP_PATH="${HOST_BACKUP_DIR}/${HOST_ARCHIVE_NAME}"
SCRIPT_PATH="/opt/scripts/gather-host-state.sh"

ssh "${SSH_OPTS[@]}" "${SSH_TARGET}" "sudo ${SCRIPT_PATH}"

log_info "Pulling host state archive..."
rsync -avz -e "${SSH_RSYNC_CMD}" \
    "${SSH_TARGET}:/tmp/host-state-backup.tar.gz" "${LOCAL_HOST_BACKUP_PATH}" >> "${LOG_FILE}" 2>&1

log_info "Cleaning up server archive..."
ssh "${SSH_OPTS[@]}" "${SSH_TARGET}" "rm -f /tmp/host-state-backup.tar.gz || true"

if [[ -s "${LOCAL_HOST_BACKUP_PATH}" ]]; then
    HOST_SIZE="$(du -h "${LOCAL_HOST_BACKUP_PATH}" | cut -f1)"
    log_success "Host state backup pulled successfully (${HOST_SIZE})."
else
    log_warn "Host state backup failed or is empty."
fi

# ------------------------------------------------------------------------------
# 4. Create Compressed Combined Snapshot & Checksum
# ------------------------------------------------------------------------------
ARCHIVE_NAME="local-n8n-backup-${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${ARCHIVE_DIR}/${ARCHIVE_NAME}"

log_info "Creating compressed backup archive: ${ARCHIVE_NAME}..."

TAR_INPUT_ARGS=(-C "${DB_BACKUP_DIR}" "${DUMP_FILENAME}" -C "${CONFIG_BACKUP_DIR}" "latest")

if [[ -s "${LOCAL_HOST_BACKUP_PATH:-}" ]]; then
    TAR_INPUT_ARGS+=(-C "${HOST_BACKUP_DIR}" "${HOST_ARCHIVE_NAME}")
fi

for VOL_FILE in "${CURRENT_VOLUME_FILES[@]}"; do
    TAR_INPUT_ARGS+=(-C "${VOLUMES_BACKUP_DIR}" "${VOL_FILE}")
done

tar -czf "${ARCHIVE_PATH}" "${TAR_INPUT_ARGS[@]}"

ARCHIVE_SIZE="$(du -h "${ARCHIVE_PATH}" | cut -f1)"

# Generate SHA256 Checksum
if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "${ARCHIVE_PATH}" > "${ARCHIVE_PATH}.sha256"
elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "${ARCHIVE_PATH}" > "${ARCHIVE_PATH}.sha256"
fi

log_success "Backup archive created successfully (${ARCHIVE_SIZE}): ${ARCHIVE_PATH}"

# ------------------------------------------------------------------------------
# 5. Retention Policy & Pruning
# ------------------------------------------------------------------------------
log_info "Applying retention policy (retaining last ${RETENTION_DAYS} days)..."

# Prune archives older than RETENTION_DAYS
find "${ARCHIVE_DIR}" -name "local-n8n-backup-*.tar.gz" -mtime "+${RETENTION_DAYS}" -print -delete >> "${LOG_FILE}" 2>&1 || true
find "${ARCHIVE_DIR}" -name "local-n8n-backup-*.sha256" -mtime "+${RETENTION_DAYS}" -print -delete >> "${LOG_FILE}" 2>&1 || true

# Prune raw db dumps older than RETENTION_DAYS
find "${DB_BACKUP_DIR}" -name "n8n_db_*.dump" -mtime "+${RETENTION_DAYS}" -print -delete >> "${LOG_FILE}" 2>&1 || true

# Prune volume archives older than RETENTION_DAYS
find "${VOLUMES_BACKUP_DIR}" -name "vol_*.tar.gz" -mtime "+${RETENTION_DAYS}" -print -delete >> "${LOG_FILE}" 2>&1 || true

# Prune host state archives older than RETENTION_DAYS
if [[ -d "${HOST_BACKUP_DIR:-}" ]]; then
    find "${HOST_BACKUP_DIR}" -name "host-state-*.tar.gz" -mtime "+${RETENTION_DAYS}" -print -delete >> "${LOG_FILE}" 2>&1 || true
fi

# Prune log files older than 30 days
find "${LOG_DIR}" -name "backup_*.log" -mtime +30 -print -delete >> "${LOG_FILE}" 2>&1 || true

log_success "Retention pruning completed."
log_info "================================================================="
log_info "Local-N8n Backup completed successfully at $(date +'%Y-%m-%d %H:%M:%S')"
log_info "================================================================="
exit 0
