# Design Guidelines — Candidate Meeting Scheduler

ธีม: **Lagoon**
สแตก UI: Next.js 15 (App Router) + TypeScript · Tailwind CSS v4 · shadcn/ui (Radix) · lucide-react icons

ไฟล์ที่เกี่ยวข้อง
- `tokens/globals.css`: token ทั้งหมดสำหรับ Tailwind/shadcn (light + dark)
- `tokens/tokens.json`: ค่าเดียวกันในรูป JSON ใช้สร้าง Figma Variables

> กติกาเดียวที่สำคัญที่สุด: **ห้าม hardcode สีหรือขนาดในคอมโพเนนต์** ให้ใช้ utility ที่ผูกกับ token เท่านั้น (`bg-card`, `text-muted-foreground`, `rounded-lg`) ถ้าต้องการค่าใหม่ ให้เพิ่ม token ใน globals.css และ tokens.json พร้อมกัน

---

## 1. หลักการออกแบบ

1. **Calm & scannable:** ผู้ใช้หลักคือ recruiter หรือ interviewer ที่ต้องเห็นนัดถัดไปในไม่กี่วินาที จึงใช้พื้นหลังนิ่ง ตัวเลขและเวลาเด่น ลดสีที่ไม่สื่อความหมาย
2. **สีต้องมีหน้าที่:** Lagoon (teal) ใช้กับ action และ focus, Yolk (amber) ใช้ไฮไลต์ "วันนี้/เร็ว ๆ นี้" เท่านั้น ส่วนสีสถานะใช้กับสถานะเท่านั้น
3. **สถานะไม่พึ่งสีอย่างเดียว:** badge ต้องมีทั้งข้อความและไอคอนเสมอ
4. **Mobile-first:** การ์ดเรียงหนึ่งคอลัมน์บนมือถือ เพิ่มเป็นสองถึงสามคอลัมน์บนจอใหญ่
5. **ทุก state มีหน้าตา:** loading (skeleton), empty (มี CTA), error (มีปุ่ม Retry), disabled และ pending

## 2. สี

### Brand & surface (Light)

| Token | Hex | ใช้กับ |
|---|---|---|
| `background` | `#F7F8FA` | พื้นหลังแอป |
| `card` | `#FFFFFF` | การ์ด, dialog, popover |
| `foreground` | `#141A24` | ตัวอักษรหลัก |
| `muted-foreground` | `#5F6B7A` | ข้อความรอง, label, เวลา |
| `border` / `input` | `#E3E6EB` / `#D5DAE1` | เส้นแบ่ง / ขอบ input |
| `primary` (Lagoon) | `#1F7A6D` | ปุ่มหลัก, ลิงก์, focus ring, tab ที่เลือก |
| `accent` | `#E8F3F1` | hover, แถวที่เลือก |
| `brand` (Yolk) | `#F4B23E` | จุดหรือแถบ "Today", ตัวนับ, ไฮไลต์เล็ก ๆ |

### Meeting status

| สถานะ | Text token | Background token | ไอคอน (lucide) |
|---|---|---|---|
| Confirmed | `success` `#1E6B3A` | `success-subtle` `#E6F4EA` | `CircleCheck` |
| Pending | `warning` `#8A5A00` | `warning-subtle` `#FDF3DC` | `Clock` |
| Cancelled | `destructive` `#B42318` | `destructive-subtle` `#FDECEA` | `CircleX` |
| Past (ไม่ใช่ status — แสดงเมื่อเวลานัดผ่านไปแล้ว) | `info` `#475467` | `info-subtle` `#EEF1F5` | `History` |

Status มี 3 ค่าเท่านั้น (PENDING / CONFIRMED / CANCELLED) — ไม่มี Completed

### Contrast (ตรวจแล้ว ผ่าน WCAG AA ทุกคู่)

| คู่สี | อัตราส่วน |
|---|---|
| foreground / background | 16.4 : 1 |
| muted-foreground / card | 5.4 : 1 |
| white / primary | 5.2 : 1 |
| success / success-subtle | 5.7 : 1 |
| warning / warning-subtle | 5.4 : 1 |
| destructive / destructive-subtle | 5.8 : 1 |
| brand-foreground / brand | 7.9 : 1 |
| Dark: foreground / background | 15.7 : 1 |

