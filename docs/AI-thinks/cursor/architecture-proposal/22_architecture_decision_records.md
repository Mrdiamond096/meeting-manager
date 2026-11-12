# 22. Architecture Decision Records (Proposed)

| ADR | Decision | Status | Context → Consequence |
|---|---|---|---|
| 001 | Single `meetings` resource as superset of core + wireframe fields; `dueDate` ≙ `startAt` | Proposed | Resolves spec conflict; one source of truth for time |
| 002 | Cancel (status) and Delete (hard) are distinct operations | Proposed | Preserves history; satisfies both wordings |
| 003 | TypeScript monorepo with shared Zod package | Proposed | No contract drift; slightly more build config |
| 004 | PostgreSQL (container) over SQLite/JSON | Proposed | Real DB story & constraints; extra service. Fallback SQLite |
| 005 | Drizzle ORM with SQL migrations, run at API boot | Proposed | Light, typed; migration-on-boot acceptable for single instance |
| 006 | REST under `/api/v1`, PATCH + optimistic `version`, RFC7807-style errors | Proposed | Predictable contract; 409 on conflicts |
| 007 | Page-based pagination (offset) with `meta.total` | Proposed | Simple/testable; revisit at scale |
| 008 | UTC `timestamptz` storage, local display | Proposed | Avoids timezone corruption |
| 009 | nginx serves SPA and proxies `/api` (same origin) | Proposed | No CORS/cookie issues in prod |
| 010 | TanStack Query for server state; no global store | Proposed | Less code, built-in caching/states |
| 011 | Render for hosting; GitHub Actions for CI | Proposed | Docker-native, low ops; free-tier limits documented |
| 012 | Auth as last-priority bonus: httpOnly JWT cookie, seeded user, guest mode | Proposed | Optional; safe if omitted |
| 013 | Testing pyramid: integration-heavy on API with real Postgres, minimal e2e | Proposed | Highest value per hour |
