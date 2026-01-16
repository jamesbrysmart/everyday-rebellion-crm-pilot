# Pilot Plan (Learning-First, Low Regret)

Purpose: run a realistic pilot for Twenty + fundraising extension while deferring VPS until the stack and runbooks are stable.

## Phases

### Phase 1 — Local production mimic (completed, optional)
- `SERVER_URL` set as if public.
- Validate storage strategy (S3-compatible) locally if needed.
- Configure pilot org, metadata, and sample data.
- Run a restore drill after meaningful data exists.

### Phase 2 — Hosted middle ground (Railway)
- Deploy full multi-service stack (Twenty, worker, db, redis, gateway, fundraising, n8n).
- Use Railway TLS termination + nginx gateway.
- Use S3-compatible storage (R2 default, AWS S3 supported).
- Validate webhooks and multi-user access.
- Keep multi-workspace disabled; document env vars + wildcard DNS requirements for Phase 3.
- Enable backups (Railway automated backups with 14-day retention).
- Execution steps: `docs/pilot/PHASE_2_EXECUTION.md`.

#### Phase 2 checklist (Railway)
- Services: `server`, `worker`, Railway Postgres, Railway Redis, `gateway`, `fundraising-service`, `n8n`.
- Storage: `STORAGE_TYPE=s3` + S3-compatible credentials (R2 default, S3 optional). Keep buckets private.
- Public URL: set `SERVER_URL` to the Railway HTTPS domain (or custom domain).
- Fundraising auth: test token propagation and UI gating before public exposure.
- n8n: use `automations.<domain>` with strong auth, persistent storage, and `N8N_ENCRYPTION_KEY`.
- Gateway: build nginx from `nginx/Dockerfile` (no file mounts).
- Backups: enable Railway daily automated backups (14-day retention). Run a monthly restore drill into a fresh env and verify login + sample records.
- Metadata provisioning: run `setup-schema.mjs` against the hosted URL.
- Smoke tests: `smoke:gifts`, manual gift → staging → process, file upload (S3-compatible validation).

### Phase 3 — VPS self-hosting (later)
- Deploy via Docker Compose or Coolify/EasyPanel.
- Enable and test multi-workspace with wildcard DNS + `{DEFAULT_SUBDOMAIN}`.
- Full ops posture: backups, upgrades, monitoring, rollback.
- Document partner-friendly self-hosting steps.

## Decisions (current)
- Storage: S3-compatible storage with R2 as default; keep buckets private.
- Integration: fundraising-service talks to Twenty via REST API only.
- Data plane: API-first is the default posture.
- Hosting: Phase 2 on Railway; Phase 3 VPS.

## Open Questions
- Which connector goes live first in n8n (Stripe vs other).
- Timeline for Phase 3 multi-workspace rollout.
- When to plan direct-to-storage uploads (presigned URLs).
