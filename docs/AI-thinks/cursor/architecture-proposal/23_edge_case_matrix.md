# Appendix — Edge Case Matrix

| Case | Safeguard | Level |
|---|---|---|
| Invalid data (blank title, bad enum, oversized text) | Zod on client + server → 422 with field details | **Essential** |
| `endAt <= startAt` | Zod refine + DB CHECK | **Essential** |
| Past dates | Allowed on edit; warn on create | Optional |
| Timezones / DST | UTC store, ISO with offset, local display, tests with varied `TZ` | **Essential** |
| Missing resource / malformed UUID | 404 / 400, FE not-found page | **Essential** |
| Concurrent updates | `version` check → 409 + reload prompt | **Essential (cheap)** |
| Duplicate submissions | Disable button while pending; (optional `Idempotency-Key`) | Essential (client) / Optional (server) |
| Pagination out of range / `pageSize` abuse | Clamp, empty `data` with correct `meta`, FE redirects to last page after deleting last item on page | **Essential** |
| DB unavailable | `/health/ready` 503, error middleware 503 `UNAVAILABLE`, FE error state with Retry, compose healthchecks | **Essential** |
| Network failure | Query retry (limited), error banner, preserve form input | Essential |
| Delete behaviour | Confirm dialog; cascade feedback; 404 on repeat; list refetch | **Essential** |
| Empty states | Dashboard, history, feedback | **Essential** |
| Illegal status transition | 409 `INVALID_TRANSITION` | Essential |
| Candidate name case/whitespace dupes | Trim + case-insensitive match | Optional |
| Double-booking | Not handled (documented) | Out of scope |
| XSS in notes/location | React escaping; URL scheme allow-list | **Essential** |
