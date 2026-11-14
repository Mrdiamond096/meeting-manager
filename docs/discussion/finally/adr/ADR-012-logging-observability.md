# ADR-012: Logging & observability

**Status:** Accepted (14 พ.ย. 2026) · **Source:** [proposal §4–5](../api-security-observability-proposal.md)

## Decision
**Logger:** pino + pino-http, JSON หนึ่งบรรทัดต่อ event ไป stdout; `LOG_LEVEL` (default `info`, test `silent`); `pino-pretty` เฉพาะ dev ผ่าน `LOG_PRETTY=true`

**Level policy**
| Level | ใช้เมื่อ |
|---|---|
| `fatal` | process ต้องปิด (migration ล้ม, ต่อ DB ไม่ได้ตอน start, mock OTP ใน production) |
| `error` | 5xx / exception ที่ไม่คาดคิด (พร้อม stack) |
| `warn` | **case by case** เมื่อเป็นสัญญาณที่ต้อง investigate: 429, 413, readiness ล้ม, OTP challenge ถูก invalidate เพราะผิดครบ 5 ครั้ง |
| `info` | lifecycle, access log ทุก request, **4xx ทั่วไป** (400/401/403/404/409/422) เพราะเกิดจากข้อมูล/ผู้ใช้ ไม่ใช่โปรแกรม |
| `debug` | รายละเอียดสำหรับ dev |

**Redaction / ห้าม log:** `cookie`, `authorization`, `set-cookie`, request/response body ทั้งหมด, password, OTP code, `DATABASE_URL`; ไม่เขียน access log ของ `/api/health/*`; log `userId` ได้ แต่ไม่ log email

**Correlation:** Express รับ `X-Request-Id` ที่ผ่าน format (`[A-Za-z0-9-]{1,64}`) หรือสร้าง `randomUUID()`; ส่งกลับใน header + error body; frontend แสดง requestId ใน error state

**Observability baseline:** `/api/health/live` (+`version` จาก `APP_VERSION`), `/api/health/ready`, Docker healthcheck, access log มี `method, route, status, durationMs, requestId, userId?`

## Rejected / future work
`/metrics` + Prometheus/Grafana (ผู้ใช้เลือกไม่ทำ), OpenTelemetry, Sentry, ส่ง log จาก browser

## Revisit trigger
deploy จริง, มีหลาย instance, หรือมี SLO
