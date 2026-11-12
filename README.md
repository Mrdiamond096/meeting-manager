# meeting-manager

Umbrella repo for the Meeting Manager app. Frontend and backend live in their own repos and are
mounted here as **git submodules**, so you can work on the whole stack or clone one side only.

```
meeting-manager/                  <- this repo (compose, Makefile, CI)
├── backend/   -> github.com/Mrdiamond096/meeting-manager-backend   (Express + Postgres)
├── frontend/  -> github.com/Mrdiamond096/meeting-manager-frontend  (React + Vite, nginx in prod)
├── docker-compose.yml            full stack, prod-like (web :8080 -> api -> db)
├── docker-compose.dev.yml        dev override: hot reload, ports 5173 / 3000 / 5432
├── Makefile
└── docs/
    ├── requirement/              original assignment brief
    ├── design/                   design guidelines + tokens
    ├── AI-thinks/                architecture proposals (claude / codex / cursor)
    └── discussion/               cross-reviews, summary, final decision
```

## Clone

```bash
git clone --recurse-submodules https://github.com/Mrdiamond096/meeting-manager.git   # everything
git clone https://github.com/Mrdiamond096/meeting-manager-backend.git               # backend only
git clone https://github.com/Mrdiamond096/meeting-manager-frontend.git              # frontend only
```

Each sub-repo has its own `Dockerfile`, `docker-compose.yml` and `Makefile`, so it also runs on its own.

## Run

```bash
make init     # pull submodules + create .env
make up       # full stack -> http://localhost:8080
make dev      # hot-reload stack -> http://localhost:5173
make test     # all tests
make down
make help     # every target
```

## Working with submodules

Commit and push inside `backend/` or `frontend/` first, then commit the updated pointer here
(`git add backend && git commit`). `make update` pulls the latest `main` of both.