ข้อห้าม: ห้ามใช้ `brand` (Yolk) เป็นสีตัวอักษรบนพื้นขาว เพราะ contrast ไม่ผ่าน ให้ใช้เป็นพื้นหลังหรือ indicator เท่านั้น

### Dark mode
ใช้ class `.dark` ที่ `<html>` โดยมี token ครบทุกตัวแล้วใน globals.css เป็น optional สำหรับงานนี้ ทำ light ให้ดีก่อน

## 3. Typography

- ฟอนต์: **Inter** สำหรับ UI และตัวเลข, **IBM Plex Sans Thai** สำหรับ UI ภาษาไทย (แอปรองรับ EN/TH) โหลดผ่าน `@fontsource` หรือ Google Fonts
- ตัวเลข วันที่ และเวลา ให้ใส่ class `tabular` (tabular-nums) เพื่อให้ตัวเลขตรงคอลัมน์

| Role | Size / Line-height | Weight | Tailwind |
|---|---|---|---|
| Page title | 24 / 32 | 600 | `text-2xl font-semibold tracking-tight` |
| Section title | 18 / 28 | 600 | `text-lg font-semibold` |
| Card title (ชื่อผู้สมัคร) | 16 / 24 | 600 | `text-base font-semibold` |
| Body | 14 / 20 | 400 | `text-sm` |
| Meta (role, เวลา) | 14 / 20 | 400 | `text-sm text-muted-foreground` |
| Label / Badge | 12 / 16 | 500 | `text-xs font-medium` |

## 4. Spacing, radius, elevation

- Grid ฐาน 4px: ใช้ scale ของ Tailwind (`1`=4px … `12`=48px)
- Padding การ์ด `p-5` (20px), ช่องว่างระหว่างการ์ด `gap-4`, ระหว่าง section `space-y-8`
- Container: `max-w-6xl mx-auto px-4 sm:px-6`
- Radius: badge 6px (`rounded-sm`), input และปุ่ม 8px (`rounded-md`), การ์ด 10px (`rounded-lg`), dialog 16px (`rounded-xl`), chip และ avatar ใช้ `rounded-full`
- Elevation: การ์ดใช้ border + `shadow-xs` เท่านั้น, popover และ dialog ใช้ `shadow-lg` ห้ามซ้อนเงาหลายชั้น

## 5. Layout ของแอป

```
┌──────────────────────────────────────────────────────────────────┐
│ Top bar: Logo · "Candidate Meeting Scheduler" · [+ New] · Avatar │
├──────────────────────────────────────────────────────────────────┤
│ Page header: Title + subtitle + primary action                   │
│ Toolbar: Search · Status filter (segmented) · Date range         │
│ Content: Card grid / Form / Profile                              │
│ Pagination                                                       │
└──────────────────────────────────────────────────────────────────┘
```
ใช้ top bar อย่างเดียว ไม่มี sidebar เพราะหน้าหลักมีน้อย การนำทางจึงสั้นและชัดกว่า Top bar มีตัวสลับภาษา EN/TH และเมนูผู้ใช้ (Logout)

**โลโก้ (ชั่วคราว):** โลโก้ EGG Digital บนพื้น Yolk ตามที่ผู้ใช้กำหนด จะเปลี่ยนภายหลัง

**ภาษา:** ข้อความภาษาไทยมักยาวกว่าอังกฤษ ปุ่มและ label ต้องไม่ fix ความกว้าง และต้องตรวจทั้งสองภาษา

## 6. Component ต่อหน้าจอ

