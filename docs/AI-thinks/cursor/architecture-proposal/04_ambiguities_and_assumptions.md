# 4. Ambiguities and Assumptions

### 4.1 Core vs. wireframe conflict (not silently resolved)

| Topic | Core says | Wireframe says | Options | **[REC]** |
|---|---|---|---|---|
| Entity | generic "meeting" (title, description, due date, status) | candidate interview (name, role, time range, type, notes) | (a) Generic only; (b) Wireframe only; (c) Superset | **(c) Superset**: keep all core fields; add wireframe fields. Satisfies both graders. |
| "Due date" vs date + start/end time | single `due date` | date + start + end | (a) date only; (b) `startAt`/`endAt` timestamps | Store `startAt`,`endAt`. API field `dueDate` is **not** kept separately; document that *due date ≙ startAt* (the meeting's scheduled date). Avoids two sources of truth. |
| Status values | `status` (unspecified) | Confirmed / Pending (+ implied Cancelled via "Cancel Meeting") | free text vs enum | Enum `PENDING`, `CONFIRMED`, `CANCELLED`, `COMPLETED`. Completed is needed for History. |
| Delete vs Cancel | "delete" | "Cancel Meeting" | same thing? | **Different:** *Cancel* = status → `CANCELLED` (kept in history). *Delete* = hard delete (`DELETE`). Both exposed. |
| Title | required field | not on form | user types / derived | Form has optional "Title"; if blank, auto-fill `"{Candidate} – {Position}"`. Keeps core field without cluttering the wireframe form. |
| Description | required field | "Notes" textarea | same? | `description` ≙ booking **Notes**. *Interview notes* (recruiter notes after the fact) are separate → `feedback` entries. |
| Upcoming Meetings | list all | only current/upcoming | filter | List endpoint takes `status`, `from`, `to`, `q`, `sort`; dashboard calls it with `upcoming=true`. |
| Candidate | absent | profile page, history | embedded string vs table | Small `candidates` table (name, position-at-application). Needed to group history. |
| Positions | absent | dropdown "Software Engineer, Backend, Frontend…" | enum vs table | Static constant list shared FE/BE (in shared package). No table. |
| Meeting type | absent | Onsite / Online (Zoom, Google Meet) | | `type` enum: `ONSITE`, `ZOOM`, `GOOGLE_MEET`; optional `location` (room or URL; URL scheme validated `http(s)` only). No link generation. |
| Feedback | absent | "Add Feedback", "Interview Notes", "evaluations" | | `feedback` rows: author, rating 1–5 (optional), text. Keep minimal. |
| Auth | bonus | optional page | | See 13. |

### 4.2 Assumptions and impact

| ID | Assumption | Impact if wrong |
|---|---|---|
| A1 | Superset model is acceptable to reviewers | Low – can drop wireframe fields; core still works |
| A2 | Single organisation, no per-user data ownership | If per-user needed: add `ownerId` + filters (moderate) |
| A3 | Times stored UTC, displayed in browser's local zone | If a fixed company zone is required, add `timezone` setting (small) |
| A4 | No overlap/double-booking rules | If required, add interviewer concept + overlap query (moderate) — I recommend *not* doing this |
| A5 | Hard delete is acceptable | If audit needed → soft delete column (small) |
| A6 | Pagination = offset/limit with total count | At scale switch to keyset (list endpoint contract changes) |
| A7 | Guest = read/write demo access with no account | If guest must be read-only, add role claim (small) |
| A8 | English UI | i18n would be additive |
| A9 | Deployment target free-tier PaaS may cold-start | Documented in README |
