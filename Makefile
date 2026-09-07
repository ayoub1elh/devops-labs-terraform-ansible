# Makefile for Lab 11 — Ansible Roles (refactors Lab 10 into a webserver role).
# Standard targets: setup, lint, test, deploy, destroy, clean.
# Ansible labs: `deploy` runs the playbook; `destroy` prints the
# manual teardown steps (Ansible has no built-in "undeploy").

.PHONY: all setup lint test deploy destroy clean ping help

ANSIBLE ?= ansible
ANSIBLE_PLAYBOOK ?= ansible-playbook
ANSIBLE_LINT ?= ansible-lint

help: ## Show this help
	@echo "Lab 11 - Ansible Roles"
	@echo "Targets: setup lint test deploy destroy clean ping all"
	@echo "  deploy  - run site.yml (installs nginx via the webserver role)"
	@echo "  destroy - print manual teardown steps (nothing is created to destroy)"

all: deploy ## Deploy the webserver role (default)

setup: ## Verify Ansible is installed and show the role layout
	@echo "==> Checking Ansible version"
	@$(ANSIBLE) --version
	@echo "==> Role layout:"
	@find roles -type f | sort
	@echo "==> Next: edit inventory/hosts.ini, then run 'make ping'"

ping: ## Check SSH connectivity to the webservers group
	@$(ANSIBLE) webservers -m ansible.builtin.ping

lint: ## Run ansible-lint if available (skipped otherwise)
	@if command -v $(ANSIBLE_LINT) >/dev/null 2>&1; then \
		$(ANSIBLE_LINT) site.yml roles/; \
	else \
		echo "ansible-lint not found; install it with: pip install ansible-lint"; \
	fi

test: ## Syntax-check the playbook (dry parse, no changes)
	@$(ANSIBLE_PLAYBOOK) --syntax-check site.yml
	@echo "Syntax check passed."

deploy: ## Run the playbook (deploys the webserver role)
	@$(ANSIBLE_PLAYBOOK) site.yml

destroy: ## Ansible has no undeploy; print the manual teardown commands
	@echo "Nothing was 'created' by Terraform here; to tear down the nginx setup run:"
	@echo "  $(ANSIBLE) webservers -m ansible.builtin.apt -a 'name=nginx state=absent purge=true' --become   # Debian/Ubuntu"
	@echo "  $(ANSIBLE) webservers -m ansible.builtin.dnf -a 'name=nginx state=absent' --become             # RedHat family"
	@echo "  $(ANSIBLE) webservers -m ansible.builtin.file -a 'path=/var/www/html state=absent' --become"
	@echo "  $(ANSIBLE) webservers -m ansible.builtin.file -a 'path=/etc/nginx state=absent' --become"
	@echo "If you used a Vagrant VM, also run: vagrant destroy -f"

clean: ## Remove local artifacts (retry files, Python caches)
	@echo "Removing retry files and caches..."
	@rm -f *.retry roles/*/*.retry
	@find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	@echo "Clean."
