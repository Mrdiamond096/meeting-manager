# Architecture Reviews — Summary by Claude

ผู้สรุป: Claude · วันที่: 12 พฤศจิกายน 2026 · สถานะ: สรุปเพื่อใช้ตัดสินใจ ยังไม่เริ่ม implement

## 1. ขอบเขตการอ่าน (ข้อจำกัดของสรุปนี้)

**อ่านครบ:** proposal ทั้งสามฉบับ (Claude 615 บรรทัด, Codex 725 บรรทัด, Cursor index + 23 ไฟล์), `claude_review_by_codex`, `cursor_review_by_codex`, `claude_review_by_cursor`, `codex_review_by_cursor`, `comparative_summary_by_cursor` (อ่านตอนที่ยังอยู่ในโฟลเดอร์), `AI_REVIEW_SUMMARY_BY_CODEX` และรีวิวสองฉบับที่ผมเขียนเอง (`codex_review_by_claude`, `cursor_review_by_claude`)
**ยังไม่ได้อ่าน:** `codex_review_by_codex`, `cursor_review_by_cursor`, `AI_REVIEW_SUMMARY_BY_CURSOR` และไฟล์ที่เคยใช้ชื่อ `claude_review_by_claude` / `AI_REVIEW_SUMMARY_BY_CLAUDE` ก่อนหน้านี้ ซึ่งผมไม่ได้เป็นผู้เขียนและตอนนี้ไม่อยู่ในโฟลเดอร์แล้ว

ยังไม่มี implementation ให้ทดสอบ ทุกข้อสรุปจึงเป็นการประเมินเอกสาร ไม่ใช่ผลวัดจริง ข้อมูลภายนอก (Node EOL, ข้อจำกัด Render free) **อ้างตามรีวิวของ Codex ที่แนบลิงก์ ผมยังไม่ได้เปิดเอกสารต้นทางตรวจซ้ำ** ชื่อ AI อ้างตามชื่อโฟลเดอร์ ไม่ใช่การรับรองผู้เขียน และเนื่องจากผมเป็นเจ้าของข้อเสนอ Claude การให้คะแนนตัวเองจึงมี bias ผมจึงให้น้ำหนักข้อวิจารณ์ของ Codex ต่อผมเป็นหลัก

## 2. เอกสารรีวิวที่เกี่ยวข้อง

| ข้อเสนอที่ถูกรีวิว | โดย Claude | โดย Codex | โดย Cursor |
|---|---|---|---|
| Claude | — (ไม่มี ผมไม่ได้เขียน self-review) | `claude_review_by_codex.md` | `claude_review_by_cursor.md` |
| Codex | `codex_review_by_claude.md` | `codex_review_by_codex.md` (self) | `codex_review_by_cursor.md` |
| Cursor | `cursor_review_by_claude.md` | `cursor_review_by_codex.md` | `cursor_review_by_cursor.md` (self) |

## 3. สิ่งที่แต่ละฉบับเสนอ

| ประเด็น | Claude | Cursor | Codex |
|---|---|---|---|
| Scope | Superset: meeting + candidate + feedback | เหมือน Claude | Generic CRUD ก่อน, candidate เป็น extension (+10–16 ชม.) |
| Stack | React/TS/Vite, Express/TS, Postgres + Drizzle, shared Zod | เหมือน Claude | React/TS/Vite, Express/TS, Postgres + `pg` + node-pg-migrate, shared contracts |
| Deploy | Render + nginx same-origin | เหมือน Claude | VPS เดียว + Compose + Caddy |
| Auth | โบนัสวัน 6 | เหมือน Claude | ไม่ทำ |
| จุดแข็ง | ครอบคลุม wireframe, แผนตัดงานชัด | แยกไฟล์อ่านง่าย | ความถูกต้องเชิงลึก, ประมาณเป็นชั่วโมง, open questions พร้อม fallback |
| จุดอ่อน | candidate ผูกด้วยชื่อ, deploy/เวลาแน่น | สืบทอดจาก Claude + เป็นสำเนา | wireframe ไม่อยู่ใน baseline, host ไม่ชัด, ออกแบบเกินตัวบางจุด |

**Cursor ไม่ใช่ข้อเสนออิสระ:** เทียบกับ `docs/AI-thinks/claude/` แล้ว ~84% ของบรรทัดไม่ซ้ำ (363/435) เหมือนกันทุกตัวอักษร รวมถึงตำหนิเฉพาะตัว (เส้น `USERS → FEEDBACK`, endpoint `/meta`) Codex ก็ตั้งข้อสังเกตเรื่องนี้โดยไม่สรุปว่าใครลอกใคร ดังนั้นมีมุมมองอิสระจริงแค่ **สอง** คือ Claude และ Codex ความเหมือนระหว่าง Claude/Cursor ไม่ใช่ฉันทามติ

