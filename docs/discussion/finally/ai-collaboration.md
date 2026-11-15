# AI Collaboration Brief — แบ่งงาน Claude / Codex / Cursor

สถานะ: Draft v2 (15 พ.ย. 2026 — สลับ: Claude ทำ frontend เพราะต่อ Figma MCP ได้, Cursor ทำ Auth) · อ้างอิง: [implementation-plan.md](./implementation-plan.md) §1–2 · [final-architecture.md](./final-architecture.md) · [ADR index](./adr/README.md)

## 1. ใครทำอะไร

| AI | งาน | Repo / branch | เหตุผล |
|---|---|---|---|
| **Claude** | **Phase 1** (infra + contract freeze) → **WS-C Frontend** (C1–C4) → **Phase 3** integration + E2E | backend + frontend (Phase 1), frontend `feature/ws-c-*`, umbrella | ต่อ Figma MCP ได้ → ดึง design context/screenshot ของแต่ละ frame มา implement ตรง ๆ; เป็นคนเขียน contract เอง |
| **Codex** | **WS-A** Meetings & Candidates & Feedback (A1–A3 + `view=range`/`mine` ของ ADR-014) | backend `feature/ws-a-*` | proposal ของ Codex ได้คะแนน backend/data สูงสุด (comparison-matrix) |
| **Cursor** | **WS-B** Auth (B1–B3) | backend `feature/ws-b-*` | แยก module ชัด (`src/modules/auth`), มี checklist ADR-009/013 ครบ; ผู้ใช้รีวิวละเอียดที่สุด + Claude รีวิวก่อนส่ง |

