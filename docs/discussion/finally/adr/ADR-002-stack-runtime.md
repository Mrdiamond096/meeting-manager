# ADR-002: Stack และ runtime

**Status:** Proposed · **Source:** A, B (ตรงกัน), repo ที่มีอยู่

## Context
ทุกข้อเสนอเลือก React + Express + PostgreSQL; repo มี Express 5.1/TS, React 18/Vite 5 (JS), postgres:16-alpine อยู่แล้ว A/C ใช้ Node 20 ซึ่งหมด support เม.ย. 2026

## Decision
- Frontend: React 18 + **TypeScript** (แปลงจาก JS) + Vite + React Router + TanStack Query + React Hook Form + Zod + Tailwind v4 + shadcn/ui (ตาม `docs/design/`)
- Backend: Express 5 + TypeScript + Zod + helmet
- DB: PostgreSQL 16
- Runtime: **Node 24 LTS** pin ใน `.nvmrc`, `engines`, Dockerfile base, CI, `@types/node`

## Alternatives
Vue, FastAPI (อนุญาตแต่ทิ้งโค้ดที่มี) · Node 22 (maintenance LTS ถึง เม.ย. 2027 — ใช้ได้ถ้า dependency มีปัญหากับ 24)

## Consequences
+ ไม่ต้อง rewrite; type-safe ทั้งสองฝั่ง · − ต้องแปลง FE เป็น TS (เล็ก เพราะมีแค่ App.jsx)

## Revisit trigger
dependency หลักไม่รองรับ Node 24 → ถอยไป 22
