# Review: Claude — Approach and Solution

ผู้รีวิว: Codex · วันที่: 12 พฤศจิกายน 2026 · สถานะ: document review ก่อน implementation

ต้นฉบับที่ตรวจ: [Claude architecture proposal](../AI-thinks/claude/ARCHITECTURE_PROPOSAL.md) ทั้ง 22 หัวข้อและ appendix โดยเทียบกับ [assignment](../../requirement/20251009_Software%20Engineer_WebApp_Interview.md) และ Master Prompt ของผู้ใช้ การระบุชื่อ Claude อิงชื่อโฟลเดอร์ ไม่ใช่การรับรองประวัติผู้สร้างไฟล์

ข้อจำกัด: ยังไม่มี implementation ให้ตรวจ จึงประเมินความสอดคล้องของแบบออกแบบและความเสี่ยง ไม่ได้ยืนยันว่าแอปมีบั๊กหรือช่องโหว่จริง ระดับ **สูง** หมายถึงควรแก้ก่อนใช้เป็น implementation baseline; **กลาง** คือควรตัดสินใจ/ระบุ contract; **ต่ำ** คือปรับความแม่นยำของเอกสาร

## ความเห็นโดยรวม

**Approach B เป็นฐานที่เหมาะถ้าต้องทำ candidate wireframes จริง แต่ควรแก้เรื่อง identity, deployment และแผนเวลาก่อนอนุมัติ** จุดแข็งคือมอง product flow ครบกว่า generic CRUD และไม่ได้สร้างประวัติสัมภาษณ์ปลอม จุดอ่อนคือคำกล่าวว่าเป็น architecture ที่เล็กที่สุดและครอบคลุมทั้งหมดมั่นใจเกินหลักฐาน โดยเฉพาะเมื่อรวมประมาณ 60–70 tests, feedback, design artifacts และอาจเพิ่ม auth ภายใน 5–6 วันทำงาน

ไม่ถือว่าการใช้ `startAt` แทนคำว่า due date ผิดโจทย์โดยอัตโนมัติ: assignment ไม่ได้กำหนดชื่อ JSON field แต่ควรยืนยันความหมายและบอก mapping ให้ผู้ตรวจเข้าใจ

## ข้อดีที่ควรเก็บไว้

- **มองเห็น scope conflict:** §4 แยก CRUD กับ candidate scheduling และอธิบาย delete/cancel ต่างกัน ช่วยป้องกันการลบประวัติเพียงเพราะกดยกเลิกนัด
- **โมเดลมีความสัมพันธ์จริง:** §9 ใช้ Candidate → Meetings → Feedback เหมาะกับ summary/history มากกว่าฝังชื่อไว้ใน title แล้วพยายามค้นประวัติย้อนหลัง
- **โครงสร้าง backend ใช้งานได้จริง:** §12 แยก app factory, startup, HTTP, service และ repository; มี transaction สำหรับสร้าง candidate/meeting และ atomic version update
- **UI ครอบคลุม flow:** §11 มี booking/edit/details, feedback/history, loading/error/empty states และ accessibility ไม่ได้หยุดที่เลือก framework
- **เลือก infrastructure พอดี:** React/Express/Postgres, same-origin proxy และไม่มี microservices/queue ใน recommendation เหมาะกับขนาดงาน
- **ทดสอบกับฐานข้อมูลจริง:** §14 เลือก real PostgreSQL integration และ browser smoke เป็นแนวทางที่ตรวจ constraint/query ได้จริง
- **มี cut order และข้อจำกัด:** §17 และ §19 บอกสิ่งที่จะไม่ทำและลำดับลดโบนัส แม้ควรปรับรายละเอียดตามข้อสังเกตด้านล่าง

## ประเมินแต่ละ approach

| Approach | ข้อดี | ข้อเสีย/สิ่งที่ควรปรับ | ความเหมาะสม |
|---|---|---|---|
| A — Minimal | เร็ว ติดตั้งง่าย ใช้เป็น fallback ได้ | §5 ใช้ single container และ SQLite/JSON จึงยังไม่ใช่ตัวเลือกที่มั่นใจว่าครบคำสั่ง containerize frontend/backend/database; การไม่มี wireframe ไม่ได้แปลว่าต้องมี single-file sprawl | ใช้ได้เมื่อยืนยันขอบเขต/การตีความ container แล้ว หรือแยก FE/API/DB ให้ชัด |
| B — Balanced | แยก concerns, schema/validation, real persistence และ candidate UX ได้ครบในเชิง intent | เป็นงานมากกว่า CRUD อย่างมีนัยสำคัญ; ต้องแก้ identity, lifecycle และ release details; ลดโบนัสก่อนเริ่ม | เหมาะที่สุดในสามตัวเลือก หาก wireframes อยู่ใน scope |
| C — Extensible | เสนอขอบเขตสำหรับอนาคตและเตือนเรื่อง overengineering | ผูก extensibility เข้ากับ DI, CQRS-lite, event bus, Redis, RBAC, flags และ observability พร้อมกัน ทำให้ C ดูแย่โดยนิยาม | ควรเสนอ C แบบ modular monolith ที่เพิ่มเฉพาะความสามารถมีเหตุผล ไม่ต้องมี cache/event bus |

