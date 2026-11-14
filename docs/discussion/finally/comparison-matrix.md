# Comparison Matrix — Cross-AI Architecture Review

ผู้ทำ: Claude (Opus 5.5) ในบทบาท Principal Engineer · วันที่: 13 พฤศจิกายน 2026 · สถานะ: **Draft รออนุมัติ — ยังไม่ implement**

## 0. ขอบเขตและข้อจำกัด

**ข้อเท็จจริงเรื่องข้อมูลนำเข้า:** prompt ระบุ 4 ข้อเสนอ (ChatGPT, Claude, Gemini, Codex) แต่ใน repo มีจริงเพียง **3 ข้อเสนอ**:

| ID | ข้อเสนอ | ไฟล์ |
|---|---|---|
| A | Claude | [`AI-thinks/claude/ARCHITECTURE_PROPOSAL.md`](../../AI-thinks/claude/ARCHITECTURE_PROPOSAL.md) |
| B | Codex | [`AI-thinks/codex/ARCHITECTURE_PROPOSAL.md`](../../AI-thinks/codex/ARCHITECTURE_PROPOSAL.md) |
| C | Cursor | [`AI-thinks/cursor/ARCHITECTURE_PROPOSAL.md`](../../AI-thinks/cursor/ARCHITECTURE_PROPOSAL.md) + 23 ไฟล์ย่อย |
| D | — | **ไม่มี** (ไม่มีไฟล์ ChatGPT หรือ Gemini) — ไม่ประเมิน ไม่สร้างหลักฐานแทน |

**อ่านแล้ว:** โจทย์, ข้อเสนอ A/B ส่วนสำคัญ (data model, API, deploy, CI, plan), ข้อเสนอ C (grep ยืนยันข้ออ้าง), สรุปรีวิว 3 ฉบับใน `discussion/summary/`, และสถานะ repo จริง (`docker-compose.yml`, `backend/`, `frontend/`, `docs/design/`)

**ข้อควรระวังเรื่อง bias:**
- ผู้ทำรีวิวนี้เป็นโมเดลเดียวกับผู้เขียนข้อเสนอ A จึงให้น้ำหนักข้อวิจารณ์ของ B ต่อ A เป็นหลัก
- C ไม่ใช่ข้อเสนออิสระ — สรุปของ Claude ตรวจพบว่าข้อความ ~84% ตรงกับ A ทุกตัวอักษร (ข้อเท็จจริงที่ grep ได้) ดังนั้นความเห็นตรงกันระหว่าง A/C **ไม่นับเป็นฉันทามติ**
- `AI_REVIEW_SUMMARY_BY_CURSOR.md` มีข้ออ้างที่ตรวจแล้ว**ไม่ตรงกับข้อเสนอ C**: "DaisyUI", "12-point manual QA", "แยก Zod ไม่ shared" — ไม่พบใน C; "SQLite 1-line swap" ไม่เป็นจริงทางเทคนิค (Drizzle แยก `pgTable`/`sqliteTable`) จึงไม่ใช้สรุปฉบับนั้นเป็นหลักฐาน
- ยังไม่มีโค้ด จึงไม่มีผลวัดจริง ทุกคะแนนประเมินจากเอกสาร

**ข้อเท็จจริงจาก repo ที่ข้อเสนอทุกฉบับไม่ได้พิจารณา** (มีผลกับการตัดสินใจ):
1. repo เป็น umbrella + **git submodules** `frontend/` และ `backend/` แยก repo — ไม่ใช่ npm-workspaces monorepo ตามที่ A/C เสนอ
2. มี `docker-compose.yml` (db/api/web, postgres:16-alpine, healthcheck) และ `Makefile` อยู่แล้ว
3. backend: Express 5.1 + TypeScript + Vitest + Supertest; `engines: node >=20`, `@types/node 20`
4. frontend: React 18 + Vite 5 แต่ยังเป็น **JavaScript** (`App.jsx`)
5. มี design system แล้ว (`docs/design/`: Tailwind v4 + shadcn/ui tokens ธีม Lagoon)

