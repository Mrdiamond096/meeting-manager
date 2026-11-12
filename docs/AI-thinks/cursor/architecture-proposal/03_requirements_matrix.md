# 3. Requirements Matrix

| # | Requirement | Source | Class | Notes |
|---|---|---|---|---|
| 1 | Create meeting (title, description, due date, status) | Core | **Mandatory** | |
| 2 | List meetings with pagination or infinite scroll | Core | **Mandatory** | Pick one: pagination |
| 3 | Edit meeting | Core | **Mandatory** | |
| 4 | Delete meeting | Core | **Mandatory** | |
| 5 | Persistence (memory/JSON/SQLite/DB) | Core | **Mandatory** | |
| 6 | Frontend React or Vue | Tech | **Mandatory** | |
| 7 | Backend Express or FastAPI/Flask | Tech | **Mandatory** | |
| 8 | REST CRUD API ("DB can mockup") | Tech | **Mandatory** | |
| 9 | README with setup | Tech | **Mandatory** | |
| 10 | Containerise Frontend + Backend + DB | Tech | **Mandatory** | |
| 11 | Deploy app | Tech | **Mandatory** | |
| 12 | Public GitHub, clear commits, run-locally steps | Deliverable | **Mandatory** | |
| 13 | Auth login/logout | Bonus (+ wireframe 1 "optional") | Optional | |
| 14 | UI design (Figma/Penpot…) | Bonus | Optional | Low-fi only |
| 15 | Tests | Bonus | Optional but **strongly recommended** | Cheap, high signal |
| 16 | CI/CD (GitHub Actions) | Bonus | Optional but **recommended** | |
| 17 | Dashboard cards: candidate+role, date/time range, status Confirmed/Pending, "View Details" | Wireframe 2 | Wireframe-derived | |
| 18 | Booking form: candidate (autocomplete/free text), position dropdown, date, start/end time, type (Onsite/Online Zoom/Meet), notes | Wireframe 3 | Wireframe-derived | |
| 19 | Candidate Summary: profile, meeting info, interview notes, history | Wireframe 4 | Wireframe-derived | |
| 20 | Buttons Edit Meeting / Cancel Meeting / Add Feedback | Wireframe 4 | Wireframe-derived | |
| 21 | "Continue as Guest" | Wireframe 1 | Optional | |
| 22 | Company logo | Wireframe 1 | Optional | Placeholder |

**Potential scope creep (deliberately avoided):** real Zoom/Meet link generation, calendar/ICS sync, email notifications, role-based access, multi-tenant, candidate CRUD UI, file uploads/CVs, infinite-scroll *and* pagination, i18n, real-time updates, Kubernetes, microservices, GraphQL.
