# ADR-003: Data access — Prisma ORM + committed SQL migrations

**Status:** Revised (เดิม Proposed: Drizzle) · **Source:** A (Drizzle) vs B (`pg` + node-pg-migrate) → เปลี่ยนเป็น Prisma ตามการตัดสินใจของผู้พัฒนา

## Context
ข้อมูลมี relation และ transaction (candidate + meeting) ทั้งสองทางเลือกเดิมต้องมี constraint, migration และทดสอบกับ DB จริงเหมือนกัน (B ชี้ว่าไม่มีทางไหนชนะโดยอัตโนมัติ)

ADR ฉบับแรกเลือก Drizzle และปฏิเสธ Prisma เพราะ "engine/binary หนักกว่าใน alpine image" ต่อมามีการเปลี่ยนเป็น Prisma ด้วยเหตุผล:
- ผู้พัฒนาคุ้นเคย Prisma มากกว่า ทำให้ดูแลและส่งต่อง่ายกว่า
- คาดว่าทีมใช้ Prisma อยู่แล้ว (ยังไม่ได้ยืนยันกับทีม — ถ้าไม่จริงให้ทบทวนตาม revisit trigger)
- ข้อกังวลเรื่อง engine หมดไป: Prisma 7 ใช้ driver adapter (`@prisma/adapter-pg`) ไม่มี query engine แบบ Rust binary และ build `node:24-alpine` ผ่านจริง (ตรวจแล้วใน PR ที่เปลี่ยน)

## Decision
Prisma 7 (`prisma-client` generator + `@prisma/adapter-pg`) สำหรับ schema/query; `prisma migrate` สร้าง SQL migration ที่ commit ลง repo (`prisma/migrations`); migration รันด้วย `prisma migrate deploy` ใน container `CMD` ก่อน start (ไม่รันใน process ของ API); CHECK constraints และ expression index (`lower(name)`) เขียนต่อท้ายใน migration SQL เพราะ `schema.prisma` ไม่รองรับ; constants แบบ enum เก็บใน `src/db/constants.ts` (คอลัมน์เป็น `varchar` + CHECK ไม่ใช้ DB enum); Prisma client ที่ generate อยู่ที่ `src/generated/prisma` (gitignored)

## Alternatives
- Drizzle + drizzle-kit (ตัวเลือกเดิมของ ADR นี้): schema เป็น TypeScript และเขียน CHECK ได้ใน schema โดยตรง แต่ผู้พัฒนาไม่คุ้นและไม่ตรงกับที่ทีมน่าจะใช้
- `pg` + raw SQL (B): โปร่งใสกว่า แต่ต้อง map row↔DTO และ type ด้วยมือ
- SQLite fallback แบบ config flag: ปฏิเสธ — provider/schema แยก dialect

## Consequences
+ type ของ row มาจาก schema เดียว · + ทีมที่ใช้ Prisma อ่าน/ต่อยอดง่าย
− CHECK constraint และ expression index อยู่นอก `schema.prisma` ต้องดูแลใน migration SQL และระวัง drift (`prisma migrate diff` ตรวจได้ แต่ไม่เห็น CHECK)
− `contains` ไม่ escape `%` `_` `\` ต้อง escape เองใน repository (มี test คุมไว้)
− row lock (`FOR KEY SHARE` / `FOR UPDATE`) ต้องใช้ tagged `$queryRaw`
− ต้องตรวจ SQL ที่ generate ก่อน commit; ไม่อ้างว่า "เปลี่ยน DB ได้ฟรี"

## Revisit trigger
ทีมยืนยันว่าไม่ได้ใช้ Prisma · query ซับซ้อนที่ Prisma เขียนยาก → ใช้ tagged `$queryRaw` เฉพาะจุด หรือพิจารณา Drizzle/ raw SQL อีกครั้ง
