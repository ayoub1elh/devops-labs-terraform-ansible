# Lab 00 — Environment Setup & Toolchain Validation
#
# This Makefile validates that the full lab toolchain is installed locally:
#   terraform, ansible, tflint, ansible-lint, checkov, tfsec, molecule
# Other standard targets print guidance, because this lab deploys nothing.

# Tools verified by `make setup`, in PATH-check order.
TOOLS := terraform ansible tflint ansible-lint checkov tfsec molecule

# Path where tfsec's release binary is placed by the `install-tools` target.
TFSEC_BIN := $(HOME)/bin/tfsec

# Detect Git Bash / MSYS on Windows. The automatic installers in
# `install-tools` target Linux/macOS only, so on Windows we print
# instructions instead of running them.
UNAME_S := $(shell uname -s 2>/dev/null || echo unknown)
IS_WINDOWS := $(filter MINGW% MSYS% CYGWIN%,$(UNAME_S))

.PHONY: setup install-tools lint test deploy destroy clean

## setup: verify every tool is installed; install missing ones via pipx/installers, then re-check.
setup: install-tools
	@echo "==> Lab 00: validating local toolchain..."
	@missing=0; \
	for tool in $(TOOLS); do \
		if command -v $$tool >/dev/null 2>&1; then \
			echo "  [OK] $$tool"; \
		else \
			echo "  [MISSING] $$tool"; \
			missing=1; \
		fi; \
	done; \
	if [ $$missing -ne 0 ]; then \
		echo "==> Some tools are still missing. See Troubleshooting in README.md."; \
		exit 1; \
	fi
	@echo "==> Tool versions:"
	@for tool in $(TOOLS); do \
		echo "----- $$tool -----"; \
		$$tool version 2>/dev/null || $$tool --version; \
	done
	@echo "==> All $(words $(TOOLS)) tools are installed and on PATH. Toolchain OK."

## install-tools: install any missing tool (idempotent — skips what is already present).
# Linux/macOS: install automatically. Windows Git Bash: print manual steps —
# the commands below need python3/pipx/wget/sudo, which Git Bash does not provide.
install-tools:
ifeq ($(IS_WINDOWS),)
	@echo "==> Installing missing tools (idempotent)..."
	@command -v pipx >/dev/null 2>&1 || { \
		echo "pipx not found — installing..."; \
		python3 -m pip install --user pipx; \
		pipx ensurepath; \
		echo "NOTE: re-open your terminal (or run 'make setup' again) so pipx's PATH takes effect."; \
	}
	@command -v ansible >/dev/null 2>&1 || pipx install --include-deps ansible || true
	@command -v ansible-lint >/dev/null 2>&1 || pipx install ansible-lint || true
	@command -v molecule >/dev/null 2>&1 || pipx install molecule || true
	@command -v checkov >/dev/null 2>&1 || pipx install checkov || true
	@command -v terraform >/dev/null 2>&1 || { \
		echo "installing terraform via HashiCorp's official installer..."; \
		wget -q https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip -O /tmp/terraform.zip; \
		unzip -o -q /tmp/terraform.zip -d /tmp/; \
		sudo mv /tmp/terraform /usr/local/bin/ 2>/dev/null || mv /tmp/terraform "$(HOME)/bin/" 2>/dev/null || mkdir -p "$(HOME)/bin" && mv /tmp/terraform "$(HOME)/bin/"; \
	}
	@command -v tflint >/dev/null 2>&1 || { \
		echo "installing tflint via its official install script..."; \
		curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash || true; \
	}
	@if ! command -v tfsec >/dev/null 2>&1 && [ ! -x "$(TFSEC_BIN)" ]; then \
		echo "installing tfsec release binary to $(TFSEC_BIN)..."; \
		mkdir -p "$(HOME)/bin"; \
		curl -sL "https://github.com/aquasecurity/tfsec/releases/latest/download/tfsec-linux-amd64" -o "$(TFSEC_BIN)"; \
		chmod +x "$(TFSEC_BIN)"; \
		echo "NOTE: add $(HOME)/bin to PATH if tfsec is still not found."; \
	fi
else
	@echo "==> Windows (Git Bash) detected - automatic installers target Linux/macOS only."
	@echo "==> Pick one:"
	@echo "==>   A) GitHub Codespaces (zero install): press '.' on the repo page, reopen in Codespace, then 'make setup'."
	@echo "==>   B) WSL2 (Ubuntu): this Makefile then works unmodified."
	@echo "==>   C) Stay on Git Bash - install manually, then re-run 'make setup':"
	@echo "==>      choco install python make terraform -y        (admin PowerShell)"
	@echo "==>      git checkout main -- requirements.txt        (pinned pip tools)"
	@echo "==>      python -m pip install -r requirements.txt    (ansible, ansible-lint, molecule, checkov, yamllint)"
	@echo "==>      tflint + tfsec: download Windows binaries from their GitHub Releases pages."
	@echo "==> Falling through to the PATH check so you can see exactly what is missing..."
endif

## lint: nothing to lint in this lab — the linters themselves are validated by `make setup`.
lint:
	@echo "==> Lab 00 deploys nothing, so there is no code to lint yet."
	@echo "==> Run 'make setup' to verify tflint, ansible-lint, checkov and tfsec are installed."
	@echo "==> They will be used starting from Lab 01."

## test: nothing to test in this lab — Molecule is installed and version-checked by `make setup`.
test:
	@echo "==> Lab 00 has no infrastructure or roles to test."
	@echo "==> Run 'make setup' to verify Molecule is installed; it will be used in the Ansible labs."

## deploy: not applicable — Lab 00 creates no resources.
deploy:
	@echo "==> Nothing to deploy in Lab 00 (it is a toolchain-validation lab)."
	@echo "==> If you expected a deployment, you are probably looking for Lab 01. Run 'make setup' first."

## destroy: not applicable — no resources exist to tear down.
destroy:
	@echo "==> Nothing to destroy — Lab 00 provisions zero cloud resources."
	@echo "==> (Good habit anyway: in later labs always run 'make destroy' when done.)"

## clean: remove transient local artifacts only (never touches installed tools or cloud state).
clean:
	@echo "==> Removing transient files (editor backups, caches)..."
	@rm -f *~ .*.swp 2>/dev/null || true
	@rm -rf __pycache__ .pytest_cache 2>/dev/null || true
	@echo "==> Clean. To uninstall the tools themselves, see the Cleanup section of README.md."
