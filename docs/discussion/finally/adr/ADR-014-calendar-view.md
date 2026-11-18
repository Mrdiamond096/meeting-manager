# ADR-014: Calendar view (Week + Month) คู่กับ List บน Dashboard

**Status:** Accepted (ผู้ใช้ตัดสิน 14 พ.ย. 2026)

การมอบหมายและสิทธิ์ของตัวกรอง Mine อัปเดตตาม [ADR-016](./ADR-016-interviewer-assignments.md)

## Context
ผู้ใช้ต้องการหน้าแบบปฏิทิน (คล้าย Google Calendar) ที่ผูกกับวันและเวลาจริง เพื่อดูว่า meeting ของตัวเองอยู่วันไหน เวลาอะไร ADR-009 กำหนดให้ข้อมูลใช้ร่วมกันทั้งทีม และ `meetings.created_by` ใช้สำหรับ audit เท่านั้น

## Decision
| เรื่อง | ตัดสิน |
|---|---|
| ตำแหน่ง | Dashboard `/` มีตัวสลับ **List \| Calendar**; route `/?view=calendar&mode=week&date=2026-11-16` (deep-link ได้, จำค่าล่าสุดใน URL) |
| Views | **Week** (time grid 07:00–20:00 เลื่อนดูได้ 00–24, คอลัมน์ จ.–อา., เส้นเวลาปัจจุบัน) และ **Month** (grid 6×7, แสดงสูงสุด 3 event/วัน + "+n more"); mobile ใช้ **Day agenda** แทน week |
| Mine / All | ค่าเริ่มต้นคือ Mine / All team ทั้ง List และ Calendar; Recruiter/Admin ใช้ `mine=true` ตามผู้สร้าง ส่วน Interviewer ใช้ `assignedToMe=true` ตามรายชื่อผู้รับมอบหมาย (ADR-016) |
| Interaction | คลิก event → S8 Candidate Summary · คลิกช่องว่าง → S7 นัดใหม่โดยเติมวันและเวลาเริ่มให้ (ปัดเป็น 30 นาที) · ปุ่ม Today / ‹ › · status filter ใช้ร่วมกับ List |
| Cancel การสร้างนัด | ฟอร์มที่เปิดจาก Calendar กลับไปวัน มุมมอง Week/Month และตัวกรอง status / mine เดิม โดยไม่บันทึก; เก็บบริบทในลิงก์เปิดฟอร์มให้กลับได้หลังรีเฟรชด้วย ส่วนการสร้างจาก List ยังคงกลับ List |
| สีของ event | ตาม status: Confirmed = success, Pending = warning, Cancelled = muted + ขีดฆ่า, Past = opacity ลด |
| Timezone | แสดงตาม timezone ของ browser (ADR-005: เก็บเป็น instant UTC); header ระบุ timezone เช่น `GMT+7` |
| API | ใช้ `GET /meetings` เดิม เพิ่ม `mine=true` และอนุญาต `from`/`to` โดยไม่ paginate เมื่อส่ง `view=range` (จำกัดช่วง ≤ 42 วัน, สูงสุด 500 รายการ) → 200 `{items}`; ช่วงเกิน → 400 |
| Overlap | event ที่ซ้อนเวลาวางคู่กันในคอลัมน์ (แบ่งความกว้าง) — ไม่ห้ามจองซ้อนในรอบนี้ |
| Library | **ไม่เพิ่ม calendar library** (FullCalendar ฯลฯ) — สร้างด้วย CSS grid + `date-fns` (ขออนุมัติเพิ่ม dependency ตอน C4) |

## Alternatives
FullCalendar / react-big-calendar (เร็วกว่าแต่ปรับธีมยากและ bundle ใหญ่) · ownership รายคน (ต้องแก้ ADR-009 ทั้งระบบ) · Day view บน desktop (ตัดเพื่อประหยัดเวลา ~3 ชม.)

## Consequences
+ เห็นภาพตารางเวลาจริง, จองจากช่องว่างได้เร็ว · − เพิ่มงาน frontend ~6–8 ชม. (C4) + backend ~1 ชม. (range query + `mine`) · ต้องมี test เรื่อง timezone/DST และ event ข้ามวัน

## Revisit trigger
ต้องการ drag-to-reschedule หรือ Day view บน desktop → พิจารณา library
