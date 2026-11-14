# ADR-001: Product scope — core CRUD gate แล้วตามด้วย thin candidate journey

**Status:** Proposed · **Source:** A (superset) + B (core-first, budget)

## Context
โจทย์ mandatory เป็น generic meeting CRUD (title, description, due date, status) แต่ส่วน App Flow มี wireframe 3 หน้าของ candidate scheduler ซึ่งไม่ได้เขียนว่า optional (ต่างจาก login ที่เขียน "optional") A ทำเต็ม superset; B ตัด candidate ออกจาก baseline (+10–16 ชม.)

## Decision
1. Core CRUD ต้องผ่าน gate G3 (deploy public) ก่อนเริ่มงาน candidate
2. จากนั้นทำ candidate journey แบบบาง: candidates, meeting fields (endAt, type, provider), feedback append-only
3. ไม่ทำ `COMPLETED`, `rating`, candidate admin/delete, multi-application

## Alternatives
- Generic CRUD อย่างเดียว (B) — เสี่ยงไม่ตรง wireframe
- Superset เต็มตั้งแต่ Day 1 (A) — เสี่ยง core ไม่เสร็จ

## Consequences
+ mandatory ปลอดภัยก่อน; wireframe ครบในรูปที่เล็กที่สุด · − schema migration สองรอบ (additive)

## Revisit trigger
ผู้ใช้ตอบ Q1 ว่า wireframe ไม่ใช่ acceptance → ตัดขั้น 2 ทิ้ง หรือ G3 เลยวัน 4 → ใช้ cut order
