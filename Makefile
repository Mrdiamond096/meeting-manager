.DEFAULT_GOAL := help
SHELL := /bin/bash

-include .env
# Demo register limit (ADR-013 is 3/60) for npm runs too, when .env predates it. Exported like everything else.
RATE_LIMIT_REGISTER ?= 100/60
export

COMPOSE     := docker compose
COMPOSE_DEV := $(COMPOSE) -f docker-compose.yml -f docker-compose.dev.yml
SVC         ?=
DB_URL      := postgres://$(or $(POSTGRES_USER),meeting):$(or $(POSTGRES_PASSWORD),meeting)@localhost:$(or $(DB_PORT),5432)/$(or $(POSTGRES_DB),meeting)

help: ## Show targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-14s\033[0m %s\n",$$1,$$2}'

# ---------- setup ----------
init: ## Clone/update frontend + backend submodules, create .env
	git submodule update --init --recursive
	@[ -f .env ] || cp .env.example .env
update: ## Pull latest main of both submodules
	git submodule update --remote --merge
install: ## npm ci in both repos (for make dev)
	cd backend && npm ci
	cd frontend && npm ci

# ---------- local dev: npm with hot reload, only the database in docker ----------
db: ## Start only PostgreSQL in docker -> localhost:5432
	$(COMPOSE_DEV) up -d --wait db
dev: db ## Hot reload with npm: web :3001 -> api :3000 -> db in docker (Ctrl-C stops both)
	@[ -d backend/node_modules ] && [ -d frontend/node_modules ] || $(MAKE) --no-print-directory install
	cd backend && DATABASE_URL="$$DB_URL" npx prisma generate >/dev/null && DATABASE_URL="$$DB_URL" npx prisma migrate deploy
	@printf '\n  Open http://localhost:3001  (the API on :3000 has no page of its own)\n\n'
	@$(MAKE) --no-print-directory -j2 dev-api dev-web
dev-api: ## API only, npm + tsx watch (needs make db)
	cd backend && NODE_ENV=development PORT=3000 DATABASE_URL="$$DB_URL" ALLOWED_ORIGINS=http://localhost:3001 \
	  COOKIE_SECURE=false LOG_PRETTY=true OTP_PROVIDER=mock OTP_MOCK_CODE=$(or $(OTP_MOCK_CODE),112233) npm run dev
dev-web: ## Web only, next dev (needs the API on :3000)
	cd frontend && API_URL=http://localhost:3000 npm run dev

# ---------- docker: full stack ----------
up: ## Start full stack (prod build) -> http://localhost:8080
	$(COMPOSE) up -d --build
down: ## Stop full stack
	$(COMPOSE) down
build: ## Build all images
	$(COMPOSE) build
restart: down up ## Restart full stack
ps: ## Show containers
	$(COMPOSE) ps
logs: ## Follow logs (SVC=api|web|db)
	$(COMPOSE) logs -f $(SVC)

# ---------- docker: dev (hot reload in containers) ----------
dev-docker: ## Start the dev stack in docker -> web :3001, api :3000, db :5432
	$(COMPOSE_DEV) up -d --build
dev-down: ## Stop the docker dev stack (and the db from make db)
	$(COMPOSE_DEV) down

# ---------- per service ----------
up-backend: ## Start only api + db
	$(COMPOSE) up -d --build api
up-frontend: ## Start web (+ api, db)
	$(COMPOSE) up -d --build web
build-backend: ## Build api image
	$(COMPOSE) build api
build-frontend: ## Build web image
	$(COMPOSE) build web
shell-api: ## Shell into api container
	$(COMPOSE) exec api sh
db-shell: ## psql into database
	$(COMPOSE) exec db psql -U $(or $(POSTGRES_USER),meeting) -d $(or $(POSTGRES_DB),meeting)

# ---------- test ----------
test: test-backend test-frontend ## Run all tests (local node)
test-backend: ## Backend tests
	$(MAKE) -C backend test
test-frontend: ## Frontend tests
	$(MAKE) -C frontend test
test-docker: ## Run all tests inside dev containers
	$(COMPOSE_DEV) run --rm --no-deps api npm test
	$(COMPOSE_DEV) run --rm --no-deps web npm test
seed: ## Reset and load the demo data (log in as demo@example.com, see backend README)
	@if $(COMPOSE) ps --status running --services 2>/dev/null | grep -qx api; then \
	  $(COMPOSE) exec -T -e ALLOW_DEMO_SEED=true api npm run db:seed; \
	elif $(COMPOSE) ps --status running --services 2>/dev/null | grep -qx db; then \
	  cd backend && DATABASE_URL="$$DB_URL" ALLOW_DEMO_SEED=true npm run db:seed; \
	else echo "make seed: start the stack first with 'make dev' or 'make up'." >&2; exit 1; fi
e2e: ## Playwright smoke against the running stack (make up first)
	cd e2e && npm ci --no-audit --no-fund && npx playwright install chromium
	cd e2e && E2E_BASE_URL=http://localhost:$(or $(WEB_PORT),8080) npx playwright test
health: ## Smoke check the running stack
	@curl -fsS http://localhost:$(or $(WEB_PORT),8080)/api/health/ready && echo

# ---------- cleanup ----------
clean: ## Remove containers, volumes, orphans
	$(COMPOSE_DEV) down -v --remove-orphans
prune: clean ## clean + remove locally built images
	$(COMPOSE) down --rmi local

.PHONY: help init update install db dev dev-api dev-web dev-docker up down build restart ps logs dev-down up-backend up-frontend \
        build-backend build-frontend shell-api db-shell seed e2e test test-backend test-frontend test-docker health clean prune
