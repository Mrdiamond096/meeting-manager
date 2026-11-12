# Architecture Reviews — Summary by Codex

ผู้รีวิว: Codex · วันที่: 12 พฤศจิกายน 2026

## เอกสารรีวิวแยกตาม AI

| ข้อเสนอที่ตรวจ | เอกสารรีวิว | สถานะที่แนะนำ |
|---|---|---|
| Claude | [claude_review_by_codex.md](./claude_review_by_codex.md) | ใช้ B เป็นฐานได้เมื่อแก้ identity, runtime, deployment และ budget |
| Cursor | [cursor_review_by_codex.md](./cursor_review_by_codex.md) | ใช้ B เป็นฐานได้เมื่อแก้ประเด็นร่วมและรวม schema/guest/validation ให้ตรงกัน |
| Codex | [codex_review_by_codex.md](./codex_review_by_codex.md) | ใช้ B เป็นฐานด้าน delivery ได้ แต่ต้องยืนยันว่าการลด candidate scope ยอมรับได้; เป็น self-review |

ไฟล์ลงท้าย `_by_codex` ระบุผู้รีวิว เพื่อไม่ให้สับสนกับเอกสารรีวิวของผู้อื่นที่มีอยู่ในโฟลเดอร์เดียวกัน ไม่มีการแก้ไขข้อเสนอต้นฉบับหรือไฟล์รีวิวเดิม

## ขอบเขตและวิธีประเมิน

อ่าน Claude proposal, Cursor index พร้อมเนื้อหาย่อย 23 ไฟล์ และ Codex proposal โดยเทียบกับ [assignment](../../requirement/20251009_Software%20Engineer_WebApp_Interview.md) และ Master Prompt แยกสิ่งที่โจทย์สั่งจริงออกจาก wireframe expectations และ engineering assumptions

ประเมิน requirement coverage, ความสอดคล้องของ data/API/UX, ความเป็นไปได้ในหนึ่งสัปดาห์, deployment, testing/security และเหตุผลของ A/B/C ตรวจข้อมูลที่เปลี่ยนตามเวลาเฉพาะประเด็นสำคัญกับเอกสารทางการ ไม่มี implementation ให้รันทดสอบ จึงไม่ให้คะแนน performance/security จากการมีชื่อ library หรือจำนวน layer และไม่ให้คะแนนตัวเลขที่ดูแม่นเกินหลักฐาน

ชื่อ AI อ้างตามชื่อโฟลเดอร์ ไม่ใช่การพิสูจน์ต้นกำเนิดไฟล์ การรีวิว Codex เป็น self-review จึงไม่ถือเป็น independent validation

## เปรียบเทียบแนวทางที่แต่ละรายแนะนำ

ตารางนี้อธิบาย **สิ่งที่เสนอจะทำ** ไม่ใช่สิ่งที่พัฒนา/ทดสอบสำเร็จแล้ว

| ประเด็น | Claude | Cursor | Codex |
|---|---|---|---|
| ขอบเขตหลัก | Candidate scheduler แบบ superset | Candidate scheduler แบบ superset | Generic CRUD ก่อน; candidate เป็น conditional extension |
| Frontend/backend | React/TS/Vite + Express/TS | React/TS/Vite + Express/TS | React/TS/Vite + Express/TS |
| Persistence | PostgreSQL + Drizzle | PostgreSQL + Drizzle | PostgreSQL + pg + migration tool |
| Candidate/history | อยู่ใน baseline; identity matching เสี่ยง | อยู่ใน baseline; identity/uniqueness ยังคลุมเครือ | ไม่อยู่ baseline; extension ใช้ stable ID |
| Due-date semantics | map เป็น startAt พร้อม endAt | map เป็น startAt พร้อม endAt | คงชื่อ dueDate และเป็น instant; endAt ใน extension |
| Deployment | Render primary; managed DB | Render primary; managed DB | VPS + Compose primary; managed DB เป็นทางเลือก |
| Auth | โบนัสปลายสัปดาห์ | โบนัสปลายสัปดาห์; guest policy ไม่ตรงกันทุกหัวข้อ | ไม่อยู่ baseline; private data ต้อง auth/authorization |
| Testing | integration-heavy แต่ target ค่อนข้างมาก | เช่นเดียวกับ Claude พร้อม component/MSW | risk-based API tests + browser smoke จำกัด |
| จุดแข็ง | Product journey ครบกว่าและ boundaries ชัด | Product journey และเอกสารแยกอ่านง่าย | Delivery gates, failure semantics, migration/recovery และขอบเขตที่เปิดเผย |
| ความเสี่ยงใหญ่ | ทำมากเกิน budget และ identity ผิดคน | ประเด็นร่วมกับ Claude บวก contract ต่างไฟล์ไม่ตรงกัน | ทำไม่ครบ product intent หาก wireframes เป็น acceptance criteria |

