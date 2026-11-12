# Review: Codex — `docs/AI-thinks/codex/ARCHITECTURE_PROPOSAL.md`

ผู้รีวิว: Claude · วันที่: 2026-11-12
ขอบเขต: อ่านครบทั้งไฟล์ (725 บรรทัด, 22 หัวข้อ) เทียบกับโจทย์ใน `requirement/20251009_Software Engineer_WebApp_Interview.md` และ Master Prompt

## สรุปสั้น

เอกสารที่ **ละเอียดและซื่อสัตย์เรื่อง scope ที่สุด** ในสามฉบับ เด่นเรื่องรายละเอียดความถูกต้อง (date/time, concurrency, pagination, Docker) แต่ **เลือกไม่ทำ wireframe ใน baseline** และ **ไม่เลือก platform deploy ที่ชัดเจน** ซึ่งเป็นความเสี่ยงต่อการถูกประเมิน

## Approach ที่เสนอ

Approach B: React + TS + Vite, Express + TS, PostgreSQL ผ่าน `pg` (SQL ตรง) + `node-pg-migrate`, shared `contracts` package (Zod), TanStack Query, CSS ธรรมดา, Compose 3 service + one-shot migrate job, deploy บน Linux host เดียว (Caddy), Vitest + Supertest + Playwright 1 flow, GitHub Actions
Entity เดียว `Meeting` (title, description, dueDate, status + version) — ส่วน Candidate/Feedback เป็น **extension ที่คิดต้นทุนแยก (+10–16 ชม.)** ไม่อยู่ใน baseline

## ข้อดี

1. **แยก Requirement / Wireframe expectation / Assumption / Recommendation ชัดเจน** ตรงกับที่ Master Prompt สั่ง ("do not silently resolve") และมี requirements matrix รายข้อ (M01–M13, O01–O04, W01–W20) พร้อม acceptance evidence
2. **ซื่อสัตย์เรื่อง scope**: บอกตรงๆ ว่า baseline ไม่ครอบคลุม wireframe และต้องไม่อ้างว่าครอบคลุม พร้อมให้ตัวเลขชั่วโมงของ extension
3. **ประมาณเวลาเป็นชั่วโมง** (A 24–32, B 34–42, C 52–72) พร้อม contingency 6 ชม. และเงื่อนไขชัดว่าเลื่อนอะไรก่อนถ้าช้า ใช้เป็น plan ได้จริงกว่า "ประมาณ N วัน"
4. **ตีความ "DB container" รอบคอบ**: ชี้ว่า SQLite/ไฟล์ใน API container อาจไม่ผ่านข้อ "containerize Database" จึงเลือก Postgres container
5. **Date/time ละเอียดที่สุด**: บังคับ offset ใน request, response เป็น UTC, ปฏิเสธ date-only, จัดการเวลา DST ที่ไม่มีอยู่จริง/ซ้ำ, แสดง timezone ข้างช่องกรอก, `timestamptz` ไม่เก็บชื่อ timezone (ระบุข้อจำกัด)
6. **Concurrency ครบทั้ง update และ delete**: optimistic `version` ใน WHERE เดียว, แยก 404 vs 409 พร้อมยอมรับว่า race ทำให้ผลต่างได้, มี conflict UI ที่ไม่ resubmit อัตโนมัติ
7. **Pagination คิดละเอียด**: เพดาน pageSize/page, deterministic sort `due_date, id`, หน้าเกินคืน 200 + items ว่าง, count+page ใน snapshot เดียว, หลังลบหน้าสุดท้ายให้ย้ายหน้า, ยอมรับว่าไม่ใช่ snapshot ข้าม request
8. **ไม่โอ้อวด guarantee**: POST ที่ response หาย = "ไม่แน่ใจ" ไม่ใช่ "ล้มเหลว", ระบุว่า double-click guard ≠ exactly-once, ไม่อ้าง compliance/audit
9. **Docker/Deploy ลงรายละเอียดที่คนมักพลาด**: migration runner ถูก prune ออกจาก prod image, path ของ data volume ต่างกันตามเวอร์ชัน Postgres, เปลี่ยน env bootstrap ไม่ rotate credential ของ volume เดิม, volume ไม่ใช่ backup, healthcheck ไม่เท่ากับ traffic removal
10. **Security ซื่อตรง**: ระบุว่า anonymous shared demo = ใครก็แก้/ลบได้, ห้ามใส่ข้อมูลจริง, CORS ไม่ใช่ auth, ไม่มี static secret ใน bundle
11. **Open questions 12 ข้อเรียงลำดับความสำคัญ พร้อม fallback ทุกข้อ** — ใช้ตัดสินใจต่อได้ทันที
12. **ADR มี "revisit trigger"** ทุกข้อ และมีลิงก์อ้างอิงเอกสารทางการ (React, TanStack Query, node-postgres, PostgreSQL, Express security, Docker startup order)

## ข้อเสีย / ความเสี่ยง

