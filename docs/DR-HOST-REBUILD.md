# Disaster Recovery Runbook: Host Rebuild

This runbook outlines the steps to recover the `silver-worker` Ubuntu server from scratch using the Phase 2 Host Configuration State Backup.

## 0. Initial Setup & Passwordless Sudo (Pre-Disaster Requirement)

For the automated Mac backup script to execute the gathering script on the server via non-interactive SSH, the `silver-worker` user needs permission to run the script via `sudo` without a password.

On your Ubuntu server, run `sudo visudo` and append the following line to the end of the file:
```text
silver-worker ALL=(ALL) NOPASSWD: /opt/scripts/gather-host-state.sh
```
> [!IMPORTANT]
> Ensure the script is placed at exactly `/opt/scripts/gather-host-state.sh` (or update the path above to match) and that it is owned by `root` and only writable by `root` (`sudo chown root:root /opt/scripts/gather-host-state.sh && sudo chmod 755 /opt/scripts/gather-host-state.sh`). This prevents malicious modification of the passwordless script.

---

## 1. Provision Fresh Server
1. Provision a new Ubuntu installation.
2. Create the `silver-worker` user (if not already the default) and ensure SSH access is established.

## 2. Transfer Backup State
1. From your Mac, securely transfer the latest host state backup tarball to the new server:
   ```bash
   scp host-state-YYYY-MM-DD.tar.gz silver-worker@<new-server-ip>:/tmp/
   ```
2. Extract the archive on the new server:
   ```bash
   ssh silver-worker@<new-server-ip>
   cd /tmp
   tar -xzf host-state-YYYY-MM-DD.tar.gz
   ```
   This will extract a `host-state-backup-XXXX` folder containing the `packages.list`, `etc/`, and `home-silver-worker/` directories.

## 3. Restore Packages
1. Update `apt`:
   ```bash
   sudo apt-get update
   ```
2. (Optional) Re-add any custom PPAs or repos from `/tmp/host-state-backup-XXXX/etc/apt-sources.list`.
3. Set the package selections:
   ```bash
   sudo dpkg --set-selections < /tmp/host-state-backup-XXXX/packages.list
   ```
4. Install the selected packages:
   ```bash
   sudo apt-get dselect-upgrade
   ```

## 4. Restore Configurations
Carefully restore the necessary `/etc` configurations. Do not indiscriminately overwrite `/etc`, but rather copy the specific configurations back into place.

```bash
# Restore UFW Rules
sudo cp -a /tmp/host-state-backup-XXXX/etc/ufw/* /etc/ufw/
sudo systemctl restart ufw

# Restore SSH configs
sudo cp -a /tmp/host-state-backup-XXXX/etc/ssh/* /etc/ssh/
sudo systemctl restart sshd

# Restore Systemd services (like Docker, n8n-worker, etc.)
sudo cp -a /tmp/host-state-backup-XXXX/etc/systemd/* /etc/systemd/
sudo systemctl daemon-reload

# Restore Docker configs if applicable
sudo cp -a /tmp/host-state-backup-XXXX/etc/docker/* /etc/docker/
sudo systemctl restart docker

# Restore Netplan (WARNING: Verify IPs before applying)
# sudo cp -a /tmp/host-state-backup-XXXX/etc/netplan/* /etc/netplan/
# sudo netplan apply
```

## 5. Restore User State
Restore the `silver-worker` dotfiles:
```bash
cp -a /tmp/host-state-backup-XXXX/home-silver-worker/.doppler ~/.doppler
cp -a /tmp/host-state-backup-XXXX/home-silver-worker/.ssh ~/.ssh
cp -a /tmp/host-state-backup-XXXX/home-silver-worker/.bashrc ~/.bashrc
cp -a /tmp/host-state-backup-XXXX/home-silver-worker/.profile ~/.profile
```
> [!NOTE]
> Ensure permissions on `~/.ssh` remain strict (`chmod 700 ~/.ssh` and `chmod 600 ~/.ssh/*`).

## 6. Verification
Reboot the server (`sudo reboot`) and verify that all services (Docker, n8n, VPN) come back online as expected and that the UFW firewall is active.