ไม่มีหลักฐานว่า ORM หนึ่งตัว, ภาษาเดียวกันทั้งระบบ หรือจำนวน tests มากกว่า จะทำให้ข้อเสนอชนะโดยอัตโนมัติ เลือกจาก product scope, familiarity, พฤติกรรมที่ต้องพิสูจน์ และ effort รวมการ deploy จริง

## ประเด็นร่วมที่ควรตัดสินใจก่อนเลือก solution

### 1. Acceptance scope มีผลมากกว่า framework

โจทย์มี generic CRUD แต่ wireframes ของ candidate dashboard/booking/summary ไม่ได้ระบุว่า optional เหมือนหน้า login จึงยังฟันธงไม่ได้ว่าควรตัดทั้งหมด หรือจำเป็นต้องเพิ่มทุก field/history ภายใน budget เดิม

- ถ้า evaluator ต้องการ **generic CRUD เป็นหลัก**: โครง Codex B เหมาะกับ budget กว่า แต่ลด policy/tooling ที่ไม่จำเป็นได้อีก
- ถ้าต้องการ **candidate wireframes ครบ**: product intent ของ Claude/Cursor ใกล้กว่า แต่ต้องแก้ candidate identity และปรับ effort/bonus ไม่ใช้คำว่า full coverage จนกว่าจะมี acceptance checklist
- ถ้ายังไม่ทราบ: เขียน checklist ของสิ่งที่จะส่งและสิ่งที่ตัดเป็นข้อเสนอเพื่อยืนยัน อย่าคิดว่าการบอกข้อจำกัดใน README เท่ากับได้รับอนุญาตให้ข้ามส่วนที่ผู้ตรวจคาดหวัง

### 2. Candidate identity เป็นเรื่อง correctness

Claude/Cursor เสนอจับคู่ชื่อแบบไม่สนตัวพิมพ์ ซึ่งอาจรวมประวัติและ feedback ของคนละคน ควรใช้ ID สำหรับคนเดิมและ explicit creation สำหรับคนใหม่ การเลือกนี้สำคัญกว่า autocomplete หรือ ORM ที่ใช้ และไม่จำเป็นต้องทำ candidate administration ทั้งระบบ

### 3. Deployment ต้องเป็น topology ที่ทดสอบได้จริง

Claude/Cursor ต้องปรับ Node 20 ซึ่ง EOL แล้ว ณ วันรีวิว และอธิบาย Render routing/plan/backup ให้ตรงความสามารถปัจจุบัน ส่วน Codex ต้องคิดต้นทุน host/DNS/TLS/operations ของ VPS ตามประสบการณ์จริง ไม่ควรประกาศว่า Compose เท่ากับ deploy เสร็จ หรือ seed เท่ากับ backup ทั้งสามรายต้องยืนยันว่าการใช้ managed DB ยอมรับได้ตามข้อกำหนด containerized database หรือไม่

