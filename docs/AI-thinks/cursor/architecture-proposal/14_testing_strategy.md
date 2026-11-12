# 14. Testing Strategy

| Level | Scope | Tools | Count (target) |
|---|---|---|---|
| Unit – backend | status transition rules, default-title logic, date-range validation, pagination math, error mapper | Vitest | ~20 |
| Integration – API | every endpoint against real Postgres: happy path, validation 4xx, 404, 409 conflict, pagination boundaries, filter combos, delete cascade | Vitest + Supertest, DB reset per test file (transaction/truncate) | ~30 |
| Unit/component – frontend | form validation, MeetingCard rendering, empty/error/loading states, pagination control | Vitest + RTL + MSW | ~12 |
| E2E | create → appears in list → edit → delete (and login if built) | Playwright against compose stack, CI only | 1–2 |
| Static | `tsc`, ESLint, Prettier check | CI | — |

Coverage goal: meaningful (service + routes ≈ 80%+), not a vanity 100%.

**Manual checklist (pre-submit):** fresh clone → `docker compose up` works; seed visible; CRUD each path; invalid forms; past dates; end < start; delete confirm; pagination at 0/1/N pages; 404 route; refresh persistence (restart containers, data survives); mobile viewport; keyboard-only flow; deployed URL smoke; cold-start behaviour.
