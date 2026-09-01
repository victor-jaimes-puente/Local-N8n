# Phase 1: Foundational Zero-Trust Pull Backups Runbook

This runbook documents the operational workflow, installation, manual execution, and disaster-recovery procedures for **Phase 1: Foundational Zero-Trust Pull Backups**.

---

## 1. Overview & Architecture

- **Execution Model**: The M4 Pro MacBook acts as the backup master, pulling data from `silver-worker` over the NordVPN Meshnet tunnel.
- **Zero Server Footprint**: 
  - PostgreSQL `pg_dump` binary stream (`-Fc`) is piped directly across the SSH connection to the Mac without intermediate server-side files.
  - Docker named volumes (`n8n_storage`, `n8n_local_files`, `caddy_data`) are mounted read-only via ephemeral `alpine` containers (`docker run --rm -v <vol>:/data:ro alpine tar -czf - -C /data .`) and streamed directly over SSH to the Mac.
- **Configuration Mirroring**: `rsync -avz` synchronizes Docker configurations, Caddy gateway profiles, systemd service units, SearXNG definitions, and workflows to local disk.
- **Packaging & Retention**: A consolidated, timestamped `.tar.gz` archive is generated with SHA256 checksums. Backups older than 14 days are automatically pruned.
- **Scheduling**: Handled by macOS `launchd` via `StartCalendarInterval` (default `03:30 AM`), which runs on schedule or immediately upon waking if the MacBook was asleep.

---

## 2. Directory Layout on Mac Workstation

Backups are organized under `~/Backups/Local-N8n/`:

```text
~/Backups/Local-N8n/
├── archives/
│   ├── local-n8n-backup-20260901_033000.tar.gz
│   └── local-n8n-backup-20260901_033000.tar.gz.sha256
├── config/
│   └── latest/                       # Rsync mirror of /home/silver-worker/Local-N8n
├── db/
│   └── n8n_db_20260901_033000.dump   # Native PostgreSQL custom format dump
├── volumes/
│   ├── vol_Local-N8n_n8n_storage_20260901_033000.tar.gz
│   ├── vol_Local-N8n_n8n_local_files_20260901_033000.tar.gz
│   └── vol_gateway_caddy_data_20260901_033000.tar.gz
└── logs/
    ├── backup_2026-09-01.log
    ├── launchd.stdout.log
    └── launchd.stderr.log
```

---

## 3. LaunchAgent Installation & Management

### Install the Scheduled Agent
To register the daily backup job with macOS `launchd`:

```bash
# 1. Create the LaunchAgents directory if it doesn't exist
mkdir -p ~/Library/LaunchAgents

# 2. Copy the plist configuration
cp systemd/mac-launchd/com.local-n8n.backup.plist ~/Library/LaunchAgents/

# 3. Load and register the daemon
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.local-n8n.backup.plist
```

### Trigger an Immediate Manual Run via launchd
```bash
launchctl kickstart -k gui/$(id -u)/com.local-n8n.backup
```

### Check Agent Status / View Logs
```bash
# Check if agent is registered
launchctl list | grep local-n8n

# Follow the live backup logs
tail -f ~/Backups/Local-N8n/logs/backup_$(date +"%Y-%m-%d").log
```

### Unload / Uninstall the Agent
```bash
launchctl bootout gui/$(id -u)/com.local-n8n.backup
rm ~/Library/LaunchAgents/com.local-n8n.backup.plist
```

---

## 4. Manual Execution & CLI Usage

### Run an Ad-Hoc Backup
Execute directly from the repository root:

```bash
./scripts/backup-pull.sh
```

### Custom Backup Parameters
You can override target host, volumes, paths, or retention periods via environment variables:

```bash
BACKUP_REMOTE_HOST="silver-worker" \
BACKUP_VOLUMES="n8n_storage,n8n_local_files,caddy_data" \
BACKUP_DIR="$HOME/Backups/Local-N8n" \
BACKUP_RETENTION_DAYS="30" \
./scripts/backup-pull.sh
```

---

## 5. Verification & Disaster Recovery

### Verify an Existing Backup Archive or Dump
```bash
# Verify checksum and list database objects inside the dump
./scripts/restore-from-backup.sh --verify ~/Backups/Local-N8n/db/n8n_db_20260901_033000.dump

# Or verify the full consolidated tar.gz archive
./scripts/restore-from-backup.sh --verify ~/Backups/Local-N8n/archives/local-n8n-backup-20260901_033000.tar.gz
```

### Restore Database to silver-worker
In the event of database corruption or rollback:

```bash
./scripts/restore-from-backup.sh --restore-db ~/Backups/Local-N8n/db/n8n_db_20260901_033000.dump
```

### Restore a Docker Named Volume
To restore persistent node storage or certificates back to `silver-worker`:

```bash
./scripts/restore-from-backup.sh --restore-volume \
    ~/Backups/Local-N8n/volumes/vol_Local-N8n_n8n_storage_20260901_033000.tar.gz \
    Local-N8n_n8n_storage
```
