#!/usr/bin/env bash
# gather-host-state.sh
# Gathers host configuration state and packages into a tarball.
# Intended to be run via sudo by silver-worker on the Ubuntu server.

set -euo pipefail

BACKUP_DIR="/tmp/host-state-backup-$$"
mkdir -p "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR/etc"
mkdir -p "$BACKUP_DIR/home-silver-worker"

echo "Exporting APT package selections..."
dpkg --get-selections > "$BACKUP_DIR/packages.list"

echo "Copying /etc configurations..."
# Using cp -a to preserve permissions where possible. 2>/dev/null ignores missing directories.
cp -a /etc/systemd "$BACKUP_DIR/etc/" 2>/dev/null || true
cp -a /etc/ufw "$BACKUP_DIR/etc/" 2>/dev/null || true
cp -a /etc/ssh "$BACKUP_DIR/etc/" 2>/dev/null || true
cp -a /etc/netplan "$BACKUP_DIR/etc/" 2>/dev/null || true
cp -a /etc/docker "$BACKUP_DIR/etc/" 2>/dev/null || true
cp -a /etc/cron* "$BACKUP_DIR/etc/" 2>/dev/null || true
cp -a /etc/fstab "$BACKUP_DIR/etc/" 2>/dev/null || true
cp -a /etc/apt/sources.list "$BACKUP_DIR/etc/apt-sources.list" 2>/dev/null || true

echo "Copying user state (excluding Local-N8n and caches)..."
cp -a /home/silver-worker/.doppler "$BACKUP_DIR/home-silver-worker/" 2>/dev/null || true
cp -a /home/silver-worker/.ssh "$BACKUP_DIR/home-silver-worker/" 2>/dev/null || true
cp -a /home/silver-worker/.bashrc "$BACKUP_DIR/home-silver-worker/" 2>/dev/null || true
cp -a /home/silver-worker/.profile "$BACKUP_DIR/home-silver-worker/" 2>/dev/null || true

echo "Creating tarball..."
TAR_DEST="/tmp/host-state-backup.tar.gz"
tar -czf "$TAR_DEST" -C "/tmp" "$(basename "$BACKUP_DIR")"

echo "Cleaning up temp dir..."
rm -rf "$BACKUP_DIR"

echo "Host state backup ready at $TAR_DEST"
