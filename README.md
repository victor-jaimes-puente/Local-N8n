# Local n8n over NordVPN Meshnet (Docker Compose)

This repository contains the deployment configuration for running a private n8n stack and Lingua application on an Ubuntu server (Dell Precision 5480), securely accessible over a NordVPN Meshnet tunnel using a Zero-Trust architecture.

---

## Architecture & Networking Overview

The infrastructure was successfully deployed with the following core configurations:

### 1. Secret Management & Container Initialization
- **Doppler Runtime Injection:** Environment variables are no longer stored in a local `.env` file on disk. Instead, secrets are securely injected directly into memory at runtime using the `doppler run -- docker compose ...` wrapper.
- **Database Initialization:** Corrupted PostgreSQL database volumes caused by early unauthenticated boot attempts were destroyed (`docker compose down -v`), allowing the database to initialize properly with the correct superuser passwords injected by Doppler.

### 2. Client DNS & Host File Overrides
- **Custom Subdomains:** Local hosts files on client machines are configured to manually map the custom subdomains (`n8n.local-n8n.com` and `lingua.local-n8n.com`) directly to the server's static Meshnet IP (`100.116.224.88`).
- **DNS Resolution Fixes:** Conflicting `127.0.0.1` loopback entries were cleared from the macOS hosts file, and the DNS cache (`mDNSResponder`) was flushed to force the browser to route traffic correctly through the VPN tunnel.

### 3. Network Security & Firewall Adjustments
- **NordVPN Firewall:** NordVPN's aggressive internal firewall was disabled (`nordvpn set firewall off`) and the daemon restarted. This prevented NordVPN's iptables from silently dropping return packets destined for Docker's internal subnet.
- **UFW Native Firewall:** Ubuntu's native UFW was re-enabled as the primary on-machine defense. Port `22` was explicitly allowed beforehand to guarantee SSH access remained active.

### 4. Zero-Trust Gateway Binding
- **Meshnet Exclusivity:** The Caddy reverse proxy (`gateway/docker-compose.yaml`) abandoned the default `0.0.0.0` binding.
- **Invisible on Local LAN:** Web ports are bound exclusively to the Meshnet adapters (e.g., `100.116.224.88:443:443`), making the server entirely invisible to other devices on the local home Wi-Fi and strictly enforcing Zero-Trust access.

---

## Deployment Guide

### Prerequisites
1. **Ubuntu Server:** Configured with Docker, Docker Compose, and UFW.
2. **NordVPN Meshnet:** Installed and connected. You must know your server's static Meshnet IP.
3. **Doppler CLI:** Installed and authenticated on the server for secret injection.

### Step 1: Start the Gateway Proxy
The Caddy reverse proxy handles all Meshnet routing securely without port conflicts. It runs on a dedicated Docker network (`gateway_net`).

```bash
# Ensure you're inside the project directory
cd /path/to/Local-N8n

# Create the shared external network
docker network create gateway_net

# Start the standalone Caddy gateway
cd gateway
docker compose up -d
```

### Step 2: Start the n8n Application Stack
The n8n stack (n8n, worker, postgres, redis) relies on Doppler for its secrets.

```bash
# Return to the main project directory
cd ..

# Ensure your Doppler project is scoped correctly
doppler setup --project local-n8n --config prd

# Boot the application stack with injected secrets
doppler run -- docker compose up -d
```

### Step 3: Client Configuration
To access the services from your client machine, you must manually point the domains to the server's Meshnet IP.

1. Open your client's hosts file (e.g., `/etc/hosts` on macOS/Linux, or `C:\Windows\System32\drivers\etc\hosts` on Windows).
2. Add the following entry, replacing `100.116.224.88` with your server's actual Meshnet IP if it changes:
   ```text
   100.116.224.88 n8n.local-n8n.com lingua.local-n8n.com
   ```
3. Flush your DNS cache (e.g., `sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder` on macOS).
4. Navigate to `https://n8n.local-n8n.com` in your browser.

### Step 4: Host Boot Persistence (Systemd Service)
To ensure the stack boots automatically upon host restart while preserving Doppler secret injection, a host-level systemd service unit manages the Compose lifecycle.

> **Why Native Docker Restart Fails**: Standard `restart: always` container policies restart containers directly via the Docker daemon on boot, completely bypassing the `doppler run --` runtime injection wrapper. Containers would launch with empty environment variables, causing PostgreSQL and n8n to crash due to missing credentials.

Create `/etc/systemd/system/local-n8n.service`:

```ini
[Unit]
Description=Local n8n Stack with Doppler Secrets
Requires=docker.service
After=docker.service network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/silver-worker/Local-N8n
User=silver-worker
Group=docker

# Clean up stale containers before starting
ExecStartPre=/usr/bin/docker compose down
# Inject secrets from Doppler directly into Docker Compose at boot
ExecStart=/usr/bin/doppler run -- /usr/bin/docker compose up -d
# Graceful shutdown on host stop/reboot
ExecStop=/usr/bin/docker compose down
TimeoutStopSec=60

[Install]
WantedBy=multi-user.target
```

Enable and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable local-n8n.service
sudo systemctl start local-n8n.service
sudo systemctl status local-n8n.service
```

*Note: Doppler authentication operates headlessly via the pre-configured directory-level token binding in `/home/silver-worker/Local-N8n`.*

---

## Troubleshooting

- **Database Authentication Errors:** If Postgres fails to authenticate, it may be due to leftover data from a previous misconfigured run. You must destroy the volume and recreate it:
  ```bash
  docker compose down -v
  doppler run -- docker compose up -d
  ```
- **Connection Refused / Timeout:** Ensure that the Caddy gateway is running and that its ports are correctly bound to your Meshnet IP in `gateway/docker-compose.yaml`.
- **Containers Cannot Reach Internet:** Ensure NordVPN's firewall is disabled (`nordvpn set firewall off`) so it does not interfere with Docker's internal networking.
- **Uninjected Containers After Reboot:** Ensure `local-n8n.service` is active (`sudo systemctl status local-n8n.service`) and that containers are not managed solely by daemon-level `restart: always` without the systemd wrapper.
