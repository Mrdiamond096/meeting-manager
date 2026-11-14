# ADR-008: Deployment topology

**Status:** Accepted — Local Docker only (ดู Update ท้ายไฟล์) · **Source:** A (Render) vs B (VM + Compose)

## Context
โจทย์: "Containerized the web for deployment (Including Frontend, Backend, and Database)" และ "Deploy the app". A แนะนำ Render + managed Postgres (DB production ไม่ใช่ container; free Postgres มีวันหมดอายุ — อ้างตามรีวิว Codex ยังไม่ได้ตรวจเอกสาร Render ซ้ำ) B แนะนำ VM เดียว + Compose (ตรงที่สุด แต่ต้องมี host, DNS, TLS) repo มี compose 3 service อยู่แล้ว

## Decision (เสนอ)
- **Primary:** VM เดียวรัน `docker-compose.yml` ชุดเดียวกับ local + HTTPS (Caddy หน้า web หรือ TLS ของ platform); same-origin nginx proxy `/api`
- **Fallback:** Fly.io — web, api, Postgres เป็น container ทั้งหมด, DB บน Fly volume (ยังไม่ได้ตรวจราคา/ข้อจำกัดปัจจุบัน ต้องเช็คใน spike)
- **ปฏิเสธ:** Render + managed Postgres — ขัดกับ Q2
- ตัดสินจริงหลัง Day 1 spike: ถ้า primary deploy hello-world ไม่ได้ภายใน ~3 ชม. → fallback

## Alternatives
Fly.io (Docker-native, มี volume) · Vercel FE + API แยก — ปฏิเสธ (cross-origin)

## Consequences
+ topology เดียวกันทุก environment · − ต้องดูแล TLS/update/backup เอง; ค่าใช้จ่าย VM

## Answers
- Q2 (13 พ.ย. 2026): **DB ต้องเป็น container** → Confidence ปรับเป็น Medium
- Q3: ไม่ระบุ → host จริงจะตัดสินจากผล spike วัน 1 (VPS ก่อน แล้ว Fly.io)

## Update 13 พ.ย. 2026 — Accepted: Local only
ผู้ใช้ตัดสินใจ **ข้ามการ deploy สาธารณะ** ให้รันแบบ local ด้วย `make up` (Docker Compose 3 container) และมี GitHub Actions CI เท่านั้น ไม่มี deploy job
- **ความเสี่ยงที่ยอมรับ:** โจทย์เขียน "Deploy the app (e.g., on Vercel/Render/Heroku/Docker)" — ถือว่า Docker local ตอบข้อนี้ README ต้องระบุชัด
- VPS/Fly.io ด้านบนเป็นทางเลือกในอนาคต ไม่ได้ทำ
