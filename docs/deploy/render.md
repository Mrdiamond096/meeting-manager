# Deploy: Render (free) + Neon (free PostgreSQL)

```
browser ──https──▶ meeting-manager-web (Render, Next.js) ──/api/* rewrite──▶ meeting-manager-api (Render, Express) ──▶ Neon PostgreSQL
```

The browser only talks to the web service. Next proxies `/api/*` to the API, so the session cookie stays first-party,
the same as with `docker compose`. Both services are built from the `prod` stage of their repo's Dockerfile (the
last stage, which Render builds by default).

Everything here is on free plans:

- **Render free web services** spin down after 15 minutes without traffic. The next request waits about 30–60 s while
  the service starts. Open the site a minute before a demo.
- **Neon free** suspends an idle database and resumes it on the next connection, which takes a second or two.
- Free services have no shell and no pre-deploy command. The API applies migrations itself when it starts, and you
  run the seed from your machine (step 4).

Check the current free-tier terms on render.com and neon.tech before relying on them; they change.

## 1. Neon: create the database

1. Sign up at neon.tech, then create a project. Pick a region near the Render region, for example AWS Singapore
   (`ap-southeast-1`) for Render `singapore`.
2. In **Connect**, turn **Connection pooling off** and copy the connection string. It looks like
   `postgresql://USER:PASSWORD@ep-xxx.ap-southeast-1.aws.neon.tech/neondb?sslmode=require`.
   Use this direct host, not `-pooler`, because `prisma migrate deploy` runs at startup and needs a direct
   connection.

## 2. Render: create the services from the Blueprint

1. Sign up at render.com with GitHub, and give it access to `meeting-manager`, `meeting-manager-backend` and
   `meeting-manager-frontend`.
2. **New → Blueprint**, pick the `meeting-manager` repo, and confirm. It reads `render.yaml` from the repo root and
   creates `meeting-manager-api` and `meeting-manager-web`.
3. Render asks for the values marked `sync: false`. The final URLs aren't known yet, so enter these for now:

   | Service | Variable | Value |
   |---|---|---|
   | api | `DATABASE_URL` | the Neon string from step 1 |
   | api | `ALLOWED_ORIGINS` | `https://meeting-manager-web.onrender.com` (corrected in step 3 if different) |
   | web | `API_URL` | `https://meeting-manager-api.onrender.com` (corrected in step 3 if different) |

4. Wait for both deploys. The API's health check is `/api/health/ready`; it is green only once Neon answers and the
   migrations have run.

## 3. Check the URLs

Each service's real URL is at the top of its page. Render adds a suffix when the name is taken, for example
`meeting-manager-api-x1y2.onrender.com`.

- If the API URL differs, set the web's `API_URL` to it, then run **Manual Deploy → Deploy latest commit**. This value
  is read at build time, so saving the variable alone is not enough.
- If the web URL differs, set the API's `ALLOWED_ORIGINS` to it, with no trailing slash. The API restarts on save.

Check:

```bash
curl https://<web>.onrender.com/api/health/ready    # {"status":"ok"}: web → api → Neon all work
```

## 4. Demo data (optional)

Run from a `meeting-manager-backend` checkout on your machine. It writes straight to Neon:

```bash
npm ci
DATABASE_URL='<neon string>' NODE_ENV=production ALLOW_MOCK_OTP=true ALLOW_DEMO_SEED=true npm run db:seed
```

Log in at `https://<web>.onrender.com` as `demo@example.com` / `demo-password-123` with OTP `112233`. Running it again
resets only the demo user's data. `ALLOW_DEMO_SEED` goes on this one command only, never on the Render service.

## CI/CD

`autoDeployTrigger: checksPass`: a push to `main` of the backend or frontend repo deploys that service once the
commit's GitHub Actions checks pass (tests, `npm audit`, build, Docker image). A failing CI never reaches Render. If a
new version fails the health check, Render keeps the previous one live.

## Demo settings to revisit before real use

- **OTP is the mock.** `ALLOW_MOCK_OTP=true` and every account accepts `112233`. Replace it with a real provider and
  remove both variables.
- **The register rate limit is off** for the demo (backend `auth/router.ts`).
- **All requests reach the API from the web service.** The per-IP part of rate limits sees the web service's IP, not
  each visitor's. Login stays limited per email.
- **Free Neon has no point-in-time restore beyond its short history window**, so treat the data as disposable.
