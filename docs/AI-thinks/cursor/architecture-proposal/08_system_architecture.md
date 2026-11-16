# 8. System Architecture

> **Historical proposal.** Data access was later changed from Drizzle to Prisma — see [ADR-003](../../../discussion/finally/adr/ADR-003-data-access.md).

### 8.1 Component diagram

```mermaid
flowchart LR
  subgraph Browser
    SPA[React SPA<br/>TanStack Query · RHF · Zod]
  end
  subgraph Docker/Render
    WEB[web: nginx<br/>static + /api proxy]
    API[api: Express + TS<br/>routes → services → repos]
    DB[(PostgreSQL)]
  end
  SPA -->|HTTPS| WEB
  WEB -->|/api/*| API
  API -->|SQL via Drizzle| DB
  SHARED[[packages/shared<br/>Zod schemas · enums · types]] -.build-time.-> SPA
  SHARED -.build-time.-> API
```

### 8.2 Request lifecycle (create meeting)

```mermaid
sequenceDiagram
  participant U as User
  participant F as React Form
  participant A as Express
  participant S as MeetingService
  participant R as Repository
  participant D as Postgres
  U->>F: Submit "Book Meeting"
  F->>F: Zod validate (client)
  F->>A: POST /api/v1/meetings (JSON)
  A->>A: requestId · rate limit · Zod validate body
  A->>S: create(dto)
  S->>S: business rules (end > start, status default)
  S->>R: upsert candidate, insert meeting
  R->>D: INSERT (transaction)
  D-->>R: row
  R-->>S: entity
  S-->>A: dto
  A-->>F: 201 + Location header + body
  F->>F: invalidate ['meetings'] → refetch, toast
```

### 8.3 Deployment topology

```mermaid
flowchart TB
  GH[GitHub main] -->|Actions: test+build| REG[Container registry / Render build]
  REG --> W[web service]
  REG --> A[api service]
  A --> PG[(Managed Postgres + backups)]
  W --> A
  User((User)) --> W
```

Local: `docker compose up --build` → `web:8080`, `api:3000`, `db:5432` (volume `pgdata`).
