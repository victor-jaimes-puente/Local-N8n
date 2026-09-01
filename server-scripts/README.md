# Local-N8n Server Management Scripts

This directory contains management and maintenance scripts for administering the Docker Compose stacks, Doppler secret injection, and `systemd` boot services on the **`silverworker`** host.

---

## Script Inventory

| Script | Purpose | Usage |
| :--- | :--- | :--- |
| [`install-systemd-services.sh`](file:///Users/victor/Dev/Local-N8n/server-scripts/install-systemd-services.sh) | Copies unit files from `systemd/` to `/etc/systemd/system/`, reloads the systemd daemon, and enables all units for host boot persistence. | `sudo ./install-systemd-services.sh` |
| [`start-all.sh`](file:///Users/victor/Dev/Local-N8n/server-scripts/start-all.sh) | Starts all services in proper dependency order (Gateway -> Core -> SearXNG -> Sandbox) with Doppler secrets. | `sudo ./start-all.sh` |
| [`stop-all.sh`](file:///Users/victor/Dev/Local-N8n/server-scripts/stop-all.sh) | Gracefully stops all services in reverse dependency order. | `sudo ./stop-all.sh` |
| [`restart-all.sh`](file:///Users/victor/Dev/Local-N8n/server-scripts/restart-all.sh) | Performs a clean stop, pause, start, and status check across the full stack. | `sudo ./restart-all.sh` |
| [`status-all.sh`](file:///Users/victor/Dev/Local-N8n/server-scripts/status-all.sh) | Displays active systemd unit statuses, Docker container states, and recent Cloudflare Tunnel logs. | `./status-all.sh` |
| [`update-cloudflare-token.sh`](file:///Users/victor/Dev/Local-N8n/server-scripts/update-cloudflare-token.sh) | Updates `CLOUDFLARE_TUNNEL_TOKEN` in Doppler (`silver-worker/prd`) and re-spins the `cloudflared` container. | `./update-cloudflare-token.sh "<TOKEN>"` |

---

## Quick Usage Workflow

```bash
cd /home/silver-worker/Local-N8n/server-scripts

# 1. Install / Enable systemd units for boot persistence:
sudo ./install-systemd-services.sh

# 2. Check full system status:
./status-all.sh

# 3. Restart everything cleanly:
sudo ./restart-all.sh
```