### 6.1 Login
- การ์ดกลางจอ กว้าง `max-w-sm` มีโลโก้และชื่อ "Candidate Meeting Scheduler"
- Email + Password (shadcn `Input` + `Label`), ปุ่ม **Login** แบบ `primary` เต็มความกว้าง
- ลิงก์ "Create account" และ "Forgot password?" (ไม่มี Continue as Guest ในรอบนี้ — future work)
- Error แสดงเป็น inline `Alert` สี destructive-subtle ใต้ฟอร์ม ข้อความ login ผิดเป็นข้อความเดียวเสมอ (ไม่บอกว่า email มีหรือไม่)

### 6.1a OTP verify
- การ์ดเดียวกับ Login, input 6 ช่อง (ตัวเลข, paste ทั้ง 6 หลักได้, `autocomplete="one-time-code"`)
- hint ชัดเจน "Demo OTP: 112233" (ระบบใช้ OTP แบบ mock)
- state: ผิด (แสดงจำนวนครั้งที่เหลือ), ผิดครบ 5 ครั้งหรือหมดอายุ (กลับไปเริ่มใหม่), 429

### 6.1b Register / Forgot / Reset password
- Register: Email, Password (≥ 8 ตัว มีปุ่มแสดง/ซ่อน), Confirm password → OTP
- Forgot: Email → ข้อความเดียวกันเสมอ "ถ้ามีบัญชีนี้ เราได้ส่ง OTP แล้ว" → Reset: OTP + Password ใหม่

### 6.2 Dashboard — Upcoming Meetings
- Header: "Upcoming Meetings" + จำนวนนัด + ปุ่ม **Schedule meeting** (primary)
- Filter สถานะใช้ segmented control (`ToggleGroup`): All · Confirmed · Pending · Cancelled
- **MeetingCard**
  ```
  ┌─────────────────────────────────────┐
  │ (AV) Alice Tan          [✓ Confirmed]│
  │      Software Engineer               │
  │ 📅 Oct 12, 2025 · 10:00 – 11:00 AM  │
  │ 🎥 Online · Google Meet              │
  │                      [View details →]│
  └─────────────────────────────────────┘
  ```
  - นัดที่เป็น "วันนี้" ให้มีแถบ Yolk กว้าง 3px ทางซ้ายของการ์ด และป้าย "Today"
  - ทั้งการ์ดคลิกได้ (hover ใช้ `bg-accent`) ปุ่ม View details มีไว้สำหรับ keyboard และ screen reader
- Empty state: ไอคอน `CalendarPlus` + "No upcoming meetings" + ปุ่ม Schedule one
- Loading: skeleton การ์ด 6 ใบ ขนาดเท่าการ์ดจริง
- Pagination: shadcn `Pagination` ชิดขวา แสดง "Showing 1–12 of 48"

### 6.3 Booking Form — Schedule a New Meeting
- ฟอร์มคอลัมน์เดียว `max-w-2xl` แบ่งเป็นกลุ่มด้วยหัวข้อ: Candidate · Schedule · Details
- Candidate: `Combobox` ค้นหา candidate เดิม (แสดงชื่อ + ตำแหน่ง + วันที่สร้าง เพื่อแยกคนชื่อซ้ำ) และตัวเลือก **"+ Create new candidate"** แบบ explicit — ไม่ผูก candidate ด้วยชื่ออัตโนมัติ (ADR-006)
- Position: `Select` (Software Engineer, Backend, Frontend, …)
- Date: `Popover` + `Calendar`; Start/End time: `Select` ทีละ 15 นาที วางคู่กันในแถวเดียว
- Meeting type: `RadioGroup` แบบ card (Onsite / Online) ถ้าเลือก Online จะแสดงช่องเลือก Zoom หรือ Google Meet
- Notes: `Textarea` 4 แถว
- Action bar ด้านล่างประกอบด้วย Cancel (`outline`) และ **Book Meeting** (`primary`, แสดง spinner ขณะส่ง)
- Validation แสดงใต้ field เป็น `text-destructive text-xs` ผูกกับ `aria-describedby`; end time ต้องมากกว่า start time

