# Pilot Plan (Learning-First, Low Regret)

Purpose: run a realistic dummy pilot for Twenty + fundraising extension while deferring VPS until the stack and runbooks are stable.

## Phases

### Phase 1 — Local production mimic (short)
- Reverse proxy + HTTPS locally.
- `SERVER_URL` set as if public.
- Decide storage strategy (S3-compatible) and validate locally.
- Configure pilot org, metadata, and sample data.
- Run a restore drill after meaningful data exists.

### Phase 2 — Hosted middle ground (Railway or similar)
- Deploy full multi-service stack (Twenty, worker, db, redis, gateway, fundraising, caddy).
- Use real HTTPS + public URL.
- Use S3-compatible storage (R2/S3).
- Validate webhooks and multi-user access.
- Evaluate Twenty multi-workspace mode (`IS_MULTIWORKSPACE_ENABLED`) for multi-tenant partner hosting (requires wildcard DNS).

#### Phase 2 checklist (Railway)
- Services: `server`, `worker`, Railway Postgres, Railway Redis, `gateway`, `fundraising-service` (n8n optional).
- Storage: `STORAGE_TYPE=s3` + S3/R2 credentials (no local volumes).
- Public URL: set `SERVER_URL` to the Railway HTTPS domain (or custom domain).
- Fundraising auth: decide and implement before public exposure (proxy guard or service-level JWT verification).
- Metadata provisioning: run `setup-schema.mjs` against the hosted URL.
- Smoke tests: `smoke:gifts`, manual gift → staging → process, file upload (S3 validation).

### Phase 3 — VPS self-hosting (later)
- Deploy via Docker Compose or Coolify/EasyPanel.
- Full ops posture: backups, upgrades, monitoring, rollback.
- Document partner-friendly self-hosting steps.

## Decisions (current)
- Storage: move to S3-compatible storage (MinIO locally, S3/R2 later).
- Integration: fundraising-service talks to Twenty via REST API only.
- Hosting: VPS deferred until Phase 2 stabilizes.

## Open Questions
- Exact cloud provider choice for Phase 2 (Railway vs alternatives).
- n8n hosting strategy and webhook patterns for Phase 2.
- Final backup/restore cadence and ownership.
