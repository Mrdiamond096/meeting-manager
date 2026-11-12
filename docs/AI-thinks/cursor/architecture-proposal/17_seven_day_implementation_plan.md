# 17. Seven-Day Implementation Plan

Effort ≈ 5–6 focused hours/day; Day 7 is deliberate buffer.

| Day | Milestone | Tasks | Deliverable / DoD | Checkpoint |
|---|---|---|---|---|
| **1** | Foundations & design | Confirm decisions (this doc); repo scaffold (workspaces, tsconfig, eslint, prettier); shared Zod schemas; DB schema + first migration; low-fi wireframes; CI skeleton (lint+typecheck) | `npm run dev` boots empty api (`/health`) + web shell; migration runs; CI green | Schema reviewed |
| **2** | Backend core | Meetings repo/service/controller/routes; validation; error middleware; list w/ pagination+filters; PATCH + version; delete; seed | All meeting endpoints work via curl/OpenAPI; DoD: integration tests for happy + main error paths | **Test gate 1** |
| **3** | Backend complete + Docker | Candidates + feedback + cancel + transitions; OpenAPI docs; api Dockerfile; compose (db+api) | Full API test suite green; `docker compose up` serves API with persistent volume | **Docker gate 1** |
| **4** | Frontend core | API client + Query hooks; Dashboard (cards, filters, pagination, empty/error/loading); Booking/Edit form with validation; delete/cancel confirm | Create/list/edit/delete usable end-to-end in browser | Manual CRUD pass |
| **5** | Wireframe completion + full stack containers | Meeting/Candidate detail page (info, feedback, history, Add Feedback); web Dockerfile + nginx; compose full stack; component tests; a11y pass | All 4 wireframe pages (minus login) work from `docker compose up`; **mandatory scope complete** | **Docker gate 2 / feature freeze for mandatory** |
| **6** | Deploy + CI/CD + bonus | Deploy to Render; CI build + deploy workflow; Playwright smoke; auth (login/logout/guest) *only if on schedule*; README first full draft | Public URL works; pipeline green | **Deploy gate** |
| **7** | Buffer & polish | Fix issues, edge cases from checklist, README (setup, decisions, API, trade-offs, screenshots), ADR files, commit history tidy, fresh-clone test, demo seed check | Fresh clone verified on clean machine; repo public; link submitted | Final manual checklist |

**Dependencies:** shared schemas (D1) → API (D2–3) and forms (D4). Deploy needs both Dockerfiles (D3, D5). Auth needs API + FE stable (D6).
**Cut order if behind:** Playwright → auth → OpenAPI polish → design files → feedback ratings → candidate autocomplete (fallback free text). **Never cut:** CRUD, pagination, persistence, Docker, deploy, README.
**Deploy early rule:** push a hello-world deployment on Day 3 if possible to de-risk Day 6.
