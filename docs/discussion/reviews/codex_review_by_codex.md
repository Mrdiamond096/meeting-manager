# Review: Codex — Approach and Solution (Self-review)

ผู้รีวิว: Codex · วันที่: 12 พฤศจิกายน 2026 · สถานะ: document review ก่อน implementation

ต้นฉบับ: [Codex architecture proposal](../AI-thinks/codex/ARCHITECTURE_PROPOSAL.md) ทั้ง 22 หัวข้อ เทียบกับ [assignment](../../requirement/20251009_Software%20Engineer_WebApp_Interview.md) และ Master Prompt

นี่เป็น **self-review ไม่ใช่ independent review** การใช้เกณฑ์เดียวกันช่วยให้เปรียบเทียบได้ แต่ไม่ลบอคติของผู้เขียน ไม่มี implementation/benchmark ให้ยืนยัน effort, performance หรือความปลอดภัย ระดับ **สูง** = ควรแก้ก่อนรับเป็น baseline; **กลาง** = design/contract ที่ควรตัดสินใจ; **ต่ำ** = ลดภาระหรือปรับเอกสาร

## ความเห็นโดยรวม

**ข้อเสนอมีวินัยด้าน delivery และ error semantics แต่ core-first baseline เสี่ยงตอบ wireframes ไม่ครบมากที่สุดในสามเอกสาร** ความโปร่งใสเรื่องสิ่งที่ไม่ทำเป็นข้อดี แต่การเปิดเผยข้อจำกัดไม่เท่ากับได้รับอนุญาตให้ข้าม acceptance criteria

เหมาะถ้า evaluator ยืนยัน generic Meeting CRUD เป็นขอบเขตหลัก หากต้องทำ candidate scheduler ตาม wireframes ควรใช้ architecture หลักนี้ต่อได้ แต่ต้องเลื่อน candidate extension เข้าสู่ baseline และปรับแผน/งบเวลา ไม่ควรถือว่า technical depth ทดแทน product coverage ได้

## ข้อดีที่ควรเก็บไว้

- **แยก requirement/assumption/recommendation ชัด:** §3–4 ไม่ประกาศว่า wireframes เป็นโบนัสโดยไม่มีหลักฐาน และระบุสิ่งที่ baseline ยังไม่ทำตรงไปตรงมา
- **เทียบสาม approach บน product scope เดียวกัน:** §5–6 ทำให้เห็น cost ของ engineering capability มากกว่ารวมงานคนละขอบเขตแล้วเทียบวันอย่างเดียว
- **API failure contract ละเอียด:** §10 แยก malformed/semantic errors, patch omission/null, stale update/delete, missing resource และ pagination boundaries
- **ไม่อ้าง exactly-once เกินจริง:** §10 และ §11 ยอมรับ lost POST response ว่าอาจบันทึกสำเร็จแล้ว ไม่ retry write อัตโนมัติและไม่ใช้ title uniqueness ป้องกัน duplicate
- **release strategy มีรายละเอียดที่ใช้งานได้:** §15 แยก migration job, runtime/release dependencies, data volume, backup และ image rollback พร้อมแยก health status จาก traffic removal
- **testing ตรวจ behavior เสี่ยง:** §14 เลือก real-DB integration, concurrency และหนึ่ง browser flow โดยไม่กำหนดจำนวน test เพื่อให้ดูมาก
- **budget และ scope มี contingency:** §17 บอก 34 ชั่วโมงงาน + 6 ชั่วโมง reserve และใช้ deployment gate เร็ว เป็นรูปแบบที่ตรวจสอบการใช้เวลาได้
- **candidate extension ไม่ merge ตามชื่อ:** §9–10 ใช้ stable ID และแยกสร้างใหม่จากเลือกเดิม เหมาะกับ history มากกว่า name matching

## ประเมิน A / B / C

| Approach | ข้อดี | ข้อเสีย | เงื่อนไขการเลือก |
|---|---|---|---|
| A — Minimal | product scope เดียวกับ B, direct SQL และชิ้นส่วนน้อยกว่า; ยังมีสาม runtime services | ใช้ PostgreSQL และแยก web/API ตั้งแต่ต้น จึงไม่ใช่ absolute simplest หาก evaluator ยอมรับ SQLite/API เดียว; validation/error handling ยังต้องใช้เวลา | เหมาะเมื่อเลือก conservative container interpretation และมีเวลาน้อย |
| B — Balanced | ขอบเขต HTTP/service/persistence พอดี, shared contracts, migration/test/release strategy มีเหตุผล | dependency/build configuration และความละเอียดของ contracts ยังมากสำหรับหนึ่ง entity; ไม่ได้แก้ candidate product gap ด้วยตัวเอง | เหมาะเมื่อ scope ได้ข้อยุติและทีมคุ้นกับ stack |
| C — Extensible | ยังคง modular monolith ไม่จำเป็นต้องมี cache/queue; อธิบาย overhead ชัด | 52–72 ชั่วโมงมาจาก judgment ไม่มี task breakdown; staging/observability/ports บางส่วนยังไม่เชื่อมกับ growth scenario ที่เป็นรูปธรรม | เลือกเมื่อมี requirement เพิ่มจริง พร้อมแจก effort เพิ่มเติม |

