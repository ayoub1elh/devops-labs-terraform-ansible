# Makefile for lab-09-ansible-basics
# Convenience shortcuts around the ad-hoc Ansible commands in the README.
# Recipes use POSIX sh syntax; Ansible itself must run on Linux/macOS/WSL.

.PHONY: all setup lint test deploy destroy clean ping

# Default target: show what is available.
all:
	@echo "Targets:"
	@echo "  make setup   - check that ansible is installed and the inventory parses"
	@echo "  make ping    - run: ansible all -m ping"
	@echo "  make lint    - lint the inventory file (ansible-inventory --graph)"
	@echo "  make test    - run the verification checks (ping + uptime)"
	@echo "  make deploy  - prints guidance (no playbooks exist in this lab)"
	@echo "  make destroy - prints guidance (nothing to tear down)"
	@echo "  make clean   - prints guidance (nothing generated to remove)"

# Verify prerequisites before doing anything else.
setup:
	@command -v ansible >/dev/null 2>&1 || { \
		echo "ERROR: ansible not found. Install it first:"; \
		echo "  pipx install ansible   (or: python3 -m pip install ansible)"; \
		exit 1; }
	@echo "ansible version: $$(ansible --version | head -1)"
	@echo "inventory groups:"
	@ansible-inventory --graph

# There are no YAML playbooks yet in this first lab, so "lint" means
# validating that the INI inventory is well-formed.
lint:
	@ansible-inventory --graph >/dev/null && echo "OK: inventory/hosts.ini parses cleanly"

# Test = the success criteria from the README.
test: ping
	@ansible all -m shell -a "uptime"
	@echo "OK: all checks passed"

# The spec's ad-hoc shortcut target.
ping:
	@ansible all -m ping

# No playbooks exist in this lab; keep the standard target but guide
# the user instead of failing.
deploy:
	@echo "Nothing to deploy — this lab uses ad-hoc commands only."
	@echo "Try:  make ping   or   ansible webservers -m setup"

destroy:
	@echo "Nothing to destroy — no infrastructure is created in this lab."

clean:
	@echo "Nothing to clean — Ansible ad-hoc commands generate no artifacts."
	@echo "(Generated files such as *.retry are covered by .gitignore.)"
