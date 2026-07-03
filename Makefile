# ==============================================================================
# headsntails platform - Orchestration Engine
# ==============================================================================

.PHONY: help e2e up down clean

# Default target when running just 'make'
help:
	@echo "Available commands:"
	@echo "  make up       - Spin up the local development ecosystem (Detached)"
	@echo "  make down     - Tear down the local development ecosystem"
	@echo "  make e2e      - Run the full platform End-to-End integration test rig"
	@echo "  make clean    - Deep clean all cached images, orphan containers, and test volumes"

# --- LOCAL DEVELOPMENT INFRASTRUCTURE ---
up:
	@echo "Spinning up local development mesh..."
	docker compose up -d --build

down:
	@echo "Stopping local development mesh..."
	docker compose down

# --- STAGE 3: END-TO-END VERIFICATION GATE ---
e2e:
	@echo "Orchestrating hermetic E2E test environment..."
	docker compose -f tests/docker-compose.e2e.yml up \
		--build \
		--abort-on-container-exit \
		--exit-code-from e2e-tester
	@$(MAKE) e2e-down

e2e-down:
	@echo "Cleaning ephemeral E2E network grid and database volumes..."
	docker compose -f tests/docker-compose.e2e.yml down -v

# --- SYSTEM MAINTENANCE ---
clean:
	@echo " Executing deep platform prune..."
	docker compose down -v --remove-orphans
	docker compose -f tests/docker-compose.e2e.yml down -v --remove-orphans
	@echo "Environment is completely pure."