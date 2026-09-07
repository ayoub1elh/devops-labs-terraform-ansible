# Makefile for lab-12 (Molecule testing of the webserver role).
# Standard targets per the repo conventions:
#   setup    - install Python tooling (ansible, molecule, docker driver)
#   lint     - ansible-lint + yamllint over the role and playbooks
#   test     - full Molecule test sequence (create/converge/idempotence/verify/destroy)
#   deploy   - run the role against the Molecule instance (molecule converge)
#   destroy  - remove the Molecule instance (molecule destroy)
#   clean    - remove local caches and build artifacts

# Directory containing the Molecule scenario for the webserver role.
ROLE_DIR := roles/webserver

.PHONY: setup lint test deploy destroy clean verify converge login help

help: ## Show this help
	@echo "lab-12 targets:"
	@echo "  make setup    Install ansible + molecule + docker driver via pip"
	@echo "  make lint     Run ansible-lint and yamllint"
	@echo "  make test     Run full Molecule test sequence"
	@echo "  make deploy   Converge (apply role to the test container)"
	@echo "  make destroy  Destroy the test container"
	@echo "  make clean    Remove local caches"

setup: ## Install prerequisites (Python packages)
	@echo "==> Installing ansible, molecule, docker driver"
	python3 -m pip install --upgrade pip
	python3 -m pip install ansible ansible-lint yamllint molecule "molecule-plugins[docker]" docker
	@echo "==> Versions:"
	ansible --version
	molecule --version
	@echo "NOTE: Docker Desktop (or docker engine) must be installed and running."

lint: ## Lint the role and playbooks
	@echo "==> Running ansible-lint"
	ansible-lint
	@echo "==> Running yamllint"
	yamllint -d "{extends: default, rules: {line-length: {max: 160}}}" site.yml roles/

test: ## Run the full Molecule test sequence
	@echo "==> molecule test (create -> converge -> idempotence -> verify -> destroy)"
	cd $(ROLE_DIR) && molecule test

deploy: ## Apply the role inside the Molecule container (converge)
	@echo "==> molecule create + converge"
	cd $(ROLE_DIR) && molecule create
	cd $(ROLE_DIR) && molecule converge

converge: deploy ## Alias for deploy

verify: ## Run verification against the running container
	@echo "==> molecule verify"
	cd $(ROLE_DIR) && molecule verify

login: ## Open a shell inside the test container (debugging)
	@echo "==> molecule login"
	cd $(ROLE_DIR) && molecule login

destroy: ## Destroy the Molecule container
	@echo "==> molecule destroy"
	cd $(ROLE_DIR) && molecule destroy

clean: ## Remove caches and Molecule state
	@echo "==> Removing local caches"
	rm -rf .molecule $(ROLE_DIR)/.molecule
	find . -type d -name __pycache__ -prune -exec rm -rf {} +
	find . -type d -name .pytest_cache -prune -exec rm -rf {} +
