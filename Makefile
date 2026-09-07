# ---------------------------------------------------------------------------
# Makefile — Standard lab targets for Lab 07 (Security Scanning).
#
#   make setup    Verify the required tools are installed
#   make lint     terraform fmt + tflint (local version of CI step 1 & 2)
#   make test     checkov + tfsec (local version of CI step 3 & 4)
#   make deploy   terraform init/plan/apply — creates the AWS resources
#   make destroy  terraform destroy — tears everything down
#   make clean    Remove local Terraform artifacts (never touches the cloud)
# ---------------------------------------------------------------------------

.PHONY: setup lint test deploy destroy clean

## setup: Verify that all required tools are installed and print versions.
setup:
	@echo "Checking required tools for Lab 07..."
	@command -v terraform >/dev/null && terraform version || echo "MISSING: terraform (see README Prerequisites)"
	@command -v tflint >/dev/null && tflint --version || echo "MISSING: tflint"
	@command -v checkov >/dev/null && checkov --version || echo "MISSING: checkov (pip install checkov)"
	@command -v tfsec >/dev/null && tfsec --version || echo "MISSING: tfsec"
	@command -v aws >/dev/null && aws --version || echo "MISSING: awscli (only needed for make deploy)"
	@echo "Setup check complete."

## lint: Run terraform fmt check and tflint (mirrors CI steps 1 and 2).
lint:
	@echo "Running terraform fmt -check -recursive ..."
	terraform fmt -check -recursive
	@echo "Running tflint ..."
	tflint --init
	tflint --format=compact --recursive
	@echo "Lint passed."

## test: Run checkov and tfsec (mirrors CI steps 3 and 4).
test:
	@echo "Running checkov (soft-fail via checkov-config.yml) ..."
	checkov -d . --config-file checkov-config.yml
	@echo "Running tfsec (soft-fail so findings don't fail the build) ..."
	tfsec --soft-fail .
	@echo "Security scans complete — review findings above."

## deploy: Create the AWS free-tier stack (requires AWS credentials in env).
deploy:
	@echo "Deploying Lab 07 stack (t2.micro, free tier)..."
	terraform init
	terraform plan -out=tfplan
	terraform apply tfplan
	@echo "Deploy complete. See 'instance_public_ip' in the outputs above."

## destroy: Tear down every resource this lab created. Guarded: requires typing 'yes'.
destroy:
	@echo "This will permanently delete all Lab 07 AWS resources."
	@read -p "Type 'yes' to continue: " confirm && [ "$$confirm" = "yes" ] || { echo "Aborted."; exit 1; }
	terraform destroy

## clean: Remove local artifacts only (.terraform, plans). Cloud resources are untouched.
clean:
	@echo "Removing local artifacts (.terraform/, tfplan, lock file)..."
	rm -rf .terraform tfplan .terraform.lock.hcl
	@echo "Local artifacts removed. Run 'make destroy' to remove cloud resources."
