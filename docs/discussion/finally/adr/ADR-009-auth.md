# ADR-009: Authentication — email/password + mock OTP 2FA, Postgres sessions

**Status:** Accepted (ผู้ใช้ตัดสิน 14 พ.ย. 2026) · **Supersedes:** ฉบับเดิม "Auth ไม่อยู่ใน baseline"

ส่วน ownership/roles ถูกแทนที่โดย [ADR-015](./ADR-015-roles.md) และ [ADR-016](./ADR-016-interviewer-assignments.md); session/OTP ยังคงตาม ADR นี้

## Context
ผู้ใช้ตัดสินใจทำ login, register, forgot password และยืนยันตัวตนด้วย OTP แบบ mock (fixed code) ทั้งหมดอยู่ใน scope ของงาน (เดิมเป็น bonus); guest เลื่อนเป็น future work

## Decision
| เรื่อง | ตัดสิน |
|---|---|
| Data ownership | ใช้ร่วมกันทั้งทีม; `meetings.created_by` เก็บว่าใครสร้าง (audit เท่านั้น) |
| Identifier | email (normalize เป็นตัวเล็ก + trim, unique) |
| OTP | ใช้ตอน **register** (ยืนยัน email), **ทุกครั้งที่ login** (2FA) และ **forgot password** |
| OTP provider | interface `OtpProvider`; `MockOtpProvider` ใช้ `OTP_MOCK_CODE` (ค่าใน `.env.example` = `112233`); api **ไม่ยอม start** ถ้า `NODE_ENV=production` และใช้ mock |
| OTP challenge | ตาราง `otp_challenges(id, user_id, purpose[REGISTER/LOGIN/RESET], code_hash, attempts, expires_at, consumed_at)`; อายุ 5 นาที, ใช้ได้ครั้งเดียว, ผิด 5 ครั้งแล้วใช้ไม่ได้ |
| Session | ตาราง `sessions` ใน Postgres + cookie `sid` (httpOnly, SameSite=Lax, Path=/, `Secure` เปิดผ่าน env); idle 8 ชม., absolute 7 วัน; logout ลบ row; ไม่ใช้ Redis เพราะโหลดต่ำและมี Postgres อยู่แล้ว |
| Password hash | **bcrypt cost 12** (`bcryptjs` — pure JS ไม่ต้อง native build บน alpine) — เลือกเพราะแพร่หลายที่สุดตามที่ผู้ใช้ขอ; argon2id เป็นทางเลือกที่ OWASP แนะนำเป็นอันดับแรก |
| Password policy | อย่างน้อย 8 ตัว, สูงสุด 72 bytes (ข้อจำกัดของ bcrypt), ไม่บังคับสัญลักษณ์ (NIST 800-63B) |
| Forgot password | กรอก email → **mock email** (ไม่ส่งจริง; ระบุใน UI/README ว่าใช้ OTP mock) → กรอก OTP + password ใหม่ → ลบ session เดิมของ user ทั้งหมด; ตอบข้อความเดียวกันไม่ว่า email มีหรือไม่ |
| Enumeration | login ผิดตอบข้อความเดียว; forgot password ตอบเหมือนกันเสมอ; register email ซ้ำ → 409 (ยอมรับ trade-off) |
| Guest | **ไม่ทำในรอบนี้ (future work)** — ไม่มีปุ่ม "Continue as Guest"; schema `users.role` เผื่อไว้ (`USER` เท่านั้นตอนนี้) |
| Enforcement | Express middleware `requireAuth` / `requireRole('USER')` บนทุก route ที่ไม่ใช่ auth/health; Next `middleware.ts` redirect ไป `/login` เพื่อ UX เท่านั้น |
| CSRF | SameSite=Lax + ตรวจ `Origin` บน method ที่ไม่ใช่ GET |
| Rate limits | ตาม proposal §10 ข้อ 3 |

## Alternatives
JWT (logout ยกเลิก token ไม่ได้) · Redis session (เพิ่ม container โดยไม่จำเป็น) · argon2id (native build)

## Consequences
+ flow ครบ: register, login 2FA, forgot password, logout · − ต้องเพิ่ม 3 ตาราง (`users`, `sessions`, `otp_challenges`) และ test ด้าน auth จำนวนมาก; ทุก test ของ meetings ต้อง login ก่อน (ทำ test helper)

## Future work — Guest
ผู้ใช้ต้องการ guest แบบอ่านอย่างเดียว แต่ยังไม่ได้ตัดสินขอบเขตการมองเห็น ทางเลือกที่คุยไว้:
- **A. Read-only ทั้งหมด** — เห็น meeting ทั้งทีม แก้ไม่ได้ (write → 403); ง่ายที่สุด
- **B. Candidate portal** — candidate ยืนยันตัวตนด้วย email + OTP แล้วเห็นเฉพาะ meeting ของตัวเอง; ต้องเพิ่ม `candidates.email`
- **C. Demo data แยก** — เห็นเฉพาะ meeting `is_demo = true`; ไม่เห็นข้อมูลจริงของทีม

ทั้งสามแบบต่อยอดได้จาก role + `requireRole` middleware ที่มีอยู่ ไม่ต้องเปลี่ยน session design
