# 10. API Design

Base: `/api/v1` (versioning in path — cheap now, painful later). JSON only.

| Method | Path | Purpose | Success |
|---|---|---|---|
| GET | `/meetings` | list/filter/paginate | 200 |
| POST | `/meetings` | create | 201 + `Location` |
| GET | `/meetings/:id` | detail (includes candidate, feedback count) | 200 |
| PATCH | `/meetings/:id` | partial update (requires `version`) | 200 |
| DELETE | `/meetings/:id` | hard delete | 204 |
| POST | `/meetings/:id/cancel` | status → CANCELLED | 200 |
| GET | `/meetings/:id/feedback` | list | 200 |
| POST | `/meetings/:id/feedback` | add feedback | 201 |
| GET | `/candidates` | `?q=` autocomplete (limit 10) | 200 |
| GET | `/candidates/:id` | profile + meetings (history) | 200 |
| GET | `/meta` | positions, types, statuses (or shared constants only) | 200 |
| GET | `/health` | liveness (+ `/health/ready` with DB ping) | 200/503 |
| POST | `/auth/login`, `/auth/logout`, `GET /auth/me`, `POST /auth/guest` | bonus | |

PUT is omitted: PATCH with partial body is enough; edit form sends changed fields (or all) plus `version`.

**List query:** `page` (default 1), `pageSize` (default 10, max 50), `status`, `type`, `q` (title/candidate), `from`, `to`, `upcoming=true`, `sort` (`startAt` | `-startAt` | `createdAt`; default `startAt`). Response:

```json
{
  "data": [ { "id": "…", "title": "Alice – Software Engineer", "candidate": {"id":"…","name":"Alice"},
              "position": "Software Engineer", "startAt": "2025-10-12T03:00:00.000Z",
              "endAt": "2025-10-12T04:00:00.000Z", "status": "CONFIRMED", "type": "ZOOM",
              "location": "https://…", "description": "…", "version": 3 } ],
  "meta": { "page": 1, "pageSize": 10, "total": 37, "totalPages": 4 }
}
```
**Pagination decision:** classic page-based with stable ordering (`start_at, id`). Chosen over infinite scroll (assignment allows either; pagination has simpler tests, URL-addressable, deterministic). Offset-vs-keyset trade-off recorded in ADR; offset is fine at this scale.

**Create body:** `{ candidateName, position, startAt, endAt, type, location?, title?, description?, status? }`.
**Validation rules:** required fields as above; `endAt > startAt`; not required to be in the future (editing past meetings must work) but create warns client-side if past; strings trimmed; unknown keys stripped (`strict` on write); `id` must be UUID (else 400 not 404).

**Error format (RFC 7807-style, stable shape):**
```json
{ "error": { "code": "VALIDATION_ERROR", "message": "Request validation failed",
             "details": [ { "field": "endAt", "message": "must be after startAt" } ],
             "requestId": "…" } }
```
Codes: `VALIDATION_ERROR` 400/422 · `UNAUTHORIZED` 401 · `NOT_FOUND` 404 · `VERSION_CONFLICT` 409 · `INVALID_TRANSITION` 409 · `RATE_LIMITED` 429 · `INTERNAL` 500 (no stack leakage) · `UNAVAILABLE` 503. I use **422** for semantic validation, **400** for malformed JSON/params.

Idempotency: `DELETE` of a missing id → 404 (documented; the client treats it as success after a refetch). Duplicate submit mitigated client-side (disabled button) — see edge cases.