---

## 1. Step 1 — Requirement Compliance

แยก **ข้อเท็จจริงจากโจทย์** (M = mandatory, W = wireframe ไม่ได้ระบุว่า optional, O = optional/bonus) ออกจาก engineering preference

| # | Requirement (จากโจทย์) | ประเภท | A Claude | B Codex | C Cursor |
|---|---|---|---|---|---|
| R1 | Create meeting (title, description, due date, status) | M | ✅ แต่ map `dueDate` → `start_at`+`end_at` (assumption) | ✅ คงชื่อ `dueDate` ตรงโจทย์ | ✅ เหมือน A |
| R2 | List + pagination/infinite scroll | M | ✅ | ✅ + กติกา pageSize cap, หน้าเกิน | ✅ |
| R3 | Edit ทั้ง 4 field | M | ✅ PATCH + version | ✅ PATCH + version | ✅ |
| R4 | Delete | M | ✅ แต่ไม่ระบุ version บน DELETE/cancel | ✅ `DELETE ?version=` | ✅ เหมือน A |
| R5 | Persist | M | ✅ Postgres | ✅ Postgres | ✅ Postgres |
| R6 | React หรือ Vue | M | ✅ React | ✅ React | ✅ React |
| R7 | Node/Express หรือ Python | M | ✅ Express | ✅ Express | ✅ Express |
| R8 | REST CRUD | M | ✅ `/api/v1` | ✅ `/api` | ✅ |
| R9 | README setup | M | ✅ | ✅ | ✅ |
| R10 | Containerize FE + BE + **DB** | M | ⚠️ local ได้; production ใช้ managed Postgres ของ Render → DB ที่ deploy ไม่ใช่ container | ✅ Compose ทั้ง 3 service ทั้ง local และ deploy | ⚠️ เหมือน A |
| R11 | Deploy | M | ⚠️ Render free: cold start + Postgres หมดอายุ; Node 20 EOL แล้ว (อ้างตามรีวิว Codex) | ⚠️ VPS ยังไม่มี host/DNS — prerequisite ที่ยังไม่ได้จัดหา | ⚠️ เหมือน A |
| R12 | Public GitHub + commit history | M | ✅ Conventional Commits | ✅ | ✅ |
| W1 | Dashboard card (candidate–role, date·time range, status, View Details) | W | ✅ | ❌ ไม่อยู่ baseline (extension +10–16 ชม.) | ✅ |
| W2 | Booking form (candidate, position, date, start–end, type, notes) | W | ✅ | ❌ baseline / ✅ extension | ✅ |
| W3 | Candidate Summary (info, notes, history, Edit/Cancel/Add Feedback) | W | ✅ แต่ match candidate ด้วยชื่อ → เสี่ยงรวมคนผิด | ❌ baseline / ✅ extension ด้วย candidateId | ✅ แต่ identity เหมือน A |
| O1 | Login/logout (+guest) | O | ✅ วัน 6 ถ้าทัน | ❌ ไม่ทำ (8–14 ชม.) | ✅ แต่ guest policy ขัดกันเอง (13: "configurable read-only or sandboxed" vs 20: "Guest can do everything") |
| O2 | UI design file | O | ✅ low-fi Day 1 | ➖ | ✅ |
| O3 | Tests | O | ✅ ~60–70 tests (เกินจริง) | ✅ risk-based + 1 smoke | ✅ |
| O4 | CI/CD | O | ✅ CI + deploy hook | ✅ CI; deploy manual ก่อน | ✅ |

**Omissions / violations / unsupported assumptions**

