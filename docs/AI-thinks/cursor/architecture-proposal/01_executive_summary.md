# 1. Executive Summary

The assignment asks for a Meeting CRUD web app (React/Vue + Node/Python, REST, containerised, deployed), but its wireframes describe a richer **candidate interview scheduler** (candidate, position, time range, meeting type, notes, feedback, history). These two descriptions conflict, and the conflict drives most design decisions.

**Recommendation (Approach B — Balanced):**

- One `meetings` resource that satisfies the core fields (`title`, `description`, `due date`, `status`) **and** the wireframe fields (candidate, position, start/end, type, notes), plus a small `feedback` sub-resource. Candidate is a lightweight table so the "Candidate Summary / History" page is real, not faked.
- **React + TypeScript + Vite** frontend, **Node + Express + TypeScript** backend, **PostgreSQL**, shared **Zod** schemas in an npm-workspaces monorepo.
- `docker compose up` brings up db + api + web. Deployed on Render (Docker web services + managed Postgres) or a single VPS.
- GitHub Actions: lint → typecheck → test → build images (→ deploy on `main`).
- Auth (login/logout + "Continue as Guest") is a **bonus built last**, as thin as possible.

Core principle: *mandatory first, wireframe second, bonus last; every layer small and testable.*