## 4. ข้อโต้แย้งของ Codex ต่อข้อเสนอของ Claude ที่ผมยอมรับ

| ข้อ | ข้อสรุป |
|---|---|
| จับคู่ candidate ด้วยชื่อ (CL-01) | **ยอมรับ** เสี่ยงรวมประวัติ/feedback ของคนละคน ต้องใช้ `candidateId` สำหรับคนเดิมและสร้างคนใหม่แบบ explicit ไม่ merge อัตโนมัติ |
| Node 20 (CL-02) | **ยอมรับตามที่ Codex อ้าง** ว่า EOL ณ วันนี้ ต้องเปลี่ยนเป็น LTS ที่ยังรองรับและ pin ให้ตรงกันทั้ง local/CI/image |
| Render free (CL-03) | **ยอมรับบางส่วน** ผมเขียนเรื่อง cold start และ Postgres หมดอายุไว้แล้ว แต่แผนภาพ "Managed Postgres + backups" สื่อเกินจริง และ nginx upstream `api:3000` ใช้ได้เฉพาะ Compose ต้องกำหนด upstream ต่อ environment |
| แผนเวลาแน่น (CL-04) | **ยอมรับ** Day 7 ไม่ใช่ buffer เต็มวัน (ยังมี README, ADR, fresh-clone), ~60–70 tests + auth + design เกินจริงสำหรับ 5–6 วัน ควรเป็นชั่วโมงแยก core/candidate/bonus/contingency |
| PATCH มี version แต่ cancel/DELETE ไม่ระบุ (CL-06) | **ยอมรับ** ต้องกำหนดให้ชัด |
| `COMPLETED` "จำเป็น" (CL-09) | **ยอมรับ** ผมเขียนเกินไป จำเป็นเมื่อธุรกิจต้องการบันทึกว่าสัมภาษณ์เกิดขึ้นแล้วเท่านั้น |
| Repository ทำให้เปลี่ยน ORM/DB "ถูก" (CL-10) | **ยอมรับ** migrations, dialect และข้อมูลไม่ย้ายตาม ไม่ควรเรียกว่าเปลี่ยนฟรี |
| Approach A/C เทียบไม่แฟร์ | **ยอมรับ** ผมเปลี่ยน scope และคุณภาพไปพร้อมกันในตาราง และ C ผูก Redis/event bus/CQRS ไว้เป็นแพ็กเกจ ควรเปรียบเทียบบน acceptance scope เดียวกัน |

## 5. ข้อสังเกตต่อรีวิวของ Cursor (ความน่าเชื่อถือ)

- `claude_review_by_cursor.md` ให้ดาวเกือบเต็มและแทบไม่พบปัญหา ทั้งที่ Codex พบประเด็นระดับสูงหลายข้อในเอกสารเดียวกัน ข้อผิดพลาดที่ตรวจได้: รีวิวระบุ **DaisyUI** ในข้อเสนอของ Claude แต่ผม grep แล้ว **ไม่มีคำนี้เลย** ทั้งในไฟล์ Claude และโฟลเดอร์ Cursor (ข้อเสนอเขียน Tailwind + shadcn/ui/Radix แบบ optional)
- `comparative_summary_by_cursor.md` (ที่อ่านไว้) อธิบายข้อเสนอของ Cursor ว่า "ไม่มี shared npm package / แยก Zod / มี SQLite fallback 1 บรรทัด / มี manual QA 12 ข้อ" แต่โฟลเดอร์ Cursor จริงมี monorepo + shared Zod เหมือน Claude ผมค้น "12-point" และ "DaisyUI" ในโฟลเดอร์ Cursor **ไม่พบ** SQLite ปรากฏเป็นเพียงประโยค fallback เดียวกับของ Claude ไม่ใช่ mechanism ที่ implement ได้
- ข้ออ้างว่า Codex "ดูเป็นฝ่ายป้องกันตัว" และผู้ตรวจ "จงใจให้ requirement คลุมเครือ" เป็นการเดาใจผู้ตรวจ ไม่มีหลักฐานในโจทย์
- **SQLite "สลับด้วยบรรทัดเดียว" ไม่เป็นจริง:** Drizzle แยก schema ตาม dialect (`pgTable` vs `sqliteTable`), enum และ `timestamptz` ของ Postgres ไม่มีใน SQLite ต้องเขียน schema/migration แยก หากอยากได้ทางหนี ให้เป็นแผน B ระดับโครงการ (เปลี่ยน repository + migrations) ไม่ใช่ config flag