| ข้อเสนอ | ประเด็น | ระดับ |
|---|---|---|
| A, C | Candidate match ด้วยชื่อ case-insensitive → รวม history/feedback คนละคน | **High (correctness)** |
| A, C | Production DB เป็น managed service ไม่ใช่ container → ตีความ R10 แบบหลวม (ไม่ได้แจ้งว่าเป็น trade-off กับ R10) | Medium |
| A, C | Node 20 (EOL 30 เม.ย. 2026) ใน Dockerfile/CI | Medium |
| A, C | `COMPLETED` "จำเป็น", `feedback.rating` — โจทย์ไม่ได้สั่ง | Low (scope creep) |
| A, C | แผน 7 วันประมาณเป็นวัน ไม่ใช่ชั่วโมง; Day 7 ไม่ใช่ buffer จริง | Medium (feasibility) |
| A, C | เสนอ npm-workspaces + `packages/shared` — **ขัดกับ repo จริงที่แยก submodule** | Medium (ทุกฉบับไม่เห็นข้อนี้) |
| B | ตัด wireframe W1–W3 ออกจาก baseline ทั้งที่โจทย์ไม่ได้เขียนว่า optional | **High (compliance risk)** |
| B | ออกแบบเกินขนาดบางจุด: one-shot migrate job, DST ซ้ำ/ไม่มีอยู่แบบเต็ม, credential แยก migration/runtime | Low |
| B | VPS/DNS/TLS เป็น prerequisite ที่ไม่มีเวลาประมาณ ops จริง | Medium |
| C | เป็นสำเนา A + contract ต่างไฟล์ไม่ตรงกัน (guest) | Medium |

---

## 2. Step 2 — Architecture Comparison

| มิติ | A Claude | B Codex | C Cursor | หมายเหตุ |
|---|---|---|---|---|
| System architecture | Modular monolith, nginx same-origin | Modular monolith, Caddy/proxy same-origin | = A | ทุกฉบับตรงกัน — แต่ C ไม่อิสระ |
| Stack | React/TS/Vite, Express/TS, PG16 + Drizzle, shared Zod | React/TS/Vite, Express/TS, PG + `pg` + node-pg-migrate | = A | |
| Database design | candidates / meetings / feedback / users; status 4 ค่า; type+location | meetings เดียว; status 3 ค่า; candidate เป็น extension ใช้ ID | = A | B ไม่มี rating/COMPLETED |
| API design | `/api/v1`, cancel endpoint แยก, candidates autocomplete | `/api`, error code ละเอียด (413/415/422/409), unknown keys reject | = A | B นิยาม failure semantics ชัดกว่า |
| Frontend | Dashboard/Form/Summary, TanStack Query, Tailwind+shadcn | List/New/Detail/Edit, native controls | = A | A ตรงกับ `docs/design/` ที่มีอยู่ |
| Backend org | routes→controller→service→repository | routes→service→repository + SQL ชัดเจน | = A | |
| Security | helmet, CORS, rate limit, zod, JWT cookie (bonus) | strict validation, no HTML render, private data ต้อง auth | = A | |
| Testing | Vitest+Supertest+RTL+Playwright ~60+ | Vitest+Supertest real DB + 1 Playwright smoke + release checklist | = A | B สมเหตุสมผลกว่าเรื่องปริมาณ |
| Docker | multi-stage, migrate-on-boot | multi-stage, one-shot migrate service | = A | instance เดียว migrate-on-boot พอ |
| Deployment | Render + managed PG | VPS + Compose | = A | **ยังไม่ปิด** (ดู Open Q) |
| CI/CD | CI + Render deploy hook | CI ก่อน, release workflow ถ้ามีเวลา | = A | |
| Effort | ประเมินเป็นวัน, แน่นเกิน | 34 ชม. + 6 ชม. contingency; candidate +10–16, auth +8–14 | = A | B โปร่งใสกว่า |

---

## 3. Step 3 — Scoring (1–5)

น้ำหนัก: Compliance 25% · Correctness 20% · Maintainability 15% · Feasibility 15% · Testing & Deploy 15% · UX 10%

| เกณฑ์ (น้ำหนัก) | A Claude | B Codex | C Cursor |
|---|---|---|---|
| Requirement compliance (25%) | **4** | **3** | **4** |
| Correctness & reliability (20%) | **3** | **5** | **2** |
| Maintainability (15%) | **4** | **4** | **3** |
| Feasibility in 1 week (15%) | **2** | **4** | **2** |
| Testing & deployment (15%) | **3** | **4** | **3** |
| User experience (10%) | **5** | **2** | **4** |
| **Weighted total** | **3.45** | **3.80** | **3.00** |

