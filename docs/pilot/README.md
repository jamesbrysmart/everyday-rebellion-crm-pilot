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
