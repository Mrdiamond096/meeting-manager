# 15. Docker and Deployment Strategy

**Dockerfiles (multi-stage)**
- `apps/api/Dockerfile`: `node:20-alpine` build stage (`npm ci`, `tsc`) → runtime stage with prod deps only, `USER node`, `HEALTHCHECK` on `/api/v1/health`, entrypoint runs migrations then starts.
- `apps/web/Dockerfile`: build stage (Vite build) → `nginx:alpine` serving `/usr/share/nginx/html`, `nginx.conf` with SPA fallback (`try_files … /index.html`), `location /api/ { proxy_pass http://api:3000; }`, gzip + cache headers for hashed assets.
- Shared package built in each build stage (monorepo root as build context).
- `.dockerignore` for node_modules, .git, env files.

**docker-compose.yml:** services `db` (postgres:16-alpine, named volume `pgdata`, healthcheck `pg_isready`), `api` (`depends_on: db: condition: service_healthy`), `web` (depends on api). Config from `.env` (compose reads it). `docker-compose.override.yml` for dev hot-reload (optional). Seed via `npm run seed` or `SEED_DEMO=true`.

**Environment variables:** `DATABASE_URL`, `PORT`, `NODE_ENV`, `CORS_ORIGINS`, `JWT_SECRET`, `SEED_DEMO`, `POSTGRES_USER/PASSWORD/DB`.

**Hosting options**

| Option | Pros | Cons |
|---|---|---|
| **Render** (recommended) | Docker-native, managed Postgres, blueprint `render.yaml`, auto-deploy from GitHub | Free tier cold starts; free Postgres expiry — note in README |
| Fly.io | Fast, Docker-native | CLI/config learning curve, card required |
| VPS + compose + Caddy | Full control, mirrors local exactly | Manual ops/TLS/updates |
| Vercel (FE) + Render (API) | Great FE hosting | Splits topology → CORS/cookies cross-site complexity |

**Deployment risks:** cold starts (mitigate: friendly loading state, README note); free DB retention limits (seed on boot makes demo recoverable); cross-origin cookie problems (avoided via same-origin proxy); migration failure at boot (healthcheck blocks traffic; migration is idempotent and transactional); image size (alpine + multi-stage).
