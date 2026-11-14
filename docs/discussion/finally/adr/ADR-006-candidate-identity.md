# ADR-006: Candidate identity ด้วย ID

**Status:** Proposed · **Source:** B (แก้ A/C ที่ match ชื่อ)

## Context
A §9 match free-text name แบบ case-insensitive กับ candidate เดิม → คนชื่อซ้ำถูกรวม history/feedback

## Decision
Meeting อ้าง `candidateId` เสมอ; booking form ให้เลือกคนเดิม (autocomplete แสดงชื่อ + ตำแหน่ง + วันที่สร้าง) หรือกด "สร้างใหม่" แบบ explicit; ชื่อซ้ำได้; สร้าง candidate + meeting ใน transaction เดียว; candidate ลบไม่ได้

## Alternatives
match ชื่อ (A/C) · unique name constraint — ปฏิเสธเพราะชื่อซ้ำเป็นเรื่องจริง · email เป็น key — โจทย์ไม่มี field นี้

## Consequences
+ history ถูกต้อง · − UI เพิ่ม interaction "สร้างใหม่" เล็กน้อย

## Revisit trigger
ต้องรองรับคนเดียวสมัครหลายตำแหน่ง → เพิ่ม Application entity