ไม่ควรเลือก B แค่เพราะมีคำว่า production-minded ทุก approach ยังต้องมี input validation, persistence และ deployment ที่ถูกต้อง ความแตกต่างคือจุดที่ลงทุนเพื่อดูแลงานต่อ ไม่ใช่ A ยอมให้ขาด correctness ได้

## ประเด็นหลักที่ควรแก้

### CX-01 — Core-first อาจไม่ผ่าน non-login wireframes [สูง]

**หลักฐาน:** §4 baseline ไม่ทำ candidate cards, interval/type, candidate summary, feedback และ history; §21 ขอ approval ภายใต้ scope decision

โจทย์ระบุเฉพาะ login ว่า optional ส่วน dashboard/booking/summary ไม่ได้ระบุเช่นนั้น การส่ง generic CRUD อาจถูกมองว่าพลาด product intent ถึงแม้ README จะอธิบายไว้แล้ว ข้อเสนอนี้รับรู้ความเสี่ยงแต่ยังไม่ทำให้เงื่อนไขผ่านหายไป

**แก้:** ก่อน implementation กำหนด acceptance checklist ที่ผู้ใช้/evaluator ยอมรับ หากติดต่อไม่ได้ แนะนำ baseline ที่รองรับ thin candidate journey มากขึ้น เช่น stable candidate ID, role, start/end, type และ real summary แล้วตัด design exports/auth/deployment automation ก่อน อย่างไรก็ดีอย่าเรียกชุดนี้ว่า complete wireframes หากยังไม่มี persisted feedback/notes/history ที่ตกลงไว้

### CX-02 — Candidate extension ยังไม่เป็น implementation-ready contract [กลางถึงสูงเมื่อเลือก extension]

**หลักฐาน:** §9 นิยาม Candidate/Feedback; §10 conditional endpoints มี candidate details, meetings และ feedback แต่ยังไม่กำหนด collection/selection endpoint หรือ final booking body และบอกให้ finalize ก่อนทำ

การระบุว่ามี paginated candidate selector ยังไม่พอให้ frontend/backend ทำงานตรงกัน ต้องรู้วิธีค้น/เลือกคนเดิม สร้างคนใหม่ ระบุ role และทำ transaction เมื่อ booking ล้มเหลว การให้ feedback textarea กลายเป็น append-only entries ก็เป็น product assumption ที่ต้องยืนยัน

**แก้:** ถ้ารับ candidate scope ให้ระบุ create/existing-candidate request แบบไม่กำกวม, selector response/pagination, profile/history schema และ feedback semantics พร้อม transaction tests อย่าเริ่มจาก placeholder แล้วให้แต่ละฝั่งเดา contract

### CX-03 — งบเวลาอาจมอง tooling และ timezone ถูกเกินไป [กลาง]

**หลักฐาน:** §17 วัน 1 รวม scope, versions, workspace, schema, Compose และ reachable deployment ใน 5 ชั่วโมง; วัน 3 รวม CRUD UI กับ date conversion ใน 6 ชั่วโมง; §9 ต้องจัดการ DST ambiguity ทั้งที่ stack ระบุ native controls โดยหลัก

แผนเหมาะกับผู้ที่มี boilerplate/hosting พร้อมแล้ว แต่มีความเสี่ยงหากต้องตั้ง workspaces, compiled contracts, proxy/TLS และ fixtures ใหม่ทั้งหมด การมี 6 ชั่วโมง reserve เป็นการกันเวลา ไม่ใช่หลักฐานว่า estimate แม่น และ 10–16 ชั่วโมงสำหรับ candidate extension ยังไม่ได้แจก task ย่อยพอ

**แก้:** ทำ deployment/workspace spike ในชั่วโมงแรก ระบุ prerequisite ว่าพร้อมจริงหรือไม่ แจก effort ของ extension และ date conversion ให้ชัด ใช้ library/helper ที่ทดสอบแล้วถ้า browser-zone DST อยู่ใน acceptance scope; หาก scope เป็นบริษัท timezone เดียวให้บอกอย่างชัดเจนและไม่สร้าง UI เลือก offset โดยไม่มีความจำเป็น

### CX-04 — Upcoming filter ของ extension ตัดนัดที่กำลังดำเนินอยู่ [กลาง]

**หลักฐาน:** §10 ใช้ `dueDate >= serverNow` และ pending/confirmed ขณะที่ extension มี endAt และ wireframe ใช้คำว่า Current Meetups

ถ้าเปิดนัด 10:00–11:00 ตอน 10:30 รายการนี้จะหายจาก Upcoming ทั้งที่ยังดำเนินอยู่ อาจตรงความหมาย Upcoming แบบเริ่มในอนาคต แต่ไม่แน่ว่าตรง Current Meetups ไม่ควรเรียกเป็นบั๊กแน่นอนก่อนตกลง semantics

