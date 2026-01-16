# Phase 2 (Railway) Execution Plan

Use this checklist to deploy the Phase 2 pilot on Railway without missing steps.

## 0) Inputs to prepare

- Domains: `crm.<domain>` (gateway) and `automations.<domain>` (n8n).
- Secrets: `APP_SECRET`, Twenty bootstrap admin email/password, `N8N_BASIC_AUTH_USER`, `N8N_BASIC_AUTH_PASSWORD`, `N8N_ENCRYPTION_KEY`.
- R2 bucket (private): bucket name, endpoint, access key ID, secret key.
- Twenty image tag: `TAG` (pin a known version).

## 1) Create the Railway project and data services

1. Create a new Railway project for the pilot.
2. Add Railway Postgres.
3. Add Railway Redis.

## 2) Create app services (match these names)

Service names should match nginx upstreams in `nginx/gateway.conf`.

1. **server**: image `twentycrm/twenty:${TAG}` (no custom command).
2. **worker**: image `twentycrm/twenty:${TAG}`, command `yarn worker:prod`.
3. **fundraising-service**: build from repo `services/fundraising-service/Dockerfile`.
4. **gateway**: build from repo `nginx/Dockerfile`.
5. **n8n**: image `n8nio/n8n:${N8N_TAG:-latest}`.

## 3) Attach domains

1. Map `crm.<domain>` to the **gateway** service.
2. Map `automations.<domain>` to the **n8n** service.

## 4) Set environment variables

### server
- `SERVER_URL=https://crm.<domain>`
- `PG_DATABASE_URL=<Railway Postgres URL>`
- `REDIS_URL=<Railway Redis URL>`
- `IS_CONFIG_VARIABLES_IN_DB_ENABLED=true`
- `DISABLE_DB_MIGRATIONS=false`
- `ADMIN_EMAIL=<admin email>`
- `ADMIN_PASSWORD=<admin password>`
- `APP_SECRET=<strong secret>`
- `STORAGE_TYPE=s3`
- `STORAGE_S3_NAME=<r2 bucket>`
- `STORAGE_S3_REGION=<aws region string, e.g. us-east-1>`
- `STORAGE_S3_ENDPOINT=<r2 endpoint>`
- `STORAGE_S3_ACCESS_KEY_ID=<r2 access key>`
- `STORAGE_S3_SECRET_ACCESS_KEY=<r2 secret key>`

### worker
- `PG_DATABASE_URL=<Railway Postgres URL>`
- `REDIS_URL=<Railway Redis URL>`
- `IS_CONFIG_VARIABLES_IN_DB_ENABLED=true`
- `DISABLE_DB_MIGRATIONS=true`
- `APP_SECRET=<same as server>`
- `TWENTY_API_BASE_URL=http://server:3000/rest`
- `TWENTY_API_KEY=<set after bootstrap>`

### fundraising-service
- `PORT=4500`
- `TWENTY_API_BASE_URL=http://server:3000/rest`
- `TWENTY_API_KEY=<set after bootstrap>`

### n8n
- `N8N_HOST=automations.<domain>`
- `N8N_PROTOCOL=https`
- `N8N_EDITOR_BASE_URL=https://automations.<domain>`
- `N8N_WEBHOOK_URL=https://automations.<domain>`
- `N8N_ENCRYPTION_KEY=<strong secret>`
- `N8N_BASIC_AUTH_ACTIVE=true`
- `N8N_BASIC_AUTH_USER=<user>`
- `N8N_BASIC_AUTH_PASSWORD=<password>`

### Notes
- Keep multi-workspace disabled in Phase 2 (do not set `IS_MULTIWORKSPACE_ENABLED`).
- Keep the R2 bucket private; uploads/downloads go through the API.

## 5) Deploy and verify health

1. Deploy all services.
2. Wait for `https://crm.<domain>/health` and `https://crm.<domain>/healthz` to return OK.
3. Log into Twenty at `https://crm.<domain>` with the bootstrap admin credentials.

## 6) Create the Twenty API key

1. In Twenty: Settings → API Keys → create a key for the workspace.
2. Set `TWENTY_API_KEY` on **worker** and **fundraising-service**.
3. Redeploy those services.

## 7) Provision metadata

Run the metadata script locally or via a Railway one-off command:

```bash
cd services/fundraising-service
TWENTY_API_KEY=... \
TWENTY_METADATA_BASE_URL=https://crm.<domain>/rest/metadata \
TWENTY_METADATA_GRAPHQL_URL=https://crm.<domain>/metadata \
node scripts/setup-schema.mjs
```

## 8) Smoke tests

```bash
cd services/fundraising-service
GATEWAY_BASE=https://crm.<domain> npm run smoke:gifts
```

Confirm a gift is created in Twenty and the staging flow works end-to-end.

## 9) Auth and UI checks

- Load `https://crm.<domain>/fundraising/` and confirm session gating.
- Create a manual gift and verify it enters staging.
- Upload a file and confirm it downloads correctly through the API.

## 10) n8n check

- Visit `https://automations.<domain>`, log in with basic auth.
- Confirm workflows persist across restarts.

## 11) Backups and restore drill

- Enable Railway daily automated Postgres backups with 14-day retention.
- Schedule a monthly restore drill into a fresh Railway project and verify login + sample records.

## 12) Record pilot state

- Store the Railway service list, domains, and env var locations in the runbooks.
- Track the first live connector you plan to ship through n8n.
