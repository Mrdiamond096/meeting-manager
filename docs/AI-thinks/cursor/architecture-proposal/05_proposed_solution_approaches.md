# 5. Proposed Solution Approaches

### Approach A — Minimal MVP
Single Express app (JS or TS) serving a static React build; SQLite file or JSON; generic meeting model only (title/description/dueDate/status); Docker single container; no tests beyond a few; no auth.
Misses the wireframes → looks like it ignored half the brief.

### Approach B — Balanced Production-Minded *(recommended)*
Monorepo: `apps/web` (React+TS+Vite), `apps/api` (Express+TS), `packages/shared` (Zod schemas/types/constants). PostgreSQL + Drizzle migrations. Layered API (routes → controller → service → repository). Zod validation, central error handler, OpenAPI doc, pino logging, health checks. Vitest + Supertest + RTL + one Playwright smoke. Docker Compose, GitHub Actions. Thin JWT-cookie auth as final-day bonus.

### Approach C — Extensible Architecture
Modular monolith with domain/application/infrastructure layers, ports/adapters, DI container, CQRS-lite, event bus for notifications, Redis cache, RBAC, feature flags, Playwright full e2e, IaC, observability stack.
Impressive on paper, but for a one-week CRUD assignment it signals poor judgement about scope and adds review burden.
