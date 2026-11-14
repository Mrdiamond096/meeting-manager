# ADR-011: Next.js ↔ Express communication — same-origin proxy, no BFF

**Status:** Accepted (14 พ.ย. 2026) · **Source:** [proposal §1](../api-security-observability-proposal.md)

## Context
Frontend เป็น Next.js (ADR-010), backend เป็น Express ตามโจทย์ รันแบบ local ด้วย Compose (ADR-008) มี auth แบบ session cookie ที่ Express ออกเอง (ADR-009) ไม่มี third-party API หรือ token ที่ต้องซ่อน

## Decision
- Browser เรียก `/api/v1/...` แบบ relative เท่านั้น → Next `rewrites` → `http://api:3000` (internal network)
- Next.js ทำหน้าที่ render + proxy เท่านั้น: **ไม่มี Route Handler / Server Action ที่แตะข้อมูลหรือ auth**
- Data fetching ฝั่ง client ด้วย TanStack Query ผ่าน API client ไฟล์เดียว (`src/lib/api.ts`) ที่แปลง error เป็น `ApiError { status, code, message, requestId }`
- `API_URL` เป็น build arg (rewrites ถูก serialize ตอน build); ไม่มี `NEXT_PUBLIC_*` ที่เป็น URL/secret
- Express ตั้ง `trust proxy = 1`
- Session cookie ผ่าน proxy แบบ first-party → ไม่ต้องใช้ CORS

## Alternatives
| ทางเลือก | เหตุผลที่ไม่เลือก |
|---|---|
| Browser → Express ตรง | ต้อง expose port api + CORS + cookie ข้าม origin |
| BFF (Route Handlers) | contract ซ้ำสองชั้น, logic รั่วเข้า Next, ไม่มี token ที่ต้องซ่อน |
| Server Components fetch + client mutation | สอง data path, ต้องส่ง cookie ต่อเอง, ไม่มีความต้องการ SEO/SSR |

## Consequences
+ api/db ไม่ถูก expose, ไม่มี CORS, ไม่มีโค้ด proxy · − ต้องทดสอบพฤติกรรม rewrite จริง (DELETE + query, body limit, `Set-Cookie`, `X-Forwarded-For`) ผ่าน `:8080` ใน smoke test

## Revisit trigger
มี third-party token, ต้อง aggregate หลาย service, หรือ api ย้ายไปคนละ origin → BFF เฉพาะ endpoint ที่ต้องการ
