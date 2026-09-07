# Makefile for lab-10-playbooks.
#
# Convenience wrapper around the ansible commands in README.md.
# Recipe lines start with TAB characters (required by make).

PLAYBOOK := site.yml
INVENTORY := inventory/hosts.ini

.PHONY: help setup lint test deploy destroy clean ping

help: ## Show this help message
	@echo "lab-10-playbooks targets:"
	@echo "  setup    - verify required tools are installed"
	@echo "  ping     - check Ansible can reach the inventory hosts"
	@echo "  lint     - run ansible-lint and yamllint on the playbook"
	@echo "  test     - run the playbook in check mode (dry run)"
	@echo "  deploy   - run the playbook for real"
	@echo "  destroy  - stop/disable Nginx and remove the deployed page"
	@echo "  clean    - remove Ansible retry files and Python caches"

setup: ## Verify required tools are installed
	@echo "Checking prerequisites..."
	@command -v ansible >/dev/null 2>&1 && ansible --version | head -n 1 || (echo "ERROR: ansible not found. Install: pip install ansible" && exit 1)
	@command -v curl >/dev/null 2>&1 && echo "curl: OK" || echo "WARN: curl not found (used for verification)"

ping: ## Verify Ansible connectivity to the webservers group
	ansible -i $(INVENTORY) webservers -m ansible.builtin.ping

lint: ## Lint the playbook and inventory
	@command -v ansible-lint >/dev/null 2>&1 && ansible-lint $(PLAYBOOK) || echo "ansible-lint not installed; skipping (pip install ansible-lint)"
	@command -v yamllint >/dev/null 2>&1 && yamllint $(PLAYBOOK) || echo "yamllint not installed; skipping (pip install yamllint)"

test: ## Dry-run the playbook in check mode (no changes made)
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --check

deploy: ## Run the playbook for real
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK)

destroy: ## Stop Nginx and remove the deployed page (local-lab teardown)
	@echo "Stopping Nginx and removing the deployed page..."
	ansible -i $(INVENTORY) webservers -m ansible.builtin.service -a "name=nginx state=stopped enabled=false" --become
	ansible -i $(INVENTORY) webservers -m ansible.builtin.file -a "path=/var/www/html/index.html state=absent" --become || true
	@echo "Done. Uninstall Nginx manually if desired: sudo apt remove nginx"

clean: ## Remove retry files and Python caches
	@rm -f *.retry
	@rm -rf __pycache__/
	@echo "Cleaned."
