# ADR-007: Optimistic concurrency ทุก write

**Status:** Proposed · **Source:** B (A ทำเฉพาะ PATCH)

## Context
A ใช้ `version` บน PATCH แต่ไม่ระบุสำหรับ cancel/DELETE ทำให้ลบ/ยกเลิกทับการแก้ไขล่าสุดได้

## Decision
`version` integer เริ่ม 1; PATCH (body), cancel (body), DELETE (`?version=`) ต้องส่ง version; ใช้ `UPDATE/DELETE ... WHERE id=? AND version=?` — 0 rows + มี id → 409, ไม่มี id → 404; UI แสดงข้อความและ refetch

## Alternatives
Last-writer-wins (ประกาศใน README) — ง่ายกว่าแต่เสีย signal ด้าน correctness · ETag/If-Match — มาตรฐานกว่าแต่ซับซ้อนกับ fetch client เกินจำเป็น

## Consequences
+ ทดสอบสองแท็บได้ชัด · − ทุก write ต้องถือ version ใน UI state

## Revisit trigger
เพิ่ม client ภายนอก → พิจารณา ETag
