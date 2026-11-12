# 16. CI/CD Strategy

`.github/workflows/ci.yml` (on PR + push):
1. Setup Node 20 + npm cache → `npm ci`
2. Lint, `tsc --noEmit`
3. Unit + integration tests (Postgres `services:` container)
4. Build web + api images (buildx, cache) — validates Dockerfiles
5. (Optional) Playwright smoke against compose

`deploy.yml` (on `main`, after CI): trigger Render deploy hook (secret `RENDER_DEPLOY_HOOK`) or rely on Render auto-deploy gated by "wait for CI". Dependabot weekly. Branch protection not necessary for a take-home, but commits via short-lived feature branches/PRs show process.

**Git hygiene:** Conventional Commits (`feat(api): …`), small logical commits per layer, one PR per day-milestone if desired.