1. **Baseline ไม่ทำ wireframe** (candidate, position, เวลาเริ่ม-จบ, meeting type, feedback, history, Cancel) หน้าที่ผู้ประเมินเห็นคือ list/form ของ "meeting" ทั่วไป เสี่ยงถูกมองว่าไม่ได้ทำครึ่งหนึ่งของโจทย์ ทั้งที่โจทย์มี wireframe แยกเป็น "App Flow" และ Master Prompt ให้ความสำคัญกับความขัดแย้งนี้ การ "ถามก่อน" ใช้ไม่ได้ในสถานการณ์ take-home ที่มักไม่มีคนตอบ
2. **แผน 40 ชม. ไม่มีที่ว่างสำหรับ extension** ถ้าผู้ตรวจต้องการ wireframe จริง ต้องเพิ่มอีก 10–16 ชม. ซึ่งเกินงบ — แผนจึงไม่ครอบคลุมกรณีที่น่าจะเกิดจริงที่สุด
3. **ไม่ระบุ hosting ชัดเจน**: "Linux host เดียว + Caddy" ต้องมีเครื่อง/โดเมน/DNS ที่ยังไม่มี และไม่ได้เลือกผู้ให้บริการ ทั้งที่ "deploy" เป็นข้อบังคับ ทำให้ความเสี่ยงสูงสุดของโปรเจกต์ยังไม่ถูกปิด (แม้ Day 1 จะให้ลอง deploy เร็ว)
4. **Over-engineering ในจุดที่ขัดกับหลักของตัวเอง** สำหรับตารางเดียว: repeatable-read transaction เพื่อ count+page, ตรวจ DST ที่ซ้ำ/ไม่มีอยู่, `version` บน DELETE ผ่าน query param, แยก credential migration/runtime, migrate job แยก, cap page 10,000, บังคับ offset ใน timestamp — ล้วนมีเหตุผล แต่รวมกันกินเวลาเกินคุณค่าที่ผู้ตรวจจะเห็น
5. **เลือก raw `pg` + CSS ธรรมดา**: ต้อง map row→DTO และเขียน UI เองทั้งหมด เร็วในระยะสั้นน้อยกว่าที่คิด และ UI ที่ดูดีมีผลต่อ "User experience" ใน criteria
6. **ไม่มี auth/guest/UI design/ไฟล์ wireframe เลย** — ยอมรับได้ในฐานะ bonus แต่เสียโอกาสทำคะแนนเพิ่มจากงานที่ราคาถูก (เช่น guest mode)
7. **เอกสารยาวและเป็นร้อยแก้วหนาแน่น** (725 บรรทัด) ใช้เวลาอ่านมากกว่า ตารางสรุปมีน้อยกว่า ไม่มี route table / component tree เชิงภาพ
8. **ข้อความ meta ปนอยู่ในเอกสารสถาปัตยกรรม**: ย่อหน้า provenance ตอนต้น และ ADR-014 ("Other AI proposals excluded as design sources") เป็นเรื่องกระบวนการของการเขียน ไม่ใช่การตัดสินใจเชิงสถาปัตยกรรม ควรอยู่นอกเอกสารที่จะ commit ลง repo
9. **ขาด COMPLETED** ทั้งที่ History ใน wireframe ต้องการแยก "meeting ที่เสร็จแล้ว" (ใช้ได้โดยอนุมานจากวันที่ แต่ตั้งใจไม่เพิ่ม status)
10. **ไม่มี API versioning** (เหตุผลสมเหตุสมผล) และ OpenAPI เขียนมือ ยอมรับเองว่าอาจ drift

## ข้อสังเกตเพิ่มเติม

- เอกสารนี้ระบุว่า "ไฟล์ก่อนหน้าที่วางผิดที่" ถูกเปิดอ่านเพื่อตรวจ authorship และ "ความพยายาม archive ไฟล์นั้นไม่พบตอนตรวจสุดท้าย" — ตรงกับเหตุการณ์ที่ `ARCHITECTURE_PROPOSAL.md` ของ Claude หายจาก root ระหว่างงาน (ผมไม่สามารถยืนยันได้ว่าเป็นสาเหตุ แต่ควรรู้ไว้)
- Codex ประกาศว่าไม่ใช้ข้อเสนออื่นเป็นแหล่งออกแบบ และเนื้อหาก็ต่างจากฉบับอื่นจริง จึงเป็นมุมมองอิสระที่แท้จริงเพียงมุมเดียวเมื่อเทียบกับ Claude

## เทียบกับ Claude (ข้อเสนอของผมเอง)

| ประเด็น | Codex | Claude |
|---|---|---|
| ครอบคลุม wireframe | ไม่ (extension แยก) | ครบใน baseline |
| ความลึกด้านความถูกต้อง (date/pagination/concurrency/Docker) | **ลึกกว่า** | พอใช้ มีข้อกำหนดแต่ตื้นกว่า |
| Hosting | ไม่ระบุ platform | Render ชัดเจน |
| UI/DX stack | เรียบ (CSS ธรรมดา) | Tailwind + RHF |
| ความซื่อสัตย์เรื่องเวลา/สมมติฐาน | **สูงกว่า** (ชั่วโมง + ช่วงประมาณการ) | ประมาณเป็นวัน ไม่ระบุ confidence ต่อรายการ |
| ความเสี่ยงต่อการประเมิน | wireframe ขาด | scope กว้าง เวลาแน่น |

## ข้อเสนอแนะเมื่อนำไปรวมกัน

- ใช้ **superset model + Render** แบบ Claude แต่ยืม **date/time contract, concurrency (version ทั้ง PATCH และ DELETE ถ้าไม่หนักเกินไป), pagination rules, Docker pitfalls, open questions พร้อม fallback และ ADR revisit trigger** จาก Codex
- ตัดของที่เกินสำหรับ take-home: repeatable-read count, DST ambiguity handling, credential แยก migration/runtime, migrate job แยก (migrate-on-boot ก็พอ)
- เก็บคำเตือนของ Codex เรื่อง "อย่าทำ control ที่ไม่ใช้งานจริง" (ปุ่ม Add Feedback/Cancel ที่ไม่ทำงาน)
