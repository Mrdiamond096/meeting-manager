# 12. Backend Design

```
apps/api/src
├─ app.ts                # express app factory (testable, no listen)
├─ server.ts             # listen + graceful shutdown
├─ config/env.ts         # zod-parsed env, fail fast
├─ db/ (client.ts, schema.ts, migrations/, seed.ts)
├─ middleware/ (requestId, errorHandler, validate, auth*, rateLimit, notFound)
├─ modules/
│  ├─ meetings/ (routes.ts, controller.ts, service.ts, repository.ts, mapper.ts, *.test.ts)
│  ├─ candidates/
│  ├─ feedback/
│  ├─ auth/*
│  └─ health/
└─ lib/ (errors.ts: AppError subclasses, logger.ts)
```

- **Routes** declare path + `validate({ body, query, params })` with shared Zod schemas.
- **Controller**: thin; HTTP ⇄ DTO only.
- **Service**: business rules (status transitions, candidate resolve-or-create, default title, optimistic version check). No Express types.
- **Repository**: all SQL/Drizzle; transactions for create (candidate + meeting).
- **Errors**: throw `AppError(code, status, details)`; single error middleware formats output, logs 5xx with `requestId`. Async handler wrapper (Express 4) or Express 5.
- **Config**: `PORT`, `DATABASE_URL`, `CORS_ORIGINS`, `JWT_SECRET*`, `NODE_ENV`, `LOG_LEVEL`. `.env.example` committed; real secrets never.
- **Optimistic concurrency:** `UPDATE … SET version = version+1 WHERE id=$1 AND version=$2`; 0 rows → check existence → 404 vs 409.
- **Graceful shutdown** on SIGTERM (close server, drain pool).
- No DI container; plain function composition (`createMeetingService(repo)`) keeps unit tests trivial.
