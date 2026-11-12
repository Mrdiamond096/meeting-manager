# Review: Cursor — Approach and Solution

ผู้รีวิว: Codex · วันที่: 12 พฤศจิกายน 2026 · สถานะ: document review ก่อน implementation

ต้นฉบับ: [Cursor index](../AI-thinks/cursor/ARCHITECTURE_PROPOSAL.md) และไฟล์เนื้อหาใน [architecture-proposal](../AI-thinks/cursor/architecture-proposal/) ทั้ง 23 ไฟล์ เทียบกับ [assignment](../../requirement/20251009_Software%20Engineer_WebApp_Interview.md) และ Master Prompt การอ่าน index อย่างเดียวไม่เพียงพอสำหรับรีวิวนี้

ระดับ **สูง** = ควรแก้ก่อนใช้เป็น baseline; **กลาง** = contract/operational decision ที่ควรปิด; **ต่ำ** = ความแม่นยำของเอกสาร ยังไม่ได้ทดสอบแอปจริงและไม่ถือว่าข้อความกำกวมเป็นบั๊กที่เกิดขึ้นแล้ว ชื่อ AI อ้างอิงโฟลเดอร์ ไม่ได้รับรอง provenance ของต้นฉบับ

## ความเห็นโดยรวม

**แนวทาง B ใช้ได้สำหรับ candidate scheduler แต่ยังมีข้อขัดแย้งใน schema, validation และ guest policy ที่ควรรวมให้เหลือ contract เดียว** โครงสร้างเอกสารแยกหัวข้ออ่านสะดวก เห็น UX/API/operations ครบ แต่ความละเอียดหลายไฟล์เพิ่มโอกาสที่ข้อมูลคนละส่วนไม่ตรงกัน

Claude และ Cursor มีส่วนที่ตรงกันหรือใกล้เคียงมากใน scope, stack, API และแผนงาน การพบข้อเสนอแบบเดียวกันสองไฟล์จึงไม่ใช่หลักฐานยืนยันทางเทคนิคสองชุดที่เป็นอิสระ ไม่สรุปว่าใครคัดลอกใครจากความเหมือนเพียงอย่างเดียว

## ข้อดีที่ควรเก็บไว้

- **แยกเอกสารตาม concern ชัด:** index ลิงก์ถึง requirements, architecture, data, API, deployment และ edge cases ช่วยทำ review เป็นหัวข้อได้
- **พยายามทำ wireframes ให้ใช้งานจริง:** Candidate/Meeting/Feedback รองรับ profile/history แทน static mock; มี free-text fallback สำหรับ autocomplete
- **เทคโนโลยีสอดคล้องกัน:** React/TS/Express, shared Zod, PostgreSQL/Drizzle และ query cache ทำให้ frontend/backend มี boundary ที่เข้าใจง่าย
- **backend มี transaction และ atomic PATCH:** [§12](../AI-thinks/cursor/architecture-proposal/12_backend_design.md) แยก rules ออกจาก HTTP/SQL และอธิบาย version condition ถูกทิศทาง
- **UX failure states และ a11y มีรายละเอียด:** [§11](../AI-thinks/cursor/architecture-proposal/11_frontend_design.md) ไม่ได้ละเลย error mapping, keyboard, loading และ conflict prompt
- **ทดสอบกับ PostgreSQL จริงและ Docker build:** [§14](../AI-thinks/cursor/architecture-proposal/14_testing_strategy.md) และ [§16](../AI-thinks/cursor/architecture-proposal/16_cicd_strategy.md) ช่วยตรวจสิ่งที่ mock ไม่ครอบคลุม
- **รู้จักตัดงานที่เกินโจทย์:** [§19](../AI-thinks/cursor/architecture-proposal/19_tradeoffs_and_rejected_alternatives.md) ไม่เลือก microservices, calendar integration และ availability engine ใน recommendation

## ประเมิน A / B / C

อ้างอิง [approaches](../AI-thinks/cursor/architecture-proposal/05_proposed_solution_approaches.md) และ [comparison](../AI-thinks/cursor/architecture-proposal/06_architecture_comparison_matrix.md)

| Approach | ข้อดี | ข้อเสีย | ข้อเสนอ |
|---|---|---|---|
| A — Minimal | dependencies และเวลาน้อย เป็นทางหนีเมื่อ budget จำกัด | single container กับ SQLite/JSON ยังมีข้อกังขาต่อ containerization ทั้งสามส่วน; ถูกจับคู่กับ weak testing และ scope ต่ำกว่า B ทำให้เทียบไม่เท่ากัน | ทำ A ที่ผ่าน acceptance เดียวกันก่อน แล้วเทียบเฉพาะ engineering overhead |
| B — Balanced | มีขอบเขตชัดและครอบคลุม candidate journey ในเชิงแบบออกแบบ | รวมหลาย module, forms, filters, docs, tests และ optional auth ในสัปดาห์เดียว; ยังมี contract ขัดกัน | เลือก B หลังแก้ประเด็นสูงและลดงานเสริม |
| C — Extensible | มองอนาคตและระบุ cost ของความซับซ้อน | ใช้ Redis/event bus/CQRS/RBAC/DI เป็นแพ็กเกจเดียว ทั้งที่ extensible monolith ไม่จำเป็นต้องมีสิ่งเหล่านี้ | เสนอ C แบบเพิ่ม modularity/contract ตามความต้องการจริง ไม่สร้างตัวเลือกที่ overengineered ตั้งแต่ต้น |

