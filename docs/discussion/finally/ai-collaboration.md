# AI Collaboration Brief — แบ่งงาน Claude / Codex / Cursor

สถานะ: **v3 (16 พ.ย. 2026)** — ผู้ใช้เปลี่ยนบทบาท: **Claude = frontend · Cursor = backend · Codex = review + docs** · อ้างอิง: [implementation-plan.md](./implementation-plan.md) §1–2 · [final-architecture.md](./final-architecture.md) · [ADR index](./adr/README.md)

## 1. ใครทำอะไร

| AI | บทบาท | Repo | งานที่เหลือ |
|---|---|---|---|
| **Claude** | **Frontend** ทั้งหมด (เจ้าของไฟล์ร่วมฝั่ง frontend) | `meeting-manager-frontend` `feature/ws-c-*` | C1 (PR เปิดแล้ว) → C2 Dashboard + Meeting form → C3 Candidate Summary → C4 Calendar; ฝั่ง frontend ของ Phase 3 (ถอด mock, Playwright) |
| **Cursor** | **Backend** ทั้งหมด (เจ้าของไฟล์ร่วมฝั่ง backend ด้วย) | `meeting-manager-backend` `feature/ws-b-*`, `fix/*` | B1 (PR #7) → B2 login/session/`createAuthenticate` → B3 forgot/reset; ดูแล contract, schema, `app.ts`; `make seed`; แก้ backend ตามรีวิว |
| **Codex** | **Reviewer + docs** — ไม่เขียน feature code | ทุก repo (อ่าน) · umbrella `docs/`, `README.md` ทุก repo | รีวิวทุก PR ก่อนผู้ใช้; README / setup / decisions / limitations; อัปเดต docs ให้ตรงโค้ดจริง |

ประวัติ: Phase 1 (Claude) และ WS-A A1–A3 (Codex) merge แล้ว — backend PR #1–#6

**ลำดับงาน:** B2 ต้อง merge ก่อนที่ frontend จะต่อ backend จริงครบ (ทุก route ที่ไม่ใช่ auth ตอบ 401 จนกว่าจะมี session จริง)
ผู้ใช้เป็นคน merge; AI ไม่ merge เอง · ทุก PR: เจ้าของเปิด → **Codex รีวิว** → ผู้ใช้อนุมัติ/merge

## 2. กติการ่วม (ทุก AI ต้องทำตาม)

1. **อ่านก่อนเขียนโค้ด** (ตาม §3) และทำตาม pattern ที่มีอยู่ — ห้ามเพิ่ม framework/library ที่ไม่อยู่ใน ADR; ถ้าจำเป็นให้ถามใน PR description ก่อน
2. **แก้เฉพาะไฟล์ที่ตัวเองเป็นเจ้าของ** (§4) — ไฟล์ร่วมต้องแก้ใน PR แยกที่ระบุชัดว่า "shared change"
3. **Contract เป็นกฎหมาย:** `backend/docs/api-contract.md` — ถ้าเห็นว่าต้องเปลี่ยน ให้เปิด PR แก้ contract แยก ห้ามแก้แบบเงียบ ๆ ใน PR feature
4. **Git:** branch `feature/ws-<b|c>-<n>-<short-kebab>` (หรือ `fix/<desc>`, `docs/<desc>`) จาก `main`; Conventional Commits `feat(<scope>): <summary>` (scope: `meetings`, `candidates`, `feedback`, `auth`, `web`, `infra`, `docs`); ห้าม force-push `main`; ไม่ commit `.env` หรือ secret
5. **ขนาด PR:** ≤ ~400 บรรทัดที่ไม่ใช่ test/migration; 1 milestone = 1 PR
6. **Definition of done:** `npm run typecheck && npm test && npm run build` ผ่าน · test ครอบ acceptance ของ milestone · PR description มี: ทำอะไร, test อะไร, trade-off, สิ่งที่ยังไม่ทำ
7. **ภาษา:** โค้ด, commit, PR เป็นภาษาอังกฤษ; ข้อความ UI มีทั้ง EN/TH ตาม Figma
8. **Logging/Error:** ใช้ `AppError` + error middleware และ logger จาก `src/observability` เท่านั้น ห้าม `console.log`; 4xx log ระดับ `info`, 5xx `error` (ADR-012); ห้าม log password, OTP, cookie, token, **email**, request body — อ้างถึงผู้ใช้ด้วย `userId` / `challengeId`
11. **Node 24** (`.nvmrc`) — สลับด้วย `nvm use` ก่อนเริ่ม; ใช้ DB แยกสำหรับ test เพราะ `resetDb()` truncate ทุกตาราง (อย่าชี้ไปที่ DB ของ `make up`)
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
| DB | `backend/prisma/schema.prisma`, `prisma/migrations/`, `src/db/client.ts` | Prisma schema → `npm run db:migrate` สร้าง migration (ตรวจ SQL ก่อน commit); CHECK constraint/expression index เขียนเองใน migration; ห้ามแก้ migration ที่ merge แล้ว |
| Import | ทั้ง backend | ESM, import ลงท้าย `.js` |
| Frontend | `frontend/src/app/*`, `frontend/next.config.ts` | App Router, server components เป็นค่าเริ่มต้น, `'use client'` เฉพาะที่จำเป็น; เรียก API ผ่าน `/api/v1/*` (same-origin rewrite, ADR-011) |
| Design | `docs/design/DESIGN_GUIDELINES.md`, `docs/design/tokens/globals.css`, `docs/design/screens/*.png`, Figma `umgd40A9k9R8M2zhtk0Coj` | ใช้ token เท่านั้น ห้าม hex ตรง; ชื่อ component ตาม shadcn/ui |

## 4. Ownership

| เจ้าของ | แก้ได้ |
|---|---|
| **Claude** | ทั้ง repo `meeting-manager-frontend` · umbrella `docker-compose*.yml` ส่วน `web` |
| **Cursor** | ทั้ง repo `meeting-manager-backend` (รวม `app.ts`, `config.ts`, `db/**`, `prisma/**`, `http/**`, `observability/**`, `test/helpers/**`, `docs/api-contract.md`, `package.json`) · umbrella `docker-compose*.yml` ส่วน `api`/`db` |
| **Codex** | umbrella `docs/**`, `README.md` (umbrella + ทั้งสอง submodule), `AGENTS.md`/rules ร่วมกับผู้ใช้ · **ห้าม**แก้ `src/**`, `test/**`, `prisma/**`, contract |
| ผู้ใช้ | `Makefile`, `.github/**`, ตัดสิน contract change |

- **Contract change** (`backend/docs/api-contract.md`): Cursor เปิด PR `contract: ...` แยก → Codex รีวิว → ผู้ใช้อนุมัติ → แจ้ง Claude ด้วยลิงก์ PR
- Claude ต้องการ endpoint/field ใหม่ → เขียน "Contract change request" ใน PR ของ frontend หรือแจ้งผู้ใช้ ไม่แก้ backend เอง
- Codex เจอบั๊กระหว่างรีวิว → comment ใน PR (ผ่านผู้ใช้) ไม่ push แก้เอง

## 5. Prompt สำหรับ Codex (Review + Docs)

```text
You are the reviewer and documentation owner for "Candidate Meeting Scheduler"
(umbrella repo meeting-manager with submodules meeting-manager-backend and meeting-manager-frontend).
Claude writes the frontend (Next.js 15), Cursor writes the backend (Express 5 + Prisma + PostgreSQL).
You do NOT write feature code. You review every PR before the user merges it, and you own the docs.

READ FIRST (umbrella repo):
1. docs/requirement/20251009_Software Engineer_WebApp_Interview.md
2. docs/discussion/finally/final-architecture.md, implementation-plan.md (section 5 = release checklist)
3. docs/discussion/finally/ai-collaboration.md (roles, rules, ownership)
4. docs/discussion/finally/adr/* (all; 009 auth, 011 API, 012 logging, 013 security, 014 calendar matter most)
5. backend/docs/api-contract.md (source of truth), backend/AGENTS.md
6. docs/design/DESIGN_GUIDELINES.md and docs/design/screens/*.png (frontend reviews)

REVIEW (for each PR the user gives you)
- Check out the PR branch; run `npm ci && npm run typecheck && npm test && npm run build`
  (backend tests need a separate Postgres; never point them at the `make up`/`make dev` database: tests truncate all tables).
- Check, in this order: correctness vs api-contract.md and ADRs; security (ADR-013 + "Auth & security" checklist:
  enumeration, OTP limits, session expiry, cookie flags, origin guard, no secrets/emails in logs, no dangerouslySetInnerHTML,
  nonce CSP not weakened); missing/weak tests for the milestone's acceptance; ownership (files outside the author's area);
  readability and hand-over (repo patterns, no dead code, no unrelated refactors, PR size <= ~400 non-test lines).
- Verify claims by running code or tests; do not report guesses as findings.
- Output: a short verdict (approve / request changes) + numbered findings, each with file:line, severity
  (blocker / should-fix / nit), the concrete failure scenario, and a suggested fix. Write it so the user can paste it as a PR comment.
- Never push to someone else's branch and never merge.

DOCS (own branch docs/<desc> in the umbrella or a submodule, one PR each)
- Keep README accurate: setup (make init/up/dev, DB_PORT, Node 24), env vars, demo account + mock OTP 112233,
  API summary (link the contract), architecture + decisions (link ADRs), security and operations, limitations, future work (guest role).
- Update docs when merged code changes behaviour; flag drift between code, contract and ADRs as review findings.
- English for README/code docs; Thai is fine in docs/discussion.
```

## 6. Prompt สำหรับ Cursor (Backend owner)

```text
You now own the whole backend of "Candidate Meeting Scheduler" (repo meeting-manager-backend), including the shared files
previously owned by Claude: src/app.ts, src/config.ts, src/db/**, prisma/**, src/http/**, src/observability/**,
test/helpers/**, docs/api-contract.md, package.json. Claude owns the frontend; Codex reviews every PR and owns docs.

Rules that still apply: backend/AGENTS.md patterns; the contract is the source of truth;
contract changes go in a separate PR titled "contract: ..." and must be announced (the frontend depends on it).
Schema changes: edit src/db/schema/*, run `npm run db:generate`, never edit merged migrations.

Your queue:
1. B1 (PR #7): finish per Codex/user review.
2. B2 feature/ws-b-2-login-sessions: login + OTP (LOGIN), session cookie, logout, GET /auth/me,
   implement createAuthenticate (src/modules/auth/authenticate.ts). After merge every /api/v1 route works with a real session.
   Add a test helper that logs in through the real flow alongside the existing loginAs() stub.
3. B3 feature/ws-b-3-reset-ratelimit: forgot/reset password, revoke sessions, auth rate limits.
4. `make seed`: demo user (verified, password documented in README by Codex) + candidates + meetings around today.
5. Follow-ups: log a fatal JSON line when config validation fails at startup (ADR-012).
DONE = typecheck + tests + build green; Conventional Commits in English; PR description with tests, trade-offs, open questions,
and the "Auth & security" checklist (implementation-plan.md section 5) for auth PRs.
```

## 7. ส่วนของ Claude (frontend)

1. ✅ Phase 1 (backend + web shell) · ✅ shared fixes หลังรีวิวของ Cursor · ✅ dev compose origin `:3001`
2. **C1** auth pages — frontend PR #2 (รอรีวิว; ทดสอบ end-to-end หลัง B1/B2)
3. **C2** Dashboard (list, filter, Mine/All, pagination, states) + Meeting form (candidate combobox, Onsite/Online, 409)
4. **C3** Candidate Summary (info, notes/feedback, history, Edit/Cancel/Delete)
5. **C4** Calendar (Week/Month, mobile Day agenda, popover, click-to-create)
6. Phase 3 ฝั่ง frontend: ต่อ API จริงครบ, Playwright smoke (`make up`), ตรวจ CSP
- ใช้ Figma MCP (`get_screenshot` / `get_design_context` page `03 Screens`, file `umgd40A9k9R8M2zhtk0Coj`) เป็น reference ทีละหน้า

## 8. การส่งต่องาน / สื่อสาร

- ทุก AI ไม่เห็นแชทของกันและกัน → ข้อมูลที่ต้องรู้ร่วมกันต้องอยู่ใน **repo** (contract, ADR, PR description, review comment) เท่านั้น
- Flow ของทุก PR: เจ้าของเปิด PR → ผู้ใช้ส่งลิงก์ให้ Codex รีวิว → เจ้าของแก้ → ผู้ใช้ merge
- Contract เปลี่ยน → PR แยกของ Cursor → ผู้ใช้วางลิงก์ให้ Claude
- โฟลเดอร์ `backend/` ในเครื่องถูก Cursor checkout branch ทำงานอยู่ — Claude/Codex ใช้ `git worktree` แยกเมื่อต้องรันหรือแก้ backend เพื่อไม่ทับงาน; `make dev` จะรันโค้ดตาม branch ที่ checkout อยู่ในโฟลเดอร์นั้น
