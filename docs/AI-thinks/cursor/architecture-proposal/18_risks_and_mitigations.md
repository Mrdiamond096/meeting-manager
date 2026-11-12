# 18. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Scope blow-up from wireframes | High | High | Superset model, feature-freeze Day 5, explicit cut order |
| Deployment surprises (cold start, DB limits, proxy) | Med | High | Early trial deploy; same-origin proxy; seed-on-boot |
| Timezone bugs | Med | Med | UTC storage, ISO in/out, shared date util, tests across zones (`TZ=` in vitest) |
| Monorepo/Docker build friction | Med | Med | Root build context, simple workspaces, test builds in CI from Day 3 |
| Reviewer perceives wireframe/core mismatch as ignored | Med | Med | Document interpretation in README ("Design decisions") |
| Over-testing/under-testing | Low | Med | Test pyramid targets above |
| Auth rushed and insecure | Med | Med | Optional, minimal, cookie-based, or omit with note |
| Free-tier availability at review time | Med | High | README includes local run + screenshots/GIF as fallback |
