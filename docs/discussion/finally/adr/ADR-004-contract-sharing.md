# ADR-004: Contract sharing ข้าม frontend/backend submodule

**Status:** Proposed · **Source:** New (ทุกข้อเสนอไม่ได้พิจารณา layout จริง)

## Context
A/C เสนอ npm-workspaces + `packages/shared` Zod แต่ repo จริงเป็น umbrella + 2 git submodule แยก repo การแชร์ package ต้อง publish (npm/GitHub Packages), git dependency, หรือรวมเป็น monorepo

## Decision
Backend Zod schema เป็น source of truth และ README backend มีตาราง contract; frontend มี `src/api/types.ts` และ form schema ของตัวเอง (เขียนมือ); drift จับด้วย Playwright smoke ใน CI ของ umbrella

## Alternatives
- รวมเป็น monorepo + shared package — ดีที่สุดเชิงเทคนิค แต่เปลี่ยนโครงที่ผู้ใช้ตั้งไว้ (Q8)
- OpenAPI จาก Zod + `openapi-typescript` generate ฝั่ง FE — เพิ่ม tooling 2 ตัวสำหรับ ~6 type
- Publish shared package — ต้อง registry + versioning

## Consequences
+ ไม่เพิ่ม tooling/infra · − type ซ้ำสองที่ ต้องแก้คู่กัน

## Revisit trigger
ผู้ใช้ยอมรวม monorepo (Q8) หรือ type ที่ซ้ำเกิน ~10 ตัว → generate จาก OpenAPI
