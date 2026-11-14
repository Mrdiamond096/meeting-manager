# ADR-005: Date/time contract

**Status:** Proposed · **Source:** B (ตัดส่วน DST)

## Context
โจทย์ใช้คำว่า "due date"; wireframe แสดงช่วงเวลา start–end A เปลี่ยนชื่อเป็น `startAt`; B คงชื่อ `dueDate`

## Decision
- API field `dueDate` = เวลาเริ่ม (instant) + `endAt` optional (> dueDate)
- Request: RFC 3339 พร้อม offset; ไม่มี offset/date-only → 400
- Storage `timestamptz`; response UTC `Z`; UI แปลงด้วย `Intl.DateTimeFormat` และแสดง timezone ของ browser
- ไม่ทำ UI เลือก offset ช่วง DST ซ้ำ (ระบุเป็น limitation)

## Alternatives
`startAt` (A) — ชื่อโดเมนดีกว่าแต่ผู้ตรวจ map กับโจทย์ยากกว่า · date-only — ไม่พอสำหรับ time picker

## Consequences
+ ตรงคำโจทย์; ไม่มีความกำกวม timezone · − ชื่อ `dueDate` สำหรับ "เวลาเริ่มประชุม" ต้องอธิบายใน README

## Revisit trigger
ผู้ใช้ตอบว่า due date เป็นวันที่ล้วน (Q ใน summary ของ A ข้อ 3)