## ประเด็นหลักที่ควรแก้

### CU-01 — Candidate identity อิงชื่อ และ uniqueness ยังเป็นคำถาม [สูง]

**หลักฐาน:** [Data Model](../AI-thinks/cursor/architecture-proposal/09_data_model.md) มี `unique on lower(name)+position?` และใช้ case-insensitive free-text matching; [trade-offs](../AI-thinks/cursor/architecture-proposal/19_tradeoffs_and_rejected_alternatives.md) ยอมรับ name matching เป็น debt

เครื่องหมายคำถามใน constraint ไม่ใช่ schema ที่ implement ได้แน่นอน และแม้เพิ่ม unique(name, position) ก็ยังรวมคนละคนชื่อ/ตำแหน่งเหมือนกัน ส่งผลต่อ interview history และ feedback โดยตรง

**แก้:** แยกการเลือก ID เดิมกับการสร้างคนใหม่ ห้าม infer identity จากชื่อ; ระบุ application/role ownership และทดสอบ same-name distinct candidates รวมถึง concurrent booking โดยไม่สร้าง/รวมผิดคน

### CU-02 — Node 20 ไม่เหมาะเป็น runtime ใหม่ ณ วันรีวิว [สูง]

**หลักฐาน:** [stack](../AI-thinks/cursor/architecture-proposal/07_recommended_technology_stack.md), [Docker](../AI-thinks/cursor/architecture-proposal/15_docker_and_deployment_strategy.md) และ [CI](../AI-thinks/cursor/architecture-proposal/16_cicd_strategy.md) ใช้ Node 20