### 6.4 Candidate Summary
- Header: Avatar ใหญ่ + ชื่อ + role + status badge ของนัดล่าสุด ปุ่มทางขวาคือ Edit Meeting (`outline`), Cancel Meeting (`ghost` สี destructive), Add Feedback (`primary`)
- Layout แบบ 2 คอลัมน์บน `lg` (ซ้าย 2/3, ขวา 1/3)
  - ซ้าย: **Meeting Info** (การ์ด) และ **Interview Notes / Feedback** (รายการที่มี timestamp + ช่องเพิ่ม feedback ใหม่ แบบ append-only)
  - ขวา: **History** เป็น timeline แนวตั้งของ meeting ที่ผ่านไปแล้ว (วันที่ + status + จำนวน feedback) — ไม่มีคะแนนประเมิน
- Cancel Meeting และ Delete ต้องผ่าน `AlertDialog` ยืนยันเสมอ ปุ่มยืนยันใช้ variant `destructive` (Cancel เก็บประวัติไว้, Delete ลบถาวร)
- ถ้าข้อมูลถูกแก้จากที่อื่น (409) แสดง dialog "This meeting was updated elsewhere" + ปุ่ม Reload

## 7. ปุ่ม (Button variants)

| Variant | ใช้เมื่อ | Class หลัก |
|---|---|---|
| `default` (primary) | action หลักหนึ่งอย่างต่อหน้าจอ | `bg-primary text-primary-foreground hover:bg-primary/90` |
| `outline` | action รอง | `border bg-card hover:bg-accent` |
| `ghost` | action ระดับสาม หรือในแถบเครื่องมือ | `hover:bg-accent` |
| `destructive` | ยืนยันการลบหรือยกเลิกใน dialog เท่านั้น | `bg-destructive text-destructive-foreground` |

ขนาด: `sm` สูง 32px, `default` สูง 36px, `lg` สูง 40px; ขนาด touch target บนมือถืออย่างน้อย 40px

## 8. Interaction & motion
- Transition: `transition-colors duration-150` สำหรับ hover และ focus; dialog ใช้ fade + scale 0.98 นาน 150–200ms
- เคารพ `prefers-reduced-motion`
- Focus ring: `focus-visible:ring-2 ring-ring ring-offset-2` ทุก element ที่โต้ตอบได้
- Toast (shadcn `Sonner`) แสดงผล success และ error หลัง mutation อยู่มุมล่างขวา ปิดเองใน 4 วินาที

## 9. Accessibility checklist
- [ ] ทุก input มี `<Label>` และ error ผูกด้วย `aria-describedby`
- [ ] Status badge มีข้อความ + ไอคอน ไม่ใช้สีอย่างเดียว
- [ ] Dialog ดักโฟกัสได้ ปิดด้วย Esc และคืนโฟกัสให้ปุ่มที่เปิด
- [ ] ใช้ landmark: `header`, `main`, `nav`
- [ ] Contrast ผ่าน AA (ตามตารางข้อ 2)
- [ ] ใช้งานได้ด้วยคีย์บอร์ดล้วน (Tab, Enter, Space, ลูกศรใน segmented และ select)

## 10. Workflow: Figma ↔ Code
1. สร้าง Figma Variables จาก `tokens/tokens.json` (collection `color` มี 2 modes: Light/Dark และ collection `radius`/`spacing`)
2. วาดหน้าจอตามข้อ 6 (desktop 1440 + mobile 390, EN/TH) ด้วย component ที่ผูก variable ไว้ แล้ว export PNG ไว้ที่ `docs/design/screens/` — แผนเต็มอยู่ที่ `docs/discussion/finally/figma-design-plan.md`
3. ฝั่งโค้ด: `npx shadcn@latest init` → แทน `src/app/globals.css` ด้วย `tokens/globals.css` → `npx shadcn@latest add button input label select textarea calendar popover radio-group toggle-group badge card dialog alert-dialog pagination skeleton sonner avatar`
4. เพิ่ม Badge variants `success | warning | destructive | info` (info ใช้กับ Past) ใน `components/ui/badge.tsx` ให้ map กับตารางสถานะข้อ 2
5. เมื่อเปลี่ยนสีใด ให้แก้ทั้ง `globals.css` และ `tokens.json` ใน commit เดียวกัน
