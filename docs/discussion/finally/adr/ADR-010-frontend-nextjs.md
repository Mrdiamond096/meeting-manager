# ADR-010: Frontend ใช้ Next.js (แทน React + Vite + nginx)

**Status:** Accepted (ผู้ใช้กำหนด 13 พ.ย. 2026) · **Supersedes:** ส่วน frontend ของ ADR-002 และ nginx ใน ADR-008

## Context
ผู้ใช้กำหนด stack: Frontend = Next.js, Backend = Node.js TypeScript, DB = PostgreSQL, Deploy = Docker container, Git = GitHub, Flow/Design = Figma
Next.js เป็น React framework จึงยังตรงข้อกำหนด "React or Vue" ของโจทย์

## Decision
- Next.js 15 App Router + TypeScript, `output: 'standalone'` รันใน container `node:24-alpine` (non-root)
- **Same-origin คงเดิม:** `next.config` rewrite `/api/:path*` → `${API_URL}/api/:path*` (default `http://api:3000`) แทน nginx — browser เรียก `/api` เท่านั้น ไม่มี CORS
- หน้า data-driven เป็น client components + TanStack Query (ข้อมูลเปลี่ยนบ่อย, ไม่ต้อง SEO); ไม่ใช้ Server Actions/route handlers เป็น backend — Express ยังเป็น REST API เดียว
- Tailwind v4 + shadcn/ui tokens จาก `docs/design/tokens/globals.css`
- Flow และหน้าจอออกแบบใน Figma (ใช้ `tokens.json` สร้าง Variables) — ไฟล์ Figma เป็น deliverable แยก

## Alternatives
- Vite SPA + nginx (เดิม) — เบากว่า แต่ไม่ตรงที่ผู้ใช้กำหนด
- ใช้ Next route handlers แทน Express — ขัดกับโจทย์ (Backend ต้องเป็น Express/FastAPI/Flask) และทำ backend ซ้ำสองที่

## Consequences
+ deep link/SPA fallback ไม่ต้องตั้ง nginx · − image ใหญ่กว่า nginx static; `API_URL` ของ rewrite ถูกอ่านตอน build → ต้องส่งเป็น build arg

## Revisit trigger
ต้องการ SSR ที่ fetch API ฝั่ง server → ใช้ `API_URL` ภายในกับ server fetch
