# Append this snippet to your existing macOS backup-pull.sh script

# -------------------------------------------------------------
# PHASE 2: HOST CONFIGURATION STATE BACKUP
# -------------------------------------------------------------

# Configuration
SERVER_IP="<silver-worker-meshnet-ip>"
SERVER_USER="silver-worker"
SCRIPT_PATH="/opt/scripts/gather-host-state.sh" # Path where you saved the script on Ubuntu
LOCAL_BACKUP_DEST="/path/to/mac/backups/host-state-$(date +%F).tar.gz" # Adjust as needed

echo "[+] Triggering host state gathering on the server..."
# SSH into the server and run the script via sudo. 
# Requires passwordless sudo configuration in visudo for this specific script.
ssh "${SERVER_USER}@${SERVER_IP}" "sudo $SCRIPT_PATH"

echo "[+] Pulling host state archive..."
# Pull the generated tarball securely over the meshnet SSH connection
rsync -avz -e ssh "${SERVER_USER}@${SERVER_IP}:/tmp/host-state-backup.tar.gz" "$LOCAL_BACKUP_DEST"

echo "[+] Cleaning up server archive..."
ssh "${SERVER_USER}@${SERVER_IP}" "rm /tmp/host-state-backup.tar.gz"

echo "[+] Phase 2 Host State Backup completed."
