# ADR-013: Security baseline

**Status:** Accepted (14 พ.ย. 2026) · **Source:** [proposal §3](../api-security-observability-proposal.md), ADR-009

## Decision
**API (Express)**
- Zod `.strict()` ทุก body/query/params; UUID ใน path ตรวจก่อนถึง DB; Prisma parameterized (raw SQL ผ่าน tagged `$queryRaw` เท่านั้น; ห้าม `$queryRawUnsafe` กับ input)
- Error middleware เดียว: shape `{ error: { code, message, details?, requestId } }`; 500 ไม่มี stack/SQL
- `helmet()`, ปิด `x-powered-by`, `express.json({ limit: '100kb' })`, pg `statement_timeout` 5s
- ไม่ติดตั้ง CORS (same-origin, ADR-011)
- Auth/session/CSRF ตาม ADR-009 (httpOnly SameSite=Lax cookie + ตรวจ `Origin` บน non-GET)
- **Rate limits** (memory store, instance เดียว, ปิดได้ด้วย `RATE_LIMIT_ENABLED=false` ใน test):

| กลุ่ม | Limit | Key |
|---|---|---|
| `POST /auth/login` | 5 / 15 นาที | IP + email |
| `POST /auth/otp/verify` | 5 ครั้งต่อ challenge แล้ว invalidate | challenge id |
| `POST /auth/register` | 3 / ชม. | IP |
| `POST /auth/password/forgot` | 3 / ชม. | IP + email |
| Write (meetings/candidates/feedback) | 60 / นาที | userId |
| Read | ไม่จำกัด | — |

- ไม่ทำ account lockout (เสี่ยงถูกล็อกโดยผู้อื่น)

**Web (Next.js)**
- **Nonce-based CSP** ใน `middleware.ts`: nonce ใหม่ทุก request, `default-src 'self'; script-src 'self' 'nonce-{n}' 'strict-dynamic'; style-src 'self' 'nonce-{n}'; img-src 'self' data:; font-src 'self'; connect-src 'self'; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'`; dev เพิ่ม `'unsafe-eval'` เฉพาะ `NODE_ENV=development`; ทุกหน้า dynamic rendering
- ถ้า inline style ของ library บางตัวถูกบล็อก → แก้ที่ต้นเหตุก่อน; ยอม `style-src 'unsafe-inline'` ได้เป็น fallback ที่บันทึกไว้ (ความเสี่ยงต่ำกว่า script)
- Headers: `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`, `Permissions-Policy: camera=(), microphone=(), geolocation=()`, `poweredByHeader: false`
- ห้าม `dangerouslySetInnerHTML`; ข้อความผู้ใช้แสดงแบบ plain text
- `middleware.ts` redirect ไป `/login` เพื่อ UX เท่านั้น — การบังคับสิทธิ์อยู่ที่ Express

**Supply chain / config**
- เวอร์ชัน dependency pin แน่นอน, `npm audit --audit-level=high` ใน CI, Dependabot (npm, docker, github-actions)
- `.env` ไม่อยู่ใน git; mock OTP code อยู่ใน `.env.example`; container non-root; prod compose ไม่ publish port api/db

## Accepted risks
- Mock OTP แบบ fixed → ใครรู้ code ผ่าน 2FA ได้ (กันด้วย fail-fast ใน production + README)
- Register ด้วย email ซ้ำตอบ 409 → เปิดเผยว่า email มีอยู่
- Rate limit เก็บใน memory → reset เมื่อ restart
- HTTP บน localhost → cookie ไม่มี `Secure` ตอน local (เปิดด้วย env `COOKIE_SECURE=true`)

## Revisit trigger
deploy สาธารณะ (HTTPS, `Secure`, rate limit store ร่วม), เพิ่ม guest/role (ทดสอบ 403 ทุก write), หรือมี feature render rich text