ตาราง §6 เปลี่ยนทั้ง architecture, product scope และคุณภาพการทดสอบพร้อมกัน จึงยังสรุปไม่ได้ว่า B ดีกว่า A/C เพราะ architecture อย่างเดียว ควรเปรียบเทียบบน acceptance scope เดียวกัน แล้วแยก effort ของ candidate/auth ออกต่างหาก

## ประเด็นที่ควรแก้ก่อนใช้

### CL-01 — รวม candidate ตามชื่อเสี่ยงให้ประวัติผิดคน [สูง]

**หลักฐาน:** §9 ระบุ case-insensitive name matching แล้ว reuse candidate; §19 จัดเป็น acceptable debt

คนสองคนชื่อเดียวกันอาจถูกผูกกับ candidate ID เดียว และ summary จะรวมการสัมภาษณ์/feedback ของคนละคน การ trim/case-fold ช่วยค้นหา แต่ไม่พิสูจน์ identity การใส่ role ในเงื่อนไขก็ยังแยกคนชื่อและตำแหน่งเหมือนกันไม่ได้

**ข้อเสนอ:** เมื่อเลือก candidate เดิมให้ส่ง `candidateId`; ถ้าพิมพ์ชื่อใหม่ให้สร้าง identity ใหม่อย่างชัดเจน ไม่ auto-merge ด้วยชื่อ เพิ่ม test คนชื่อเดียวกันสองคน และนิยามว่าหนึ่ง candidate รองรับหลาย application หรือไม่

### CL-02 — Runtime ที่เสนอหมดระยะสนับสนุนแล้ว [สูง ณ วันรีวิว]

**หลักฐาน:** §7 เลือก Node 20, §15 ใช้ `node:20-alpine`, §16 ตั้ง CI เป็น Node 20