Node 20 อยู่สถานะ EOL ณ 12 พฤศจิกายน 2026 ตาม [Node.js releases](https://nodejs.org/en/about/previous-releases) เปลี่ยนเป็น LTS ที่ยังรองรับ ตรวจความเข้ากันได้ แล้ว pin local/CI/images ให้ตรงกัน ไม่ใช่ข้อกล่าวหาว่าเทคโนโลยีนี้ผิดในบริบทปี 2025

### CU-03 — Render topology ยังไม่รองรับสมมติฐานทั้งหมด [สูงถ้าเลือก free plan]

**หลักฐาน:** [System Architecture](../AI-thinks/cursor/architecture-proposal/08_system_architecture.md) แสดง managed Postgres + backups; [Deployment](../AI-thinks/cursor/architecture-proposal/15_docker_and_deployment_strategy.md) ระบุ Render free, nginx upstream `api:3000`, seed-on-boot และ migration healthcheck

ชื่อ service ของ Compose ไม่ใช่ upstream ที่รับประกันบน PaaS ต้องระบุปลายทาง/port จริง; free Render web รับ private traffic ไม่ได้ ขณะที่ free Postgres หมดอายุ 30 วันและไม่มี managed backup ตาม [Render documentation](https://render.com/docs/free) จึงต้องเลือก public upstream หรือ paid/private topology ให้ชัด ไม่ใช่นำ Compose configuration ไปใช้ตรง ๆ

**แก้:** เลือก deployment topology และ budget ตั้งแต่ต้น ยืนยัน managed DB ตามโจทย์ ตั้ง environment-specific upstream, ตรวจ health gate จริง, แยก seed ออกจาก backup/restore และทำ public smoke test ก่อนวันสุดท้าย

### CU-04 — ER diagram กับ feedback schema ยังไม่ตรงกัน [กลาง]

**หลักฐาน:** [Data Model](../AI-thinks/cursor/architecture-proposal/09_data_model.md) มีความสัมพันธ์ USERS → FEEDBACK แต่ feedback field ระบุเพียง `author` เป็นข้อความ ไม่มี `user_id` FK ขณะที่ auth เป็นโบนัส

ผู้ลงมือทำต้องเดาเองว่า guest/no-auth feedback มี author อย่างไร และถ้าเปิด auth จะเปลี่ยน field หรือเปลี่ยนความหมายเดิมหรือไม่

**แก้:** baseline ใช้ display-name text และเอา user relationship ออกจาก diagram หรือออกแบบ nullable authorUserId พร้อม guest rule อย่างชัดเจน ไม่จำเป็นต้องสร้างระบบ user ก่อนถ้า auth ไม่อยู่ใน scope

## ความกำกวม/ข้อเสียเพิ่มเติม

| ID / ระดับ | หลักฐาน | ผลกระทบและข้อเสนอ |
|---|---|---|
| CU-05 / กลาง | §10 บอก unknown keys stripped และ strict on write; §13 บอก strip | เลือก write policy เดียว: reject เพื่อจับ client typo หรือ strip แบบตั้งใจ; sync schema/OpenAPI/tests ไม่เรียกสิ่งนี้ว่าช่องโหว่โดยไม่มี implementation |
| CU-06 / กลาง | §13 guest configurable read-only/sandboxed; §20 guest ทำทุกอย่าง | สิทธิ์ที่ไม่แน่นอนกระทบ UI และ API; เลือกหนึ่ง policy และใช้ synthetic data ถ้า shared writes ไม่ถือว่า cookie ช่วยแยกข้อมูลให้อัตโนมัติ |
| CU-07 / กลาง | §10 PATCH มี version แต่ cancel/DELETE ไม่ระบุ | กำหนด stale-action semantics ของ cancel/delete ให้ชัด จะ conditional หรือ last-writer-wins; การป้องกัน PATCH อย่างเดียวไม่ครอบคลุมสอง action นี้ |
| CU-08 / กลาง | §17 deployment gate วัน 6; Day 7 ยังมี submission/docs; §14 มีราว 60–70 tests | Buffer จริงน้อยกว่าที่บอก; ใช้ hour budget แยก contingency, deploy vertical slice เร็ว และตัด auth/design export ก่อน browser CRUD smoke |
| CU-09 / กลาง | §9 Upcoming = endAt >= now และ status != CANCELLED | รวม ongoing และอาจรวม COMPLETED ที่เวลายังไม่หมด; ให้ product นิยาม Upcoming/Current แยกชัด ไม่ถือว่ามีคำตอบเดียวจากโจทย์ |
| CU-10 / ต่ำ | §10 และ ADR-006 เรียก error ว่า RFC7807-style แต่เป็น nested `error` envelope | Custom envelope ใช้ได้ แต่ไม่ควรสื่อว่าเป็นมาตรฐานโดยไม่กำหนด mapping/media type; ใช้คำว่า custom JSON error หรือกำหนด Problem Details ให้ตรง [RFC 9457](https://www.rfc-editor.org/rfc/rfc9457.html) ซึ่งแทน RFC 7807 แล้ว |
| CU-11 / ต่ำ | §11 ระบุ keepPreviousData แต่ไม่ pin TanStack Query release | ไม่ใช่ bug จากชื่อเพียงอย่างเดียว เพราะ helper นี้ยังมีอยู่; pin version และใช้ API ของรุ่นนั้น เอกสารปัจจุบันแสดง `placeholderData: keepPreviousData` ใน [pagination guide](https://tanstack.com/query/latest/docs/framework/react/guides/paginated-queries) |

## ประเด็นที่ไม่ควรตัดสินเกินหลักฐาน

การใช้ Drizzle ไม่ได้พิสูจน์ว่าดีกว่า Prisma/raw SQL ทุกบริบท และ shared TypeScript/Zod ลด contract drift แต่ไม่ได้ทำให้ business rules, migrations และ authorization ถูกต้องเอง การไม่ใช้ JSON key ชื่อ dueDate ตรงตัวไม่ใช่ noncompliance ที่พิสูจน์แล้ว เพราะ core ไม่ได้กำหนด request schema; ประเด็นคือความหมายต้องตรงและต้องแก้ค่าได้จริง

Healthcheck และ seed เป็นเรื่องที่เอกสารระบุไว้แล้ว จึงไม่ควรรีวิวว่า “ไม่มี healthcheck/seed” ข้อบกพร่องคือคำอธิบาย recovery/traffic gating ยังไม่เพียงพอ ไม่ใช่ขาดทุกอย่าง

## ขั้นตอนที่แนะนำก่อนอนุมัติ

1. รวม schema, strictness, status errors และ guest policy ให้เป็น contract เดียวข้ามทุกไฟล์
2. แก้ candidate identity และ feedback authorship; ตัด optional metadata เช่น rating ถ้าไม่จำเป็น
3. เปลี่ยน supported runtime และทำ deployment spike บน plan ที่จะใช้จริง
4. เขียน hourly budget และ acceptance checklist ที่แยก mandatory/wireframe/bonus; คง real-DB integration และ browser happy path
5. เลือก B เมื่อแก้ข้างต้นแล้ว หากไม่มีเวลาให้ลด product scope โดยแจ้ง evaluator ไม่ใช่ลด reliability ของ mandatory paths

**ข้อสรุป:** จุดแข็งคือ product coverage และเอกสารที่ค้นง่าย จุดที่ต้องระวังคือรายละเอียดหลายไฟล์ยังไม่ตรงกัน การเลือก B สมเหตุผล แต่คำรับรองว่าครบและทันเวลาควรมี scope gate และ deployment proof รองรับ
