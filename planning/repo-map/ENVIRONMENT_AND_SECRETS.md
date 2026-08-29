# Environment Variables & Secrets Reference — Local-N8n

> **Scope**: Detailed reference of all environment variables, security patterns, database credential workflows, and secret injection models.

---

## 1. Environment Variable Dictionary

| Variable Name | Description | Used In | Example / Default |
| :--- | :--- | :--- | :--- |
| `POSTGRES_USER` | Superuser username for PostgreSQL initialization | `compose.yaml`, `init-data.sh` | `postgres` |
| `POSTGRES_PASSWORD` | Superuser password for PostgreSQL | `compose.yaml` | *(Secret string)* |
| `POSTGRES_DB` | Primary database name for n8n | `compose.yaml`, `init-data.sh` | `n8n` |
| `POSTGRES_NON_ROOT_USER` | Application non-root database user | `compose.yaml`, `init-data.sh` | `n8n` |
| `POSTGRES_NON_ROOT_PASSWORD` | Application non-root database password | `compose.yaml`, `init-data.sh` | *(Secret string)* |
| `N8N_ENCRYPTION_KEY` | Key used by n8n to encrypt credentials stored in DB | `compose.yaml` | *(32+ char secret)* |
| `DOMAIN_NAME` | Base domain name for reverse proxy | `compose.yaml`, `Caddyfile` | `local-n8n.com` / `local.test` |
| `SUBDOMAIN` | Subdomain for n8n instance | `compose.yaml`, `Caddyfile` | `n8n` |
| `GENERIC_TIMEZONE` | Timezone configured for n8n workflows | `compose.yaml` | `America/Chicago` |
| `DATA_FOLDER` | Host path for mounted local files accessible by n8n | `compose.yaml` | `/home/user/n8n-data` |
| `EXECUTIONS_MODE` | Execution mode for n8n (`queue` for Redis worker model) | `compose.yaml` | `queue` |
| `QUEUE_BULL_REDIS_HOST` | Hostname of Redis service for queue | `compose.yaml` | `redis` |
| `QUEUE_HEALTH_CHECK_ACTIVE` | Enable active health check for Redis queue | `compose.yaml` | `true` |
| `NODE_ENV` | Environment mode for n8n process | `compose.yaml` | `production` |
| `WEBHOOK_URL` | Base public URL for n8n webhooks | `compose.yaml` | `https://${SUBDOMAIN}.${DOMAIN_NAME}/` |

---

## 2. Secrets Management & File Best Practices

1. **Local `.env` Handling**:
   - `.env` contains active credentials and MUST be ignored by version control (listed in `.gitignore`).
   - `.env-sample` serves as the sanitized template file committed to Git.
   - Initial setup copies `.env-sample` -> `.env` (or `.env.local`).

2. **Database Credential Flow**:
   - During first container launch, `postgres` superuser (`POSTGRES_USER` / `POSTGRES_PASSWORD`) creates the database `POSTGRES_DB`.
   - `init-data.sh` executes as superuser to create `POSTGRES_NON_ROOT_USER` with `POSTGRES_NON_ROOT_PASSWORD` and grant schema privileges.
   - `n8n` and `n8n-worker` authenticate exclusively using `POSTGRES_NON_ROOT_USER`.

3. **Roadmap Enhancement: Doppler Secret Injection**:
   - As outlined in [`planning/roadmmap-1.md`](file:///Users/victor/Dev/Local-N8n/planning/roadmmap-1.md#L10), the recommended production pattern is eliminating disk `.env` files in favor of runtime injection:
     ```bash
     doppler run -- docker compose up -d
     ```