**แก้:** แยก Upcoming = start >= now กับ Ongoing/Current = start <= now < end หรือกำหนด current list ให้ end > now; ระบุ fallback สำหรับ generic record ที่ไม่มี endAt และใช้ขอบเขตเวลาเดียวกันใน count/page

## ข้อเสียและรายละเอียดรอง

| ID / ระดับ | หลักฐาน | ผลกระทบและข้อเสนอ |
|---|---|---|
| CX-05 / กลาง | §9 กำหนดปี 2000–2100 และห้าม create เป็น CANCELLED | เป็น product policy เพิ่มเอง แม้ติดป้าย recommendation/assumption แล้ว; ตัดกฎที่ไม่ช่วย acceptance หรือยืนยันก่อน อย่าปฏิเสธ historical/import records โดยไม่จำเป็น |
| CX-06 / กลาง | §15 เลือก VPS + database container เป็น default | ลดความกำกวมโจทย์ แต่รับภาระ host/DNS/TLS/security/backup เอง; เทียบกับ managed deployment ตามความคุ้นเคยจริง ไม่มี topology ที่ชนะด้านเวลาสำหรับทุกคน |
| CX-07 / ต่ำถึงกลาง | §10 ใช้ short repeatable-read transaction สำหรับ count/page | ถูกต้องสำหรับ snapshot เดียวตาม [PostgreSQL isolation](https://www.postgresql.org/docs/current/transaction-iso.html) แต่เพิ่ม transaction/pool handling และไม่ได้แก้การเลื่อนหน้าข้าม request; ทำเมื่อ cost ต่ำจริง หรือยอมรับ metadata ที่อาจเปลี่ยนใน demo พร้อมระบุข้อจำกัด |
| CX-08 / ต่ำ | §10 version อยู่ใน PATCH body และ DELETE query | เป็น contract ที่ใช้ได้ ไม่จำเป็นต้องเป็น ETag เสมอไป; ถ้าเปลี่ยนในอนาคตให้เลือกแนวทางเดียวและอธิบาย compatibility อย่า implement สองระบบในสัปดาห์เดียว |
| CX-09 / ต่ำถึงกลาง | §7 shared contracts + router + query library + migration tool; §12 workspace build wiring | แม้ไม่ใช้ ORM แต่ configuration ยังไม่ฟรี; ทำ shared package เท่าที่จำเป็นและทดสอบ production build ตั้งแต่ต้น ไม่ประเมิน raw SQL ว่า dependencies น้อยจึงง่ายกว่าเสมอ |
| CX-10 / ต่ำ | เอกสาร 725 บรรทัด ประมาณ 11,600 คำ พร้อม provenance note | เหมาะกับ deep review แต่ยาวเกิน reviewer entry point; เพิ่ม one-page decision brief และย้ายประวัติการจัดไฟล์ออกจากเอกสารส่งสัมภาษณ์ โดยเก็บ audit ที่เกี่ยวข้องไว้แยก |

## ข้อแลกเปลี่ยนที่ยอมรับได้

Shared anonymous demo ไม่ใช่ข้อผิดพลาดโดยตัวมันเองเพราะ auth เป็นโบนัส เอกสารบอกชัดว่าไม่มี privacy และใช้ synthetic data แต่ถ้ากลายเป็นงาน candidate จริงต้องเพิ่ม server authorization/ownership ไม่ใช่แค่ login UI เช่นเดียวกัน offset pagination และ single-host downtime เป็นข้อจำกัดที่ยอมรับได้ใน demo หากไม่อ้าง scalability/availability เกินจริง

การใช้ `pg` กับหนึ่งตารางสมเหตุผล แต่ถ้าต้องทำ Candidates/Applications/Feedback ครบ อย่าล็อกใจว่า ORM คือ overengineering ควรเทียบ mapping/migration/test effort กับความคุ้นเคยของผู้พัฒนาใหม่ตาม scope ที่ตกลงแล้ว

## สิ่งที่แนะนำให้ทำต่อ

1. ยืนยัน wireframe acceptance; ถ้าจำเป็นให้ย้าย thin candidate flow เข้า baseline และคำนวณเวลาใหม่
2. ปิด contract ของ candidate selection/booking/history/feedback ก่อนแบ่งงาน frontend/backend
3. ตัด policy และ edge-case UI ที่ไม่มี acceptance need โดยคง server validation และข้อมูลเวลาที่ไม่กำกวม
4. ตรวจ prerequisite ของ host/workspace ด้วย spike แรก แล้วปรับแผน 40 ชั่วโมงตามข้อมูลจริง
5. คง migration job, atomic conditional writes, lost-response semantics และ behavior-based tests ซึ่งเป็นจุดแข็งของข้อเสนอนี้

**ข้อสรุป:** ใช้เป็นฐานด้าน delivery/API/reliability ได้ดี แต่ไม่ควรอนุมัติ product scope อัตโนมัติ ถ้า evaluator คาด candidate wireframes ข้อเสนอนี้ต้องเพิ่มความครอบคลุมก่อน ไม่ใช่เพียงเขียน README อธิบายการตัดงาน
