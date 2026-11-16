# 7. Recommended Technology Stack

> **Historical proposal.** Data access was later changed from Drizzle to Prisma — see [ADR-003](../../../discussion/finally/adr/ADR-003-data-access.md).

Respecting the allowed list (React/Vue, Express/FastAPI/Flask).

| Concern | Choice | Why | Rejected (why) |
|---|---|---|---|
| Frontend | **React 18 + Vite** | Allowed; fastest dev loop; wide familiarity | Vue (equally valid; I'm picking one stack to go deep), Next.js (SSR unnecessary, heavier deploy) |
| Language | **TypeScript** (both sides) | Shared types/schemas eliminate FE/BE drift; senior signal | JS (more runtime bugs) |
| UI | **Tailwind CSS** + a few hand-written components (optionally shadcn/ui primitives, Radix for a11y dialogs) | Small bundle, fast, consistent | MUI/Ant (heavy, look generic), custom CSS (slow) |
| Routing | **React Router** | Four simple routes | TanStack Router (more setup) |
| Server state | **TanStack Query** | Caching, loading/error states, invalidation, retries | Redux (overkill), hand-rolled fetch hooks |
| Client state | React state / URL search params | List filters live in URL → shareable | Zustand/Redux (no global client state needed) |
| Forms | **react-hook-form + Zod resolver** | Same Zod schema as backend | Formik (heavier), manual |
| Dates | **date-fns** (+ native `<input type=date/time>`) | Light | Moment (deprecated), Luxon (fine, bigger), custom pickers (scope creep) |
| Backend | **Node 20 + Express + TypeScript** | Allowed; same language as FE → shared package | FastAPI (great, but loses shared schemas), NestJS (too much structure), Fastify (nicer, but Express explicitly named) |
| Validation | **Zod** | Single source of truth | Joi/class-validator |
| DB | **PostgreSQL 16** | Real DB satisfies "DB" + container requirement; `timestamptz`, enums, constraints | SQLite (simplest; viable fallback—file volume, single-writer; weaker "database container" story), JSON file (no integrity), Mongo (schema-less not helpful) |
| Data access | **Drizzle ORM + drizzle-kit migrations** | Typed SQL, light, readable SQL migrations | Prisma (heavier engine, bigger image), raw `pg` (more boilerplate), TypeORM (decorators, quirks) |
| API docs | **OpenAPI 3 served at `/docs`** (generated from Zod via `zod-to-openapi`, or handwritten YAML) | Reviewers can try endpoints | Swagger comments scattered in code |
| Logging | pino + pino-http | Structured logs, request IDs | morgan only |
| Security middleware | helmet, cors (allow-list), express-rate-limit | Cheap, expected | — |
| Testing | **Vitest** (both), **Supertest**, **React Testing Library**, **Playwright** (1–2 smoke tests, CI only) | One runner, fast | Jest (extra config), Cypress |
| Test DB | Real Postgres via CI service container / docker compose (or Testcontainers) | Tests the real SQL | In-memory fake (hides bugs) |
| Containers | Multi-stage Dockerfiles; web = nginx serving static + reverse proxy `/api` | Same-origin → no CORS in prod | Single fat container (violates "FE, BE, DB" spirit) |
| Hosting | **Render** (Docker web services + managed Postgres) primary; Fly.io/VPS alternative | Free/cheap, Dockerfile-native, simple | Vercel (serverless API/DB split awkward), Heroku (no free tier) |
| CI/CD | **GitHub Actions** | Repo is on GitHub | — |
| Lint/format | ESLint + Prettier, `tsc --noEmit` | Baseline hygiene | — |
