# Environment Variables & Secrets Reference — Local-N8n

> **Scope**: Comprehensive dictionary of environment variables, Doppler secret injection workflows, PostgreSQL user lifecycle, and credential security.

---

## 1. Complete Environment Variable Dictionary

| Variable Name | Description | Used In | Default / Example Value |
| :--- | :--- | :--- | :--- |
| `POSTGRES_USER` | Superuser username for PostgreSQL cluster | `compose.yaml`, `init-data.sh` | `n8nRootUser` / `postgres` |
| `POSTGRES_PASSWORD` | Superuser password for PostgreSQL cluster | `compose.yaml` | *(High-entropy secret)* |
| `POSTGRES_DB` | Primary database name for n8n | `compose.yaml`, `init-data.sh` | `n8n` |
| `POSTGRES_NON_ROOT_USER` | Dedicated application user created by `init-data.sh` | `compose.yaml`, `init-data.sh` | `n8nRootUser` / `n8n` |
| `POSTGRES_NON_ROOT_PASSWORD` | Password for application non-root database user | `compose.yaml`, `init-data.sh` | *(High-entropy secret)* |
| `DB_TYPE` | Database driver type configured in n8n | `compose.yaml` (x-shared) | `postgresdb` |
| `DB_POSTGRESDB_HOST` | Database host name within internal Docker network | `compose.yaml` (x-shared) | `postgres` |
| `DB_POSTGRESDB_PORT` | Database port within internal Docker network | `compose.yaml` (x-shared) | `5432` |
| `DB_POSTGRESDB_DATABASE` | Database name referenced by n8n connection | `compose.yaml` (x-shared) | `${POSTGRES_DB}` (`n8n`) |
| `DB_POSTGRESDB_USER` | Database username used by n8n connection | `compose.yaml` (x-shared) | `${POSTGRES_NON_ROOT_USER}` |
| `DB_POSTGRESDB_PASSWORD` | Database password used by n8n connection | `compose.yaml` (x-shared) | `${POSTGRES_NON_ROOT_PASSWORD}` |
| `N8N_ENCRYPTION_KEY` | 32+ character key for AES credential encryption | `compose.yaml` (x-shared) | *(32+ char high-entropy secret)* |
| `DOMAIN_NAME` | Base domain name for reverse proxy and webhook URLs | `compose.yaml`, `Caddyfile` | `local-n8n.com` |
| `SUBDOMAIN` | Subdomain for n8n web application | `compose.yaml`, `Caddyfile` | `n8n` |
| `N8N_HOST` | Host header expected by n8n web server | `compose.yaml` (x-shared) | `${SUBDOMAIN}.${DOMAIN_NAME}` |
| `N8N_PORT` | Internal HTTP listening port for n8n service | `compose.yaml` (x-shared) | `5678` |
| `N8N_PROTOCOL` | External protocol scheme for incoming traffic | `compose.yaml` (x-shared) | `https` |
| `WEBHOOK_URL` | Public webhook callback URL emitted in workflow triggers | `compose.yaml` (x-shared) | `https://${SUBDOMAIN}.${DOMAIN_NAME}/` |
| `GENERIC_TIMEZONE` | Default timezone for Cron nodes and workflow scheduling | `compose.yaml` (x-shared) | `America/Chicago` |
| `EXECUTIONS_MODE` | Runtime architecture mode (`regular` vs `queue`) | `compose.yaml` (x-shared) | `queue` |
| `QUEUE_BULL_REDIS_HOST` | Hostname of Redis instance handling Bull queue | `compose.yaml` (x-shared) | `redis` |
| `QUEUE_HEALTH_CHECK_ACTIVE` | Active health check validation on Redis Bull queue | `compose.yaml` (x-shared) | `true` |
| `EXECUTIONS_DATA_PRUNE` | Enables automatic deletion of historical execution data | `compose.yaml` (x-shared) | `true` |
| `EXECUTIONS_DATA_MAX_AGE` | Maximum age (in hours) before execution history is purged | `compose.yaml` (x-shared) | `168` (7 days) |
| `EXECUTIONS_DATA_PRUNE_MAX_COUNT` | Hard ceiling for total execution records retained | `compose.yaml` (x-shared) | `50000` |
| `NODE_ENV` | Node.js runtime environment flag | `compose.yaml` (x-shared) | `production` |
| `DATA_FOLDER` | Legacy/local host directory mounted for file exchange | `.env`, `compose.yaml` | `./caddy/n8n-docker-caddy` |
| `SSL_EMAIL` | Contact email for automated ACME / Let's Encrypt TLS | `.env` | `example@example.com` |
| `SANDBOX_API_KEY` | Secret token authenticating n8n to local code sandbox | `sandbox/` stack, Doppler | *(High-entropy secret token)* |
| `SANDBOX_API_LISTEN_ADDR` | Public HTTP listen address for sandbox API container | `sandbox/` stack | `:3200` |
| `SANDBOX_API_PORT` | Host exposed port for code sandbox service | `sandbox/` stack | `3200` |

---

## 2. Secrets Management & Injection Architecture

### Primary Method: Doppler Runtime Secret Injection (Production)
In the production Meshnet deployment, plaintext credentials are never written to disk in `.env` files. Secrets are managed centrally in Doppler and injected directly into container processes in memory at launch time.

```bash
# 1. Select the project and environment configuration
doppler setup --project silver-worker --config prd

# 2. Launch Docker Compose with in-memory secrets
doppler run -- docker compose up -d
```

**Benefits**:
- Eliminates accidental credential commits to Git.
- Centralizes credential rotation for `N8N_ENCRYPTION_KEY`, database passwords, `N8N_MCP_API_KEY`, and `SANDBOX_API_KEY`.
- Ensures consistency between `n8n` main service and all scaled `n8n-worker` instances.
- **Headless Boot Execution**: The Doppler CLI is bound to the repository directory (`/home/silver-worker/Local-N8n`) using a directory-level service token binding, allowing `local-n8n.service` to inject secrets non-interactively upon host boot without requiring manual user login.
- **MCP Client Injection**: The Antigravity MCP configuration calls `doppler run --project silver-worker --config prd -- npx -y n8n-mcp`, providing the `N8N_MCP_API_KEY` directly from the secret store without placing tokens in plain text in config files.

### Template & Schema: `.env-sample`
The [`.env-sample`](file:///Users/victor/Dev/Local-N8n/.env-sample) file acts as the formal schema reference for required secrets in Doppler. It is tracked in Git with placeholder values and descriptive comments.

### Offline & Local Development Fallback: `.env`
When working completely offline without access to Doppler CLI, developers may copy `.env-sample` to `.env`. The standard `docker compose up -d` command will automatically pick up the local file. **Note**: `.env` is strictly ignored by version control via `.gitignore`.

---

## 3. Database Credential Lifecycle

1. **Bootstrap Phase**:
   - When PostgreSQL container boots for the first time with an empty volume (`db_storage`), PostgreSQL initializes a database cluster owned by superuser `POSTGRES_USER` with `POSTGRES_PASSWORD`.
2. **Privilege Delegation (`init-data.sh`)**:
   - PostgreSQL executes `/docker-entrypoint-initdb.d/init-data.sh` as superuser.
   - The script creates application user `POSTGRES_NON_ROOT_USER`, sets its password `POSTGRES_NON_ROOT_PASSWORD`, and grants all privileges on `POSTGRES_DB` along with schema creation rights on `public`.
3. **Application Authentication**:
   - Both `n8n` and `n8n-worker` authenticate exclusively using `POSTGRES_NON_ROOT_USER` credentials, enforcing the principle of least privilege.