ณ 12 พฤศจิกายน 2026 Node 20 อยู่สถานะ EOL ตาม [Node.js release table](https://nodejs.org/en/about/previous-releases) ควรเลือก LTS ที่ยังรองรับและตรวจ compatibility ของ dependencies แล้ว pin ให้ตรงกันใน local/CI/images นี่เป็นข้อสังเกตตามวันที่รีวิวปัจจุบัน ไม่ใช่การกล่าวว่า Node 20 ไม่เหมาะสมในวันที่โจทย์ถูกตั้งเมื่อปี 2025

### CL-03 — Deployment ที่เสนอมีเงื่อนไขสำคัญไม่ครบ [สูงถ้าใช้ free Render ตามแผน]

**หลักฐาน:** §8 แสดง managed Postgres พร้อม backups; §15 เสนอ free Render, nginx proxy `http://api:3000` และใช้ seed-on-boot เป็นวิธีกู้ demo

Compose hostname `api` ใช้ได้ใน Compose แต่ต้องเปลี่ยนเป็น upstream จริงเมื่อแยก Render services และระบุ public/private routing ให้ชัด ที่สำคัญ free web service รับ private network traffic ไม่ได้; free Postgres หมดอายุใน 30 วันและไม่มี managed backups ตาม [Render Free documentation](https://render.com/docs/free) จึงไม่ควรใช้ diagram ที่สื่อว่าฟรีพร้อม backup โดยไม่มีเงื่อนไข

**ข้อเสนอ:** เลือก topology/compute plan ให้ชัดตั้งแต่ต้น ระบุ upstream และ port ของแต่ละ environment; ทดสอบ public URL เร็ว; seed เป็นการสร้างข้อมูลตัวอย่าง ไม่ใช่ restore ข้อมูลที่ evaluator แก้; ใช้ backup/restore แยกต่างหาก และยืนยันว่า managed DB ยอมรับได้ภายใต้ข้อกำหนด containerization

### CL-04 — แผนเวลารวมโบนัสมากและ deploy หลักช้า [กลางถึงสูง]

**หลักฐาน:** §14 ตั้งประมาณ 20 unit + 30 API + 12 component + E2E; §17 ให้ frontend หลักเริ่มวัน 4, deployment gate วัน 6 และอาจทำ auth ในวันเดียวกัน

ประมาณการอาจเป็นไปได้สำหรับผู้ชำนาญ แต่ยังไม่แจก effort ให้ configuration, test fixtures, cookie/security, documentation และ hosting failures พอ การบอก Day 7 เป็น buffer ทั้งวันคลาดเคลื่อนเพราะมี README, ADR, fresh-clone และ submission work อยู่แล้ว ทั้งนี้เอกสารมี early trial deploy วัน 3 ซึ่งเป็น mitigation ที่ดี แต่ควรทำเป็น gate ไม่ใช่แค่ “if possible”

**ข้อเสนอ:** ใช้ focused hours แยก core/candidate/bonus/contingency; deploy vertical slice ภายในวัน 1–2; ตัด auth และ design export ก่อน browser smoke ที่ตรวจ mandatory flow; เลือก test ตามพฤติกรรมเสี่ยง แทนจำนวน test/coverage เป้าหมาย

## ข้อเสียและรายละเอียดรอง

| ID / ระดับ | หลักฐาน | ผลกระทบและข้อเสนอ |
|---|---|---|
| CL-05 / กลาง | §10 create ต้องมี candidateName, position, start/end, type | Superset ในความหมาย “มีทุก field” ยังบังคับ workflow เพิ่มกับ generic meeting; ไม่ใช่ข้อผิดโจทย์ที่พิสูจน์แล้ว แต่ควรยืนยันกับ evaluator และอธิบาย `dueDate → startAt` ชัดเจน |
| CL-06 / กลาง | §10 PATCH requires version แต่ cancel/DELETE ไม่ระบุ version | Atomic PATCH ไม่ได้ป้องกัน stale cancel/delete โดยอัตโนมัติ; กำหนดว่าจะให้สอง action นี้ conditional ด้วยหรือยอมรับ last-writer behavior และทดสอบ |
| CL-07 / กลาง | §15 migrate on boot และ healthcheck “blocks traffic” | ใช้ได้ใน single instance ถ้าล้มเหลวแล้วไม่เริ่ม listen แต่ Docker healthcheck อย่างเดียวไม่ใช่ traffic gate; ระบุ startup failure, platform readiness และ migration serialization ให้ชัด |
| CL-08 / กลาง | §13 optional JWT cookie auth; §10 มี logout | ยังไม่ระบุ expiry, logout semantics, guest write policy ที่เป็นหนึ่งเดียว และผลต่อ anonymous API; เลื่อน auth ออกจาก baseline หรือออกแบบ/test session lifecycle ก่อนทำ ไม่ต้องสร้างระบบใหญ่ |
| CL-09 / กลาง | §9 candidate.position กับ meeting.position; Upcoming = endAt >= now และไม่ cancelled | ระบุว่า role เป็น application identity หรือ snapshot; นิยามว่าจะรวม ongoing/COMPLETED หรือไม่ อย่าปล่อยให้ชื่อหน้าเป็นผู้กำหนด query โดยปริยาย |
| CL-10 / ต่ำ | §19 ORM/hosting ถูกจัดว่า cheap to change | Repository ลด coupling แต่ไม่ย้าย migrations, SQL dialect, connection behavior, data และ hosting secrets ให้เอง ควรจัดเป็น cost-dependent ไม่ใช่เปลี่ยนฟรี |

Completed ไม่ใช่สิ่งที่ “จำเป็น” ต่อ History เสมอไปตาม §4: สามารถแสดงนัดที่ผ่านมาโดยใช้เวลาและ feedback ได้ เป็น status ที่เพิ่มได้เมื่อ business ต้องการบันทึกว่าสัมภาษณ์เกิดขึ้นแล้ว ไม่ใช่กฎจากโจทย์

## สิ่งที่แนะนำให้ทำต่อ

1. ยืนยันระดับความสำคัญของ wireframes, due-date semantics และ topology ที่ใช้ส่งจริง
2. แก้ candidate selection ให้ใช้ ID; ระบุ role/application model และ conditional cancel/delete
3. เปลี่ยน Node เป็น supported LTS และตรวจ migration runner ใน production image
4. แยก budget สำหรับ candidate features, core delivery และ buffer; ตัด auth ออกจากสัปดาห์แรกหากไม่จำเป็น
5. อนุมัติ B เมื่อ contract และแผน release ข้างต้นชัด โดยคง transaction, validation, same-origin และ real-DB tests ไว้

**ข้อสรุป:** เหมาะเป็นฐานสำหรับ candidate scheduler แต่ยังไม่ควรรับรองว่า “ครอบคลุมทุกอย่างและทันหนึ่งสัปดาห์” ก่อนปิดประเด็นด้านข้อมูลและ deployment เหล่านี้
