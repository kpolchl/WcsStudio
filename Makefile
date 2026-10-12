# Local mirror of the CI workflow (.github/workflows/ci.yml).
# Run `make` or `make help` to list targets, `make ci` to run every check.

MIX_ENV ?= test
export MIX_ENV

MIX := mix

.DEFAULT_GOAL := help

.PHONY: help setup deps format format-check compile audit credo sobelow db-setup test ci

help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

setup: deps ## Fetch and verify dependencies
	$(MIX) deps.get

deps: ## Check for unused locked dependencies
	$(MIX) deps.unlock --check-unused

format: ## Auto-format the codebase
	$(MIX) format

format-check: ## Verify formatting without modifying files
	$(MIX) format --check-formatted

compile: ## Compile with warnings as errors
	$(MIX) compile --warnings-as-errors

audit: ## Audit for retired Hex packages
	$(MIX) hex.audit

credo: ## Run Credo in strict mode
	$(MIX) credo --strict

sobelow: ## Run Sobelow security scan (fails on Low and above)
	$(MIX) sobelow --private --exit Low

db-setup: ## Create and migrate the test database
	$(MIX) ecto.create
	$(MIX) ecto.migrate

test: ## Run the test suite
	$(MIX) test

ci: setup format-check compile audit credo sobelow test ## Run every CI check locally
	@echo "All CI checks passed."
