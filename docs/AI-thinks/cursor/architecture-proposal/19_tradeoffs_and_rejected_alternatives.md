# 19. Trade-offs and Rejected Alternatives

- **Superset model vs strict generic meeting:** more fields/tests, but covers both rubrics.
- **Postgres vs SQLite:** SQLite is simpler and would pass, but a real DB container and proper types/constraints better match "Frontend, Backend, and Database" containerisation. Cost: one more service + healthchecks. *Fallback if time-pressed: SQLite file on volume (repo layer isolates the change).*
- **Monorepo with shared package vs separate repos:** shared Zod contract prevents drift; cost is build wiring.
- **Express vs FastAPI:** FastAPI has built-in OpenAPI, but shared TS schemas outweigh it.
- **Drizzle vs Prisma:** Drizzle lighter/closer to SQL; Prisma has better docs/GUI. Reversible.
- **Offset vs keyset pagination:** offset chosen for simplicity/page-jump; keyset needed only at large scale.
- **Pagination vs infinite scroll:** pagination (testable, linkable).
- **Hard delete + cancel status:** matches both wording sources; no audit trail for deletes (acceptable).
- **No global state library, no DI container, no CQRS, no cache, no queues, no microservices:** nothing in the requirements justifies them.
- **E2E minimal:** slow/flaky tests have poor ROI for a take-home.
- **Next.js / SSR:** no SEO or SSR need.
- **Vercel serverless:** awkward with a long-lived Express+Postgres topology.

**Reversibility**
- *Cheap to change:* UI library/styling, ORM (behind repository), hosting provider, CI details, pagination UI, logging.
- *Moderate:* auth mechanism, status enum values, API shapes (versioned path helps).
- *Expensive:* language/framework choice (TS/React/Express), data model split (candidate vs embedded), timestamp storage semantics (UTC `timestamptz`), shared-schema monorepo layout.

**Deliberately NOT implemented:** double-booking/availability engine, calendar/ICS, email, real Zoom/Meet integration, roles/permissions, candidate management UI, file uploads, real-time, i18n, soft-delete/audit log, caching, observability stack.

**Acceptable technical debt:** offset pagination; denormalised `position` on meeting; free-text candidate matching by name; no audit trail; single-instance rate limiter (in-memory); demo-grade auth; minimal e2e.

**With more time:** keyset pagination, interviewer entity + conflict detection, ICS export + email reminders, soft delete + audit log, RBAC, Testcontainers, OpenTelemetry, visual regression, blue/green deploy, proper design system.

**Interview talking points:** how I resolved the spec conflict and why; shared-schema contract; UTC handling; optimistic concurrency; why Postgres container + same-origin nginx; what I cut and in what order; how I would scale/evolve each piece.
