# Local-N8n Server Management Scripts

This directory contains management, maintenance, and Docker Compose helper scripts with automated **Doppler secret injection** for the **`silverworker`** host.

---

## Script Inventory

| Script | Purpose | Usage |
| :--- | :--- | :--- |
| [`dc.sh`](file:///Users/victor/Dev/Local-N8n/server-scripts/dc.sh) | **Universal Doppler Compose CLI**: Runs any `docker compose` command (`ps`, `logs`, `config`, `restart`, `up`, `down`, `exec`) with automatic Doppler secret injection for any stack (`core`, `gateway`, `searxng`, `sandbox`, or `all`). | `./dc.sh [stack] <command> [args...]` |
| [`logs.sh`](file:///Users/victor/Dev/Local-N8n/server-scripts/logs.sh) | **Fast Logs Viewer**: Quick shortcut to tail or stream logs for any container across all stacks. | `./logs.sh [service|stack] [-f]` |
| [`status-all.sh`](file:///Users/victor/Dev/Local-N8n/server-scripts/status-all.sh) | Displays active systemd unit statuses, Docker container states, and recent Cloudflare Tunnel logs. | `./status-all.sh` |
| [`start-all.sh`](file:///Users/victor/Dev/Local-N8n/server-scripts/start-all.sh) | Starts all services in proper dependency order (Gateway -> Core -> SearXNG -> Sandbox) with Doppler secrets. | `sudo ./start-all.sh` |
| [`stop-all.sh`](file:///Users/victor/Dev/Local-N8n/server-scripts/stop-all.sh) | Gracefully stops all services in reverse dependency order. | `sudo ./stop-all.sh` |
| [`restart-all.sh`](file:///Users/victor/Dev/Local-N8n/server-scripts/restart-all.sh) | Performs a clean stop, pause, start, and status check across the full stack. | `sudo ./restart-all.sh` |
| [`install-systemd-services.sh`](file:///Users/victor/Dev/Local-N8n/server-scripts/install-systemd-services.sh) | Copies unit files from `systemd/` to `/etc/systemd/system/`, reloads systemd, and enables all units for host boot persistence. | `sudo ./install-systemd-services.sh` |
| [`update-cloudflare-token.sh`](file:///Users/victor/Dev/Local-N8n/server-scripts/update-cloudflare-token.sh) | Updates `CLOUDFLARE_TUNNEL_TOKEN` in Doppler (`silver-worker/prd`) and re-spins the `cloudflared` container. | `./update-cloudflare-token.sh "<TOKEN>"` |

---

## Doppler Compose CLI (`dc.sh`) Cheat Sheet

The `dc.sh` script automatically wraps commands with `doppler run --` in the appropriate directory:

### Core Stack (n8n, Postgres, Redis, Worker)
```bash
./dc.sh ps                      # List core containers
./dc.sh logs -f n8n             # Follow n8n logs
./dc.sh logs -f n8n-worker      # Follow worker logs
./dc.sh restart n8n-worker      # Restart a single service
./dc.sh config                  # Validate rendered compose YAML with injected secrets
```

### Gateway Stack (Caddy & Cloudflare Tunnel)
```bash
./dc.sh gateway ps
./dc.sh gateway logs -f cloudflared
./dc.sh gateway logs -f caddy
./dc.sh gateway up -d
```

### SearXNG Stack
```bash
./dc.sh searxng logs -f
./dc.sh searxng restart
```

### Code Sandbox Stack
```bash
./dc.sh sandbox ps
./dc.sh sandbox logs -f api
./dc.sh sandbox logs -f runner
```

### All Stacks
```bash
./dc.sh all ps                  # Summary of all containers across all 4 stacks
./dc.sh all pull                # Pull latest images across all stacks
```

---

## Log Viewer (`logs.sh`) Examples

```bash
./logs.sh cloudflared -f        # Stream Cloudflare Tunnel logs
./logs.sh n8n -f                # Stream n8n core logs
./logs.sh worker -f             # Stream n8n worker logs
./logs.sh caddy -f              # Stream Caddy reverse proxy logs
./logs.sh searxng -f            # Stream SearXNG logs
./logs.sh sandbox -f            # Stream Sandbox logs
```