**ลำดับ:** Codex และ Cursor เริ่มได้ทันทีโดย **แตก branch จาก `feature/phase-1-infra`** ([backend PR #1](https://github.com/Mrdiamond096/meeting-manager-backend/pull/1)) แล้ว rebase บน `main` เมื่อ R1 merge (เดิมกำหนดให้รอ R1)
ผู้ใช้รีวิวทุก PR; AI ไม่ merge เอง

## 2. กติการ่วม (ทุก AI ต้องทำตาม)

1. **อ่านก่อนเขียนโค้ด** (ตาม §3) และทำตาม pattern ที่มีอยู่ — ห้ามเพิ่ม framework/library ที่ไม่อยู่ใน ADR; ถ้าจำเป็นให้ถามใน PR description ก่อน
2. **แก้เฉพาะไฟล์ที่ตัวเองเป็นเจ้าของ** (§4) — ไฟล์ร่วมต้องแก้ใน PR แยกที่ระบุชัดว่า "shared change"
3. **Contract เป็นกฎหมาย:** `backend/docs/api-contract.md` — ถ้าเห็นว่าต้องเปลี่ยน ให้เปิด PR แก้ contract แยก ห้ามแก้แบบเงียบ ๆ ใน PR feature
4. **Git:** branch `feature/ws-<a|b|c>-<n>-<short-kebab>` จาก `main`; Conventional Commits `feat(<scope>): <summary>` (scope: `meetings`, `candidates`, `feedback`, `auth`, `web`, `infra`); ห้าม force-push `main`; ไม่ commit `.env` หรือ secret
5. **ขนาด PR:** ≤ ~400 บรรทัดที่ไม่ใช่ test/migration; 1 milestone = 1 PR
6. **Definition of done:** `npm run typecheck && npm test && npm run build` ผ่าน · test ครอบ acceptance ของ milestone · PR description มี: ทำอะไร, test อะไร, trade-off, สิ่งที่ยังไม่ทำ
7. **ภาษา:** โค้ด, commit, PR เป็นภาษาอังกฤษ; ข้อความ UI มีทั้ง EN/TH ตาม Figma
8. **Logging/Error:** ใช้ `AppError` + error middleware และ logger จาก `src/observability` เท่านั้น ห้าม `console.log`; 4xx log ระดับ `info`, 5xx `error` (ADR-012); ห้าม log password, OTP, cookie, request body
9. **Time:** เก็บ/ส่งเป็น ISO 8601 UTC instant; แสดงผลตาม timezone ของ browser (ADR-005)
10. ไม่แน่ใจ → เขียนคำถามไว้ใน PR description หัวข้อ `Open questions` แล้วทำทางเลือกที่ conservative ที่สุด

## 3. ต้องอ่านอะไร (ตามลำดับ)

**ทุกตัว**
- `docs/requirement/20251009_Software Engineer_WebApp_Interview.md` — โจทย์
- `docs/discussion/finally/final-architecture.md` — data model §4, API §5, frontend §6, acceptance §16
- `docs/discussion/finally/implementation-plan.md` — §1 หลักการ, §2 workstream ของตัวเอง
- `docs/discussion/finally/adr/README.md` + ADR ที่ระบุใน prompt ของแต่ละตัว
- `backend/docs/api-contract.md` — (หลัง Phase 1) source of truth ของ request/response/error code

**Pattern อ้างอิงในโค้ด**
| เรื่อง | ไฟล์ตัวอย่าง | Pattern |
|---|---|---|
| App composition | `backend/src/app.ts` | `createApp(deps)` รับ dependency ผ่าน argument (ทดสอบได้โดยไม่ต้องมี DB จริง) |
| Router | `backend/src/routes/health.ts` | factory function คืน `Router`; ไม่มี global state |
| Test | `backend/test/health.test.ts` | Vitest + supertest เรียก `createApp(...)` ตรง ๆ |
| DB | `backend/src/db/schema.ts`, `client.ts`, `drizzle/` | Drizzle schema → `npm run db:generate` สร้าง migration; ห้ามแก้ migration ที่ merge แล้ว |
| Import | ทั้ง backend | ESM, import ลงท้าย `.js` |
| Frontend | `frontend/src/app/*`, `frontend/next.config.ts` | App Router, server components เป็นค่าเริ่มต้น, `'use client'` เฉพาะที่จำเป็น; เรียก API ผ่าน `/api/v1/*` (same-origin rewrite, ADR-011) |
| Design | `docs/design/DESIGN_GUIDELINES.md`, `docs/design/tokens/globals.css`, `docs/design/screens/*.png`, Figma `umgd40A9k9R8M2zhtk0Coj` | ใช้ token เท่านั้น ห้าม hex ตรง; ชื่อ component ตาม shadcn/ui |

## 4. Ownership

| เจ้าของ | Backend | Frontend |
|---|---|---|
| Claude (Phase 1, ไฟล์ร่วม) | `src/app.ts`, `src/config.ts`, `src/db/client.ts`, `src/db/schema/*`, `drizzle/*`, `src/http/*`, `src/observability/*`, `test/helpers/*`, `docs/api-contract.md`, `package.json` | `middleware.ts`, `next.config.ts`, `src/app/layout.tsx`, `src/app/providers.tsx`, `src/lib/*`, `src/components/ui/*`, `package.json` |
| Cursor (WS-B) | `src/modules/auth/*`, `src/http/auth-guard.ts` (implementation), `test/auth/*` | — |
| Codex (WS-A) | `src/modules/meetings/*`, `src/modules/candidates/*`, `src/modules/feedback/*`, `test/meetings/*`, `test/candidates/*`, `test/feedback/*` | — |
| Claude (WS-C) | — | `src/app/(auth)/*`, `src/app/(app)/*`, `src/features/*`, `src/mocks/*` (MSW), tests ข้างไฟล์ |

ต้องการ dependency ใหม่หรือแก้ schema/ไฟล์ร่วม → ขอใน PR description; Claude/ผู้ใช้เป็นคนแก้ไฟล์ร่วม

## 5. Prompt สำหรับ Codex (WS-A)

```text
You are working on the backend of "Candidate Meeting Scheduler"
(repo: meeting-manager-backend, Node 24 + Express 5 + TypeScript + Drizzle + PostgreSQL 16 + Zod + Vitest/supertest).
You own workstream WS-A: Meetings, Candidates, Feedback. Two other AIs work in parallel:
Claude owns shared infra + the Next.js frontend (WS-C), Cursor owns Auth (WS-B).

READ FIRST (in the umbrella repo meeting-manager, docs live outside the submodule):
1. docs/requirement/20251009_Software Engineer_WebApp_Interview.md
2. docs/discussion/finally/final-architecture.md (sections 4 Data Model, 5 API, 16 Acceptance)
3. docs/discussion/finally/implementation-plan.md (sections 1 and 2, WS-A rows)
4. docs/discussion/finally/ai-collaboration.md (this brief: rules, ownership)
5. ADRs: 003 data access, 005 datetime, 006 candidate identity, 007 concurrency, 012 logging, 014 calendar
6. backend/docs/api-contract.md  <- source of truth, do not deviate
Then read existing code to copy its patterns: src/app.ts, src/routes/health.ts, src/http/*,
src/observability/*, src/db/schema/*, test/health.test.ts, test/helpers/*.

PATTERNS TO FOLLOW
- Module layout: src/modules/<domain>/{router.ts, service.ts, repository.ts, schemas.ts}
  router = HTTP + Zod validation via src/http/validate.ts; service = rules/transitions; repository = Drizzle only.
- Routers are factory functions taking deps; mount them only via the hook Claude left in app.ts.
- Errors: throw AppError with codes from src/http/errors.ts; never res.status(...) ad hoc for errors.
- Logging: use req.log / the shared logger; never console.log; never log bodies.
- ESM imports with .js suffix. Strict Zod (reject unknown keys).
- Tests: Vitest + supertest against createApp(); use test/helpers (DB reset, loginAs()).

MILESTONES (one branch + one PR each, from main)
- A1 feature/ws-a-1-meetings-crud: list (page, pageSize<=50, status, from, to, candidateId, mine), get, create,
  PATCH with version (409 on mismatch), DELETE ?version, POST /cancel, status transitions, created_by.
  Also GET /meetings?view=range&from&to&status&mine (range <= 42 days, <= 500 items, else 400) per ADR-014.
- A2 feature/ws-a-2-candidates: search ?q (limit 10), create, detail with upcoming + history;
  create candidate + meeting in one transaction.
- A3 feature/ws-a-3-feedback: append-only feedback; cascade on meeting delete.
Required tests: 400 validation, 404, 409 version, pagination edges (page beyond end => 200 + []),
transitions, transaction rollback, 401 when not logged in (via auth guard), range limits.

DO NOT
- Touch src/modules/auth/*, src/app.ts, src/db/schema/*, drizzle/*, package.json, src/http/*, src/observability/*.
  If you need a schema/shared change, stop and describe it in the PR under "Shared change request".
- Add dependencies. Change the API contract silently.
DONE = npm run typecheck && npm test && npm run build pass; PR <= ~400 non-test lines;
PR description: what, tests, trade-offs, open questions. Commits: feat(meetings): ..., English only.
```

## 6. Prompt สำหรับ Cursor (WS-B Auth)

```text
You are working on the backend of "Candidate Meeting Scheduler"
(repo: meeting-manager-backend, Node 24 + Express 5 + TypeScript + Drizzle + PostgreSQL 16 + Zod + Vitest/supertest).
You own workstream WS-B: Authentication. Two other AIs work in parallel:
Claude owns shared infra + the Next.js frontend (WS-C), Codex owns Meetings/Candidates/Feedback (WS-A).
This is the most security-sensitive part; it will be reviewed line by line against ADR-009 and ADR-013.

READ FIRST (umbrella repo meeting-manager):
1. docs/requirement/20251009_Software Engineer_WebApp_Interview.md
2. docs/discussion/finally/final-architecture.md (sections 4 Data Model, 5 API, 8 Security, 16 Acceptance)
3. docs/discussion/finally/implementation-plan.md (sections 1, 2 WS-B rows, 5 release checklist "Auth & security")
4. docs/discussion/finally/ai-collaboration.md (rules, ownership)
5. docs/discussion/finally/api-security-observability-proposal.md (sections on auth, rate limits, logging)
6. ADRs: 009 auth (main spec), 011 API communication, 012 logging, 013 security baseline + rate-limit table
7. backend/docs/api-contract.md  <- auth endpoints, cookie, error codes; do not deviate
Then read existing code: src/app.ts, src/config.ts, src/http/* (errors, validate, rate-limit, auth-guard interface),
src/observability/*, src/db/schema/{users,sessions,otp_challenges}.ts, test/helpers/*, test/health.test.ts.

SPEC (from ADR-009, summary — ADR wins on conflict)
- Email identifier: lowercase + trim, unique. Password 8..72 bytes, bcryptjs cost 12.
- OTP via interface OtpProvider; MockOtpProvider uses OTP_MOCK_CODE (112233 in .env.example).
  Refuse to start when NODE_ENV=production and the mock provider is configured.
- otp_challenges: purpose REGISTER/LOGIN/RESET, store code hash, 5 min TTL, single use, locked after 5 wrong attempts (log warn).
- Sessions in Postgres + cookie `sid` (httpOnly, SameSite=Lax, Path=/, Secure via env); idle 8h, absolute 7d;
  store only a hash of the session token; logout deletes the row; password reset deletes all user sessions.
- Login always requires OTP (2FA). Same error message for wrong email or password. Forgot password always returns the same message.
  Duplicate email on register => 409 (accepted trade-off).
- CSRF: SameSite=Lax + Origin check on non-GET. Rate limits per ADR-013 table (login, OTP, register, forgot 3/hour).
- requireAuth / requireRole('USER') implementation in src/http/auth-guard.ts (interface already defined by Claude).
- Never log password, OTP, cookie, token, or bodies. 4xx => info, lockout/abuse => warn.

PATTERNS TO FOLLOW
- Module layout: src/modules/auth/{router.ts, service.ts, repository.ts, schemas.ts, otp-provider.ts, password.ts, session.ts}.
- Router factory with injected deps (clock, OtpProvider) so tests control time; mount only via the hook in app.ts.
- Throw AppError with codes from src/http/errors.ts; validate with src/http/validate.ts; ESM imports with .js suffix.
- Tests: Vitest + supertest against createApp(); fake clock for TTL/idle/absolute expiry.

MILESTONES (one branch + one PR each, from main)
- B1 feature/ws-b-1-register-otp: register + OTP verify (REGISTER), OtpProvider/MockOtpProvider, bcrypt, production fail-fast.
- B2 feature/ws-b-2-login-sessions: login + OTP (LOGIN) + session cookie + logout + GET /auth/me + real requireAuth + Origin check.
- B3 feature/ws-b-3-reset-ratelimit: forgot/reset password via OTP (RESET), revoke sessions, auth rate limits.
Required tests: OTP expired / reused / 5 wrong => locked, session idle + absolute expiry, logout deletes session,
enumeration-safe responses, 429, production + mock => startup error, no secrets in logs (assert on captured log output), Origin rejected.

DO NOT
- Touch src/modules/meetings|candidates|feedback, src/app.ts, src/db/schema/*, drizzle/*, package.json,
  src/observability/*, other src/http/* files. Need a change there? Describe it in the PR under "Shared change request".
- Add dependencies beyond bcryptjs (already approved). Use JWT. Change the contract silently.
DONE = npm run typecheck && npm test && npm run build pass; PR <= ~400 non-test lines;
PR description: what, tests, ADR-013 checklist ticked, trade-offs, open questions. Commits: feat(auth): ..., English only.
```

## 7. ส่วนของ Claude (เพื่อให้ตรงกัน)

1. **Phase 1** → PR `feature/phase-1-infra` (backend: รวม `bcryptjs` ใน package.json ให้ WS-B) + `feature/phase-1-web-shell` (frontend) → **R1** ผู้ใช้รีวิว contract + schema
2. ระหว่างรอ R1: เขียน `AGENTS.md` (Codex) ใน backend และ `.cursor/rules/project.mdc` (Cursor) ใน backend โดยสรุป §2–4
3. หลัง R1: **WS-C** C1–C4 — ใช้ Figma MCP (`get_design_context` / `get_screenshot` ของ frame ใน page `03 Screens`, file `umgd40A9k9R8M2zhtk0Coj`) เป็น reference ทีละหน้า; mock API ด้วย MSW ตาม contract จน A1 + B2 merge
   - routes: `src/app/(auth)/*`, `src/app/(app)/*` · feature code: `src/features/<domain>/{api,hooks,components,schemas}` · ทุกหน้ามี loading/empty/error(requestId) · 401 → `/login?next=` · 409 dialog · EN/TH
4. รีวิวเบื้องต้น PR ของ Codex/Cursor ให้ตรง contract + ADR-013 ก่อนส่งผู้ใช้
5. Phase 3: ถอด MSW, Playwright smoke, seed, README

## 8. การส่งต่องาน / สื่อสาร

- ทุก AI ไม่เห็นแชทของกันและกัน → ข้อมูลที่ต้องรู้ร่วมกันต้องอยู่ใน **repo** (contract, ADR, PR description) เท่านั้น
- เปลี่ยน contract → PR แยก + ผู้ใช้แจ้ง AI อีกสองตัวโดยวางลิงก์ PR ในแชท
- ผู้ใช้เป็นคน merge; ลำดับ: Phase 1 → B2 (Cursor) ก่อนเปิด `requireAuth` จริงบน route ของ A (Codex) → frontend (Claude) ต่อ backend จริงหลัง A1 + B2
- Codex และ Cursor ทำงานใน repo backend เดียวกันคนละ module → ทั้งคู่ต้อง rebase บน `main` ก่อนเปิด PR; ถ้าชนกันในไฟล์ร่วม ให้หยุดและแจ้งผู้ใช้