การคำนวณ: A = 1.00+0.60+0.60+0.30+0.45+0.50 · B = 0.75+1.00+0.60+0.60+0.60+0.20 · C = 1.00+0.40+0.45+0.30+0.45+0.40

**เหตุผลประกอบคะแนน (อ้างหลักฐานจากข้อเสนอ)**

- **Compliance** — A/C ครอบคลุม M + W ทั้งหมด (A §3, §11) หัก 1 เพราะ R10 production DB ไม่เป็น container (A §15 "Render (recommended) … managed Postgres") B ครบทุก M และ R10 เคร่งที่สุด (B §15 "including the database container") แต่ W1–W3 ไม่อยู่ใน baseline (B §4 "Two reviewable delivery profiles") ซึ่งเป็นความเสี่ยงใหญ่ที่สุดต่อการประเมิน → 3
- **Correctness** — A §9 "[ASM] free-text name is matched case-insensitively" = bug ระดับข้อมูล; DELETE/cancel ไม่ใช้ version (A §10) → 3. B §9–10 กำหนด RFC 3339 + offset, reject unknown keys, `DELETE ?version`, transaction สำหรับ candidate+meeting, stable candidateId → 5. C สืบทอดปัญหาของ A + guest policy ขัดกันเอง (C 13 vs 20) → 2
- **Maintainability** — A/B layering ชัดทั้งคู่ A มี shared Zod contract (แต่ใช้ไม่ได้ตรง ๆ กับ submodule) B ใช้ raw SQL ซึ่งอ่านง่ายแต่ mapping มือมากขึ้นเมื่อมี 3 ตาราง → ทั้งคู่ 4. C เนื้อหากระจาย 23 ไฟล์และไม่สอดคล้องกันระหว่างไฟล์ → 3
- **Feasibility** — A §17 "5–6 focused hours/day" แต่ใส่ candidate+feedback+auth+design+Playwright+~60 tests; Day 7 ยังมี README/ADR/fresh-clone → 2. B §17 แจกแจง 34+6 ชม. และประกาศว่า candidate/auth ไม่พอดี budget → 4 (หัก 1 เพราะ VPS ops ไม่ได้ประมาณ). C = A → 2
- **Testing & deploy** — B มี release checklist, real-DB integration, smoke 1 flow, backup ≠ volume (B §14–15) → 4 (VPS ยังไม่ provision). A มี test plan ดีแต่ปริมาณเกินจริง และ deploy target ขัดกับ R10/EOL runtime → 3. C = A → 3
- **UX** — A มีทุกหน้า wireframe, empty/loading/error, a11y pass, ตรงกับ design system ที่มีอยู่ → 5. B native controls, ไม่มี candidate journey → 2. C = A แต่ไม่ได้เพิ่มอะไรที่ตรวจยืนยันได้ → 4

> คะแนนรวม B สูงสุด **ไม่ได้แปลว่าควรเลือก B ทั้งชุด** — B แพ้ชัดเจนในเกณฑ์ที่มีความเสี่ยงสูงสุดต่อการประเมิน (wireframe compliance) ข้อสรุปคือ **ใช้ engineering discipline ของ B บน product scope ของ A** (ดู `final-architecture.md`)

---

## 4. Step 4 — Decision Matrix (Disagreements)

คอลัมน์ D ไม่มีข้อเสนอ จึงใส่ "—"