ดาวและฉลาก "Conservative Realist / Modern Professional" ไม่มีเกณฑ์ที่ตรวจสอบได้ จึงไม่นำมาใช้ตัดสิน

## 6. ประเด็นที่ต้องให้ผู้ใช้ตัดสิน

1. **Wireframe ต้องทำเต็มหรือไม่** — ไม่มีใครรู้เกณฑ์ผู้ตรวจ Codex กับผมเห็นตรงกันว่าฟันธงไม่ได้ ผมเอนไปทางทำ เพราะ wireframe อยู่ในโจทย์หัวข้อ "App Flow" และตัดทีหลังง่ายกว่าเติม
2. **ต้อง deploy DB เป็น container จริงหรือใช้ managed Postgres ได้** — กระทบ topology (Render/VPS)
3. **Due date = เวลาเริ่ม (instant) หรือวันที่ล้วน**
4. **ต้องการ auth/guest หรือไม่** — ถ้าทำ ต้องเลือก policy เดียวของ guest (อ่านอย่างเดียวหรือทำได้ทุกอย่าง) เพราะข้อเสนอฝั่ง Claude/Cursor เขียนไว้ขัดกันเอง
5. **งบเวลาจริง** — 40 ชั่วโมงเต็ม หรือเป็นช่วงเย็น

## 7. ข้อเสนอแนะของผม (สังเคราะห์)

**ฐาน:** Approach B แบบ modular monolith — React/TS/Vite + Express/TS + PostgreSQL คอนเทนเนอร์ + same-origin proxy

- **ใช้จาก Claude:** superset model ครอบคลุม wireframe (dashboard, booking form, candidate summary, cancel vs delete), shared Zod contract, cut order ที่ชัดเจน
- **ใช้จาก Codex:** date/time contract (offset ใน request, UTC ใน response, แสดง timezone), optimistic `version` พร้อมกำหนดให้ cancel/DELETE ตรวจ version หรือประกาศ last-writer ให้ชัด, pagination rules (เพดาน pageSize, หน้าเกินคืน 200 + ว่าง, ย้ายหน้าหลังลบ), ประมาณเป็นชั่วโมงแยก bucket, vertical-slice deploy ตั้งแต่ Day 1–2, open questions พร้อม fallback, ADR พร้อม revisit trigger, คำเตือนว่า seed ≠ backup
- **แก้ตามข้อโต้แย้งที่ยอมรับ:** `candidateId` แทนการ match ชื่อ, เปลี่ยน Node เป็น LTS ที่ยังรองรับ, ระบุ upstream/port ต่อ environment ใน nginx, ตัด `rating` ของ feedback, เลื่อน auth/design export ออกก่อน browser smoke
- **ตัดเพราะเกินตัว:** repeatable-read สำหรับ count+page, การจัดการ DST ซ้ำ/ไม่มีอยู่แบบเต็มรูป (ใช้ helper ที่ผ่านการทดสอบ + แสดง timezone ก็พอ), credential แยก migration/runtime, migrate job แยก (migrate-on-boot สำหรับ instance เดียว)
- **ทางหนี:** ถ้า deploy Postgres ไม่ผ่านเร็ว ให้ตัดสินใจเป็นแผน B (SQLite ผ่าน repository ใหม่ + migration แยก) ตั้งแต่ spike Day 1

**ลำดับแรกก่อนเขียนโค้ด:** spike วัน 1 ตรวจ workspace + Docker build + ปลายทาง hosting ที่เลือก แล้ว freeze schema/API contract จากนั้นเขียน acceptance checklist แยก mandatory / wireframe / bonus

## 8. แหล่งอ้างอิง

- [Claude proposal](../AI-thinks/claude/ARCHITECTURE_PROPOSAL.md) · [Cursor proposal](../AI-thinks/cursor/ARCHITECTURE_PROPOSAL.md) · [Codex proposal](../AI-thinks/codex/ARCHITECTURE_PROPOSAL.md)
- [Node.js releases](https://nodejs.org/en/about/previous-releases) และ [Render Free](https://render.com/docs/free) — อ้างผ่านรีวิวของ Codex ยังไม่ได้ตรวจซ้ำโดยผม
