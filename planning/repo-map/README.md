# Repository Map for AI Agents — Local-N8n

> **Target Audience**: Autonomous Coding & Operations AI Agents
> **Repository Path**: `/Users/victor/Dev/Local-N8n`
> **Primary Stack**: Docker Compose, n8n (Queue Mode), PostgreSQL 16, Redis 6, Caddy (Reverse Proxy), WSL 2 / Ubuntu.

---

## 1. Executive Summary & Purpose

`Local-N8n` is a production-grade, containerized local automation stack running **n8n** in **Queue Mode** with PostgreSQL and Redis backends, behind a **Caddy** reverse proxy. It is designed to run inside WSL 2 (Ubuntu) on Windows 11, integrated with Docker Desktop, and prepared for multi-tenant Meshnet deployment alongside external services like **Lingua**.

Key Features:
- **Scalable Queue Mode**: Separates UI/API (`n8n`) from background workflow execution (`n8n-worker`) using Redis Bull Queue.
- **Dedicated Central Gateway**: External Docker network (`gateway_net`) for clean multi-tenant reverse proxying (Caddy) without port conflicts.
- **Isolated Database Infrastructure**: PostgreSQL 16 initialization script (`init-data.sh`) creating dedicated non-root application users.
- **Meshnet Infrastructure Plan**: Roadmap (`planning/roadmmap-1.md`) for private deployment over Tailscale/Meshnet and CI/CD via GitHub Actions.

---

## 2. Directory & Component Structure

```
Local-N8n/
├── compose.yaml                             # Main n8n stack (Postgres, Redis, n8n, n8n-worker)
├── init-data.sh                             # Postgres non-root DB & user setup script
├── .env / .env-sample                       # Stack environment variables & secrets configuration
├── gateway/                                 # Central reverse proxy stack
│   ├── docker-compose.yaml                  # Standalone Caddy service bound to gateway_net
│   └── Caddyfile                            # Subdomain routing (n8n.local-n8n.com, lingua...)
├── caddy/                                   # Legacy / standalone Caddy configs
│   └── n8n-docker-caddy/
│       └── caddy_config/
│           └── Caddyfile                    # Alternate Caddy configuration (n8n.local.test)
├── planning/                                # Planning & architecture documentation
│   ├── roadmmap-1.md                        # 4-Phase Meshnet Infrastructure Roadmap
│   └── repo-map/                            # Agent Repository Map (This directory)
│       ├── README.md                        # Main navigation & summary index
│       ├── ARCHITECTURE.md                  # Network topology, services & scaling specs
│       ├── FILE_MANIFEST.md                 # Detailed file inventory & line-by-line purpose
│       ├── ENVIRONMENT_AND_SECRETS.md       # Env variables, Doppler integration, credentials
│       └── OPERATIONS_AND_DEPLOYMENT.md     # Commands, lifecycle, WSL2 guide & roadmap summary
├── README.md                                # Developer onboarding & quickstart instructions
├── DOCKER-WSL.md                            # WSL2 & Docker Desktop configuration guide
└── WSL.md                                   # Comprehensive Ubuntu WSL2 setup & tuning guide
```

---

## 3. Quick Reference for Agents

| Task / Domain | Key Files to Read / Edit |
| :--- | :--- |
| **Main n8n Stack** | [`compose.yaml`](file:///Users/victor/Dev/Local-N8n/compose.yaml), [`.env`](file:///Users/victor/Dev/Local-N8n/.env) |
| **Database Setup** | [`init-data.sh`](file:///Users/victor/Dev/Local-N8n/init-data.sh), [`compose.yaml`](file:///Users/victor/Dev/Local-N8n/compose.yaml#L40-L57) |
| **Reverse Proxy / Routing** | [`gateway/Caddyfile`](file:///Users/victor/Dev/Local-N8n/gateway/Caddyfile), [`gateway/docker-compose.yaml`](file:///Users/victor/Dev/Local-N8n/gateway/docker-compose.yaml) |
| **Environment / Variables** | [`.env-sample`](file:///Users/victor/Dev/Local-N8n/.env-sample), [`ENVIRONMENT_AND_SECRETS.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/ENVIRONMENT_AND_SECRETS.md) |
| **Deployment / Roadmap** | [`planning/roadmmap-1.md`](file:///Users/victor/Dev/Local-N8n/planning/roadmmap-1.md), [`OPERATIONS_AND_DEPLOYMENT.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/OPERATIONS_AND_DEPLOYMENT.md) |
| **WSL 2 & System Tuning** | [`WSL.md`](file:///Users/victor/Dev/Local-N8n/WSL.md), [`DOCKER-WSL.md`](file:///Users/victor/Dev/Local-N8n/DOCKER-WSL.md) |

---

## 4. Map Navigation

- For **Topology & Architecture**: See [`ARCHITECTURE.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/ARCHITECTURE.md).
- For **File Inventory & Purpose**: See [`FILE_MANIFEST.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/FILE_MANIFEST.md).
- For **Environment Variables**: See [`ENVIRONMENT_AND_SECRETS.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/ENVIRONMENT_AND_SECRETS.md).
- For **Operational Workflows**: See [`OPERATIONS_AND_DEPLOYMENT.md`](file:///Users/victor/Dev/Local-N8n/planning/repo-map/OPERATIONS_AND_DEPLOYMENT.md).