| Topic | A Claude | B Codex | C Cursor | D | Main disagreement | Trade-offs | Recommended decision | Confidence |
|---|---|---|---|---|---|---|---|---|
| Product scope | Superset ตาม wireframe | Generic CRUD; candidate = extension | = A | — | wireframe เป็น acceptance หรือไม่ | ทำครบ = เสี่ยงเวลา; ตัด = เสี่ยงไม่ตรงความคาดหวัง | **Core CRUD ก่อน (gate) แล้ว candidate journey แบบบาง** — ไม่มี rating/COMPLETED | Medium |
| Due date semantics | `start_at` + `end_at` | `dueDate` instant; `endAt` ใน extension | = A | — | ใช้ชื่อโจทย์หรือชื่อโดเมน | ชื่อโจทย์ = ผู้ตรวจ map ง่าย | **API ใช้ `dueDate` (= เวลาเริ่ม) + `endAt` optional** | Medium |
| Candidate identity | match ชื่อ | `candidateId` + explicit create | = A | — | ความถูกต้องของ history | ID ต้องมี UI เลือก/สร้าง | **`candidateId` เสมอ; สร้างใหม่แบบ explicit; ชื่อซ้ำได้** | **High** |
| Status set | PENDING/CONFIRMED/CANCELLED/COMPLETED | 3 ค่าแรก | = A | — | COMPLETED จำเป็นไหม | History ต้องการ "ผ่านมาแล้ว" | **3 ค่า; "History" = meeting ที่ `dueDate` ผ่านแล้ว** | Medium |
| Data access | Drizzle + drizzle-kit | `pg` + node-pg-migrate | = A | — | ORM vs raw SQL | Drizzle: type-safe schema 3 ตาราง; pg: โปร่งใส ไม่มี abstraction | **Drizzle** (typed schema + generated SQL migrations ที่ commit) | Medium |
| Contract sharing | `packages/shared` Zod (workspaces) | shared contracts | ไม่ชัด | — | **ทุกฉบับขัดกับ submodule layout จริง** | shared pkg ข้าม repo = publish/link ซับซ้อน | **Backend Zod = source of truth; frontend เขียน type/schema ของตัวเอง + smoke test จับ drift** | Medium |
| Concurrency | version บน PATCH | version บน PATCH + DELETE | = A | — | ขอบเขต optimistic lock | ใส่ทุก write = ปลอดภัย, เพิ่ม test เล็กน้อย | **version บน PATCH, DELETE, cancel → 409** | High |
| Migration run | on boot | one-shot migrate job | on boot | — | ความเรียบง่าย vs multi-replica safety | replica เดียว | **migrate-on-boot** (revisit ถ้า >1 replica) | High |
| Deploy target | Render + managed PG | VPS + Compose | = A | — | R10 + ค่าใช้จ่าย/ops | Render: ง่ายแต่ DB ไม่ใช่ container; VPS: ตรง R10 แต่ต้องทำ TLS/DNS | **Compose บน VM (primary), Fly.io (fallback); DB เป็น container (ผู้ใช้ยืนยัน Q2)** | Medium |
| Runtime | Node 20 | pinned supported LTS | Node 20 | — | EOL | — | **Node 24 LTS** pin ทั้ง local/CI/image | High |
| Frontend language | TS | TS | TS | — | repo ปัจจุบันเป็น JS | แปลงตอนนี้ถูกที่สุด | **แปลง frontend เป็น TS ใน Day 1** | High |
| Styling | Tailwind + shadcn (optional) | hand-written CSS | Tailwind | — | | design tokens มีแล้วสำหรับ Tailwind v4 + shadcn | **Tailwind v4 + shadcn/ui ตาม `docs/design/`** | High |
| Auth | Bonus Day 6 + guest | ไม่ทำ | Bonus + guest ขัดกัน | — | มีไหม, guest ทำอะไรได้ | 8–14 ชม. (B) | **ไม่อยู่ใน baseline; ถ้าทำ = login + guest แบบ full access บนข้อมูล demo** | Medium |
| Test volume | ~60–70 | risk-based + 1 smoke | = A | — | ปริมาณ vs ความคุ้ม | | **risk-based (B) + component test เฉพาะ form** | High |
| SQLite fallback | ประโยค fallback | ไม่มี | (สรุป Cursor อ้าง 1-line swap) | — | ทำได้จริงไหม | ต้อง schema/migration แยก | **ปฏิเสธ** เป็น config flag; เป็นแผน B ระดับโครงการถ้า spike Day 1 ล้ม | High |
