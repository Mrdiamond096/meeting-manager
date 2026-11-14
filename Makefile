.DEFAULT_GOAL := help
SHELL := /bin/bash

-include .env
export

COMPOSE     := docker compose
COMPOSE_DEV := $(COMPOSE) -f docker-compose.yml -f docker-compose.dev.yml
SVC         ?=

help: ## Show targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-14s\033[0m %s\n",$$1,$$2}'

# ---------- setup ----------
init: ## Clone/update frontend + backend submodules, create .env
	git submodule update --init --recursive
	@[ -f .env ] || cp .env.example .env
update: ## Pull latest main of both submodules
	git submodule update --remote --merge
install: ## npm install in both repos (local dev without docker)
	$(MAKE) -C backend install
	$(MAKE) -C frontend install

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

# ---------- docker: dev (hot reload) ----------
dev: ## Start dev stack -> web :3001, api :3000, db :5432
	$(COMPOSE_DEV) up -d --build
dev-down: ## Stop dev stack
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
health: ## Smoke check the running stack
	@curl -fsS http://localhost:$(or $(WEB_PORT),8080)/api/health && echo

# ---------- cleanup ----------
clean: ## Remove containers, volumes, orphans
	$(COMPOSE_DEV) down -v --remove-orphans
prune: clean ## clean + remove locally built images
	$(COMPOSE) down --rmi local

.PHONY: help init update install up down build restart ps logs dev dev-down up-backend up-frontend \
        build-backend build-frontend shell-api db-shell test test-backend test-frontend test-docker health clean prune