อ้างอิงที่ตรวจ ณ วันรีวิว: [Node.js releases](https://nodejs.org/en/about/previous-releases), [Render Free limitations](https://render.com/docs/free) การประเมินนี้อิงวันที่ปัจจุบัน ไม่ถือว่าเวอร์ชันที่เหมาะในปี 2025 ต้องเหมาะต่อไปตลอด

### 4. เปรียบเทียบ effort บนงานเท่ากัน

Claude/Cursor เปลี่ยนทั้ง product scope และ engineering depth ระหว่าง A/B/C จึงยังเปรียบเทียบไม่เป็นธรรม ส่วน Codex ทำ scope comparison ชัดกว่าแต่ effort ก็ยังเป็น judgment ต้องมี spike และปรับตามข้อเท็จจริง แยก core, candidate, bonus, deployment และ contingency ให้เห็นเป็นชั่วโมง อย่าใช้ auth เป็นงานแถมวัน deploy โดยไม่กันเวลาทดสอบ

### 5. ความเหมือนของเอกสารไม่ใช่หลักฐานยืนยันสองทาง

Claude/Cursor มีเนื้อหาจำนวนมากตรงกันหรือใกล้กัน จึงอาจมี blind spots เดียวกัน เช่น name matching, test count และ deploy plan ไม่อนุมานว่าใครอ้างอิงใคร แต่ไม่ควรนับความเห็นที่เหมือนกันเป็น independent consensus ส่วน Codex เป็นผลงานผู้รีวิวเอง จึงต้องเปิดเผย self-review และให้ตรวจข้ามอีกครั้งเมื่อตกลง solution

## แนวทางที่แนะนำให้นำไปตัดสินใจ

ใช้ modular monolith แบบ B เป็นจุดเริ่มต้น: React/Vue ที่ผู้พัฒนาถนัด + backend ที่โจทย์อนุญาต + relational persistence + same-origin API + Docker และ deployment ที่ตรวจได้ ไม่จำเป็นต้องรวม dependency ทุกตัวจากทุกข้อเสนอ

สิ่งที่ควรหยิบมารวมในการตัดสินใจครั้งถัดไป:

1. ใช้ product journey ของ Claude/Cursor เมื่อ wireframes อยู่ใน scope แต่แก้ candidate selection เป็น ID และตัด metadata เช่น rating ที่โจทย์ไม่สั่ง
2. ใช้ acceptance matrix, early deployment, conditional writes และ recovery semantics ของ Codex โดยไม่ยอมให้ความละเอียดเหล่านี้กลบ product gaps
3. เลือก Drizzle หรือ pg ตาม relational scope และความคุ้นเคย; ทั้งคู่ต้องมี constraints, migrations และ real-DB verification
4. เลื่อน auth, design exports, broad filters และ deployment automation ออกก่อน หากจำเป็นต้องรักษา core/candidate acceptance และ buffer
5. ทำ prototype spike เรื่อง workspace + container + hosting ก่อนสัญญาว่าใช้เวลาเท่าไร แล้ว freeze schema/contract ที่ frontend/backend จะใช้ร่วมกัน

นี่เป็นข้อเสนอสำหรับ architecture discussion ไม่ได้อนุมัติให้เริ่ม implement เปลี่ยนข้อเสนอต้นฉบับ หรือ deploy ระบบแทนผู้ใช้

## แหล่งอ้างอิงสำหรับข้อสังเกตเฉพาะ

- [Claude proposal](../AI-thinks/claude/ARCHITECTURE_PROPOSAL.md)
- [Cursor proposal index](../AI-thinks/cursor/ARCHITECTURE_PROPOSAL.md) พร้อมเอกสารย่อยที่ลิงก์ในรีวิว
- [Codex proposal](../AI-thinks/codex/ARCHITECTURE_PROPOSAL.md)
- [Node.js release status](https://nodejs.org/en/about/previous-releases): runtime lifecycle
- [Render Free documentation](https://render.com/docs/free): private traffic, expiry และ backups
- [RFC 9457](https://www.rfc-editor.org/rfc/rfc9457.html): Problem Details ที่แทน RFC 7807; custom envelope ไม่ใช่มาตรฐานนี้โดยอัตโนมัติ
- [PostgreSQL transaction isolation](https://www.postgresql.org/docs/current/transaction-iso.html): ขอบเขตของ repeatable-read snapshot
- [TanStack Query pagination](https://tanstack.com/query/latest/docs/framework/react/guides/paginated-queries): API ของ keepPreviousData/placeholderData ต้องตรงเวอร์ชัน
