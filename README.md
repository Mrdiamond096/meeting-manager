# meeting-manager

Umbrella repo for the Meeting Manager app. Frontend and backend live in their own repos and are
mounted here as **git submodules**, so you can work on the whole stack or clone one side only.

```
meeting-manager/                  <- this repo (compose, Makefile, CI)
├── backend/   -> github.com/Mrdiamond096/meeting-manager-backend   (Express + Postgres)
├── frontend/  -> github.com/Mrdiamond096/meeting-manager-frontend  (Next.js, standalone server in prod)
├── docker-compose.yml            full stack, prod-like (web :8080 -> api -> db)
├── docker-compose.dev.yml        dev override: hot reload, ports 3001 / 3000 / 5432
├── Makefile
└── docs/
    ├── README.md                 documentation index
    ├── requirement/              original assignment brief
    ├── design/                   design guidelines, tokens and Figma screen exports
    └── discussion/finally/       architecture, technical design and decision records
```

See the [documentation index](docs/README.md) for the requirements, design and API specification.

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
make dev      # day-to-day: npm with hot reload -> http://localhost:3001 (only the database runs in docker)
make seed     # optional demo data (log in as demo@example.com)
make test     # all tests
make help     # every target
```

`make dev` runs the API (`tsx watch`, :3000) and the web app (`next dev`, :3001) with npm, so an edit shows up
without rebuilding an image. PostgreSQL runs in docker on :5432 (`make db`); migrations run before the API starts.
Ctrl-C stops both; `make dev-down` stops the database. `make dev-api` / `make dev-web` start one side only.

Docker images are built in CI: each repo's pipeline builds its image, and this repo's CI starts the full stack with
`docker compose` and runs the smoke test and Playwright against it. To run the same prod-like stack locally:

```bash
make up       # full stack in docker (prod build) -> http://localhost:8080
make e2e      # Playwright against it
make down
```

## Working with submodules

Commit and push inside `backend/` or `frontend/` first, then commit the updated pointer here
(`git add backend && git commit`). `make update` pulls the latest `main` of both.
