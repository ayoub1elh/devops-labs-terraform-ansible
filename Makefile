# =============================================================================
# lab-15-ansible-vault — convenience Makefile
#
# Standard targets:
#   setup    create local vault_password from vault_password.example (600)
#   lint     YAML-lint the Ansible files
#   test     ansible-playbook --syntax-check (vault-aware)
#   deploy   run the demonstration playbook against localhost
#   destroy  remove the config file the playbook creates
#   clean    destroy + remove local vault_password
# Extra: rekey = rotate the vault password interactively.
# =============================================================================

SHELL := /bin/bash

PLAYBOOK     := ansible/site.yml
VAULT_FILE   := ansible/group_vars/all/vault.yml
PASS_FILE    := vault_password
CONFIG_FILE  := /tmp/lab15-app.conf

.PHONY: all setup lint test deploy destroy clean rekey

all: setup test deploy

## setup: create the local vault password file if missing (mode 600)
setup:
	@if [ ! -f $(PASS_FILE) ]; then \
		echo "Creating local $(PASS_FILE) from vault_password.example ..."; \
		cp vault_password.example $(PASS_FILE); \
		chmod 600 $(PASS_FILE); \
		echo "Done. Password file: $(PASS_FILE)"; \
	else \
		echo "$(PASS_FILE) already exists — leaving it untouched."; \
	fi

## lint: YAML-lint the playbook and group_vars (ansible-lint if present)
lint:
	@if command -v ansible-lint >/dev/null 2>&1; then \
		ansible-lint $(PLAYBOOK); \
	elif command -v yamllint >/dev/null 2>&1; then \
		yamllint -d "{extends: default, rules: {line-length: {max: 120}}}" ansible/; \
	else \
		echo "Neither ansible-lint nor yamllint found — install one, or skip lint."; \
	fi

## test: syntax-check the playbook (requires a decryptable vault file)
test: setup
	ansible-playbook $(PLAYBOOK) --vault-password-file $(PASS_FILE) --syntax-check

## deploy: run the demonstration playbook on localhost
deploy: setup
	ansible-playbook $(PLAYBOOK) --vault-password-file $(PASS_FILE)

## rekey: rotate the vault password (interactive)
rekey:
	ansible-vault rekey $(VAULT_FILE)

## destroy: remove the config file written by the playbook
destroy:
	@if [ -f $(CONFIG_FILE) ]; then \
		rm -f $(CONFIG_FILE); \
		echo "Removed $(CONFIG_FILE)."; \
	else \
		echo "Nothing to destroy ($(CONFIG_FILE) not found)."; \
	fi

## clean: destroy + remove the local vault password file
clean: destroy
	@if [ -f $(PASS_FILE) ]; then \
		rm -f $(PASS_FILE); \
		echo "Removed local $(PASS_FILE)."; \
	else \
		echo "$(PASS_FILE) already absent."; \
	fi
