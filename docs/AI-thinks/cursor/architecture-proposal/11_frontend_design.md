# 11. Frontend Design

**Routes**

| Path | Page | Wireframe |
|---|---|---|
| `/login` | Login (+ Continue as Guest) | 1 |
| `/` | Dashboard – "Upcoming Meetings" cards + filters + pagination | 2 |
| `/meetings/new` | "Schedule a New Meeting" | 3 |
| `/meetings/:id/edit` | Same form, prefilled | 3 |
| `/meetings/:id` | "View Details" → Candidate Summary of that meeting's candidate | 4 |
| `/candidates/:id` | Candidate Summary (optional alias of above) | 4 |
| `*` | Not found | — |

Navigation decision: "View Details" opens `/meetings/:id`, which renders the candidate profile header, this meeting's info, interview notes/feedback, and the candidate's history list. One page, fewer routes.

**Component hierarchy (sketch)**
```
App (QueryClientProvider, Router, AuthProvider*)
├─ AppLayout (header, logout*)
├─ DashboardPage → MeetingFilters, MeetingCard[], Pagination, EmptyState, ErrorState, Skeletons
├─ MeetingFormPage → MeetingForm (CandidateAutocomplete, PositionSelect, DateInput, TimeRange, TypeRadio, Notes)
├─ MeetingDetailPage → CandidateHeader, MeetingInfo, FeedbackList, FeedbackDialog, HistoryList, ConfirmDialog
└─ LoginPage*
src/api/ (typed client + query hooks) · src/lib/ (date utils) · src/components/ui/ (Button, Dialog, Badge, Toast)
```

**Data fetching:** one typed `apiFetch` wrapper (JSON, error normalisation to the error shape, `credentials: 'include'`); TanStack Query hooks per resource; mutations invalidate relevant keys; `keepPreviousData` for pagination; list filters synced to URL search params.

**States:** skeleton while loading; inline error with Retry; empty state ("No upcoming meetings – Schedule one"); mutation pending disables submit; success toast; field-level server errors mapped back into the form (`setError`); 409 version conflict shows "Updated by someone else – reload" action.

**Validation:** shared Zod schema in RHF; time-range cross-field check; inline messages tied via `aria-describedby`.

**Accessibility/UX:** semantic landmarks, labelled inputs, visible focus, keyboard-operable dialogs (Radix/`<dialog>`), status not colour-only (badge text + icon), contrast ≥ AA, responsive cards (mobile first). Confirm dialog before Delete/Cancel.

**UI design bonus:** 4 low-fi wireframes in Penpot/Figma exported as PNG into `docs/design/` (≈1–2h, Day 1). No pixel-perfect work.
