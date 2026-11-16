# 13. Security Considerations

> **Historical proposal.** Data access was later changed from Drizzle to Prisma — see [ADR-003](../../../discussion/finally/adr/ADR-003-data-access.md).

| Area | Plan |
|---|---|
| Input validation | Zod on every body/query/param; length caps; enum checks; strip unknown keys |
| SQL injection | Parameterised queries via Drizzle only; `ILIKE` input escaped (`%`/`_`) |
| XSS | React escapes by default; never `dangerouslySetInnerHTML`; `location` URLs restricted to `http/https` and rendered with `rel="noopener noreferrer"` |
| CORS | Prod: same-origin through nginx proxy → CORS closed; dev: explicit allow-list from env |
| Headers | `helmet`; nginx adds CSP basics |
| Rate limiting | Global modest limit; stricter on `/auth/*` |
| Secrets | Env only, `.env` gitignored, `.env.example` committed, platform secret store in deploy; no secrets in CI logs |
| Body size | `express.json({ limit: '100kb' })` |
| Data exposure | Explicit response mappers (never return raw rows); error handler hides internals; password hash never serialised; PII (candidate names, feedback) is the sensitive part — logs avoid bodies |
| Dependencies | `npm audit` + Dependabot, lockfile committed, `npm ci`, pinned base image tags, non-root container user |
| Auth (bonus) | See below |

**Authentication decision:** *Defer to Day 6, implement only if mandatory + tests + deploy are green.* Minimal design: seeded user(s) in `users` (bcrypt/argon2), `POST /auth/login` → signed JWT in **httpOnly, SameSite=Lax, Secure** cookie (no localStorage tokens); `/auth/guest` issues a limited-claims token; middleware protects write routes (guest → configurable read-only or sandboxed-demo). CSRF: SameSite + custom header requirement for mutating requests. No registration, password reset or roles. If time runs out, the app is fully functional open and the README says so. Demo credentials printed in README (demo data only).
