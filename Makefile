# Makefile — convenience targets for the Ansible CI/CD lab.
# Run `make` (or `make help`) to list all targets.

.PHONY: setup lint test deploy destroy clean ping help

help: ## Show this help message
	@echo "Available targets:"
	@echo "  setup    - Check that ansible, ansible-lint and yamllint are installed"
	@echo "  lint     - Run ansible-lint and yamllint"
	@echo "  test     - Syntax-check the playbook (dry parse, no changes)"
	@echo "  ping     - Ping all hosts in the inventory"
	@echo "  deploy   - Run site.yml against the inventory (installs nginx)"
	@echo "  destroy  - Remove what the playbook created (see target output)"
	@echo "  clean    - Remove local junk files (.retry, __pycache__, etc.)"

setup: ## Verify required tools are installed
	@echo "Checking required tools..."
	@command -v ansible >/dev/null 2>&1 || { echo "ERROR: ansible not found. Install with: pip install ansible"; exit 1; }
	@command -v ansible-lint >/dev/null 2>&1 || { echo "ERROR: ansible-lint not found. Install with: pip install ansible-lint"; exit 1; }
	@command -v yamllint >/dev/null 2>&1 || { echo "ERROR: yamllint not found. Install with: pip install yamllint"; exit 1; }
	@ansible --version | head -n 1
	@echo "All tools found."

lint: ## Run ansible-lint and yamllint
	@echo "Running ansible-lint..."
	@ansible-lint site.yml roles/
	@echo "Running yamllint..."
	@yamllint .
	@echo "Lint passed."

test: ## Syntax-check the playbook without applying changes
	@echo "Syntax-checking site.yml..."
	@ansible-playbook -i inventory/hosts.ini site.yml --syntax-check
	@echo "Syntax check passed."

ping: ## Ping all inventory hosts
	@ansible -i inventory/hosts.ini all -m ansible.builtin.ping

deploy: ## Deploy the web server (playbook run)
	@echo "Deploying web server with Ansible..."
	@ansible-playbook -i inventory/hosts.ini site.yml

destroy: ## Tear down what the playbook created
	@echo "The playbook installs nginx and drops two files in the web root."
	@echo "To undo it on a LOCAL machine (Ubuntu/Debian), run:"
	@echo "  sudo apt-get remove --purge -y nginx nginx-common"
	@echo "  sudo rm -f /var/www/html/index.html /var/www/html/health-check.txt"
	@echo "In CI there is nothing to clean up: the ubuntu-latest runner is"
	@echo "ephemeral and discarded after the job finishes."
	@echo "Refusing to run package removal automatically (guarded target)."

clean: ## Remove local junk files only (never touches the system)
	@echo "Removing local junk files..."
	@rm -f *.retry
	@rm -rf __pycache__ .pytest_cache
	@echo "Clean."
