# ADR-003: Data access — Drizzle ORM + committed SQL migrations

**Status:** Proposed · **Source:** A (Drizzle) vs B (`pg` + node-pg-migrate)

## Context
ข้อมูลมี 3 ตาราง มี relation และ transaction (candidate + meeting) ทั้งสองทางเลือกต้องมี constraint, migration และทดสอบกับ DB จริงเหมือนกัน (B ชี้ว่าไม่มีทางไหนชนะโดยอัตโนมัติ)

## Decision
Drizzle ORM สำหรับ schema/query; `drizzle-kit generate` สร้าง SQL migration ที่ commit ลง repo; API รัน migrate on boot (replica เดียว); CHECK constraints เขียนใน schema

## Alternatives
- `pg` + raw SQL (B): โปร่งใสกว่า แต่ต้อง map row↔DTO และ type ด้วยมือ
- Prisma: engine/binary หนักกว่าใน alpine image
- SQLite fallback แบบ config flag: ปฏิเสธ — schema แยก dialect

## Consequences
+ type ของ row มาจาก schema เดียว · − ต้องตรวจ SQL ที่ generate ก่อน commit; ไม่อ้างว่า "เปลี่ยน DB ได้ฟรี"

## Revisit trigger
query ซับซ้อนที่ Drizzle เขียนยาก → ใช้ `sql` template เฉพาะจุด
