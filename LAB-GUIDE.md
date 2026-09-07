# Lab Workflow Guide

This guide is **just the git mechanics** for working through the labs — it contains no solutions. Each lab's `README.md` on its branch is the actual instructions.

## The Loop (read once, reuse forever)

Every lab follows the same rhythm:

1. **Switch to the lab branch** (from `main`)
2. **Do the lab** — follow that branch's `README.md` (usually `make setup` → edit/run per steps → `make deploy` → verify → `make destroy`)
3. **Commit your work** on the lab branch (optional but recommended — it's your progress tracker)
4. **Push** the lab branch (triggers its CI workflow — that's your grader)
5. **Switch back to `main`** before the next lab

Prereqs once, on `main`:

```bash
# Python tooling for the Ansible/security labs (Terraform/tflint/tfsec install separately — see lab-00)
python3 -m pip install -r requirements.txt
```

> Committing/pushing your lab work is safe: each lab lives on its own branch, so your commits never interfere with other labs or with `main`.

---

## Lab 00 — Setup

```bash
git checkout main && git pull
git checkout lab-00-setup
# do the lab: make setup, follow README.md
git add -A && git commit -m "feat: complete lab-00-setup" && git push origin lab-00-setup
git checkout main
```

## Lab 01 — Docker Provider

```bash
git checkout main && git pull
git checkout lab-01-docker-provider
# do the lab: make setup, terraform init/plan/apply, follow README.md
git add -A && git commit -m "feat: complete lab-01-docker-provider" && git push origin lab-01-docker-provider
git checkout main
```

## Lab 02 — Variables & Outputs

```bash
git checkout main && git pull
git checkout lab-02-variables-outputs
# do the lab: cp terraform.tfvars.example terraform.tfvars, then apply — follow README.md
git add -A && git commit -m "feat: complete lab-02-variables-outputs" && git push origin lab-02-variables-outputs
git checkout main
```

## Lab 03 — Modules

```bash
git checkout main && git pull
git checkout lab-03-modules
# do the lab: apply, verify blue/green containers — follow README.md
git add -A && git commit -m "feat: complete lab-03-modules" && git push origin lab-03-modules
git checkout main
```

## Lab 04 — State Backends

```bash
git checkout main && git pull
git checkout lab-04-state-backends
# do the lab: terraform login, edit backend.tf org, init -migrate-state — follow README.md
git add -A && git commit -m "feat: complete lab-04-state-backends" && git push origin lab-04-state-backends
git checkout main
```

## Lab 05 — AWS Free Tier

```bash
git checkout main && git pull
git checkout lab-05-aws-free-tier
# do the lab: set AWS env vars, terraform apply, curl the IP — follow README.md
# IMPORTANT: make destroy when done, then check AWS Billing
git add -A && git commit -m "feat: complete lab-05-aws-free-tier" && git push origin lab-05-aws-free-tier
git checkout main
```

## Lab 06 — Workspaces

```bash
git checkout main && git pull
git checkout lab-06-workspaces
# do the lab: terraform workspace new dev / select / apply — follow README.md
git add -A && git commit -m "feat: complete lab-06-workspaces" && git push origin lab-06-workspaces
git checkout main
```

## Lab 07 — Security Scanning

```bash
git checkout main && git pull
git checkout lab-07-security-scanning
# do the lab: push and read the checkov/tfsec findings — follow README.md
git add -A && git commit -m "feat: complete lab-07-security-scanning" && git push origin lab-07-security-scanning
git checkout main
```

## Lab 08 — Terraform CI/CD

```bash
git checkout main && git pull
git checkout lab-08-terraform-cicd
# do the lab: create OIDC provider + role, set AWS_ROLE_ARN secret — follow README.md
git add -A && git commit -m "feat: complete lab-08-terraform-cicd" && git push origin lab-08-terraform-cicd
git checkout main
```

## Lab 09 — Ansible Basics

```bash
git checkout main && git pull
git checkout lab-09-ansible-basics
# do the lab: make ping, ad-hoc commands — follow README.md
git add -A && git commit -m "feat: complete lab-09-ansible-basics" && git push origin lab-09-ansible-basics
git checkout main
```

## Lab 10 — Playbooks

```bash
git checkout main && git pull
git checkout lab-10-playbooks
# do the lab: run site.yml with --check first — follow README.md
git add -A && git commit -m "feat: complete lab-10-playbooks" && git push origin lab-10-playbooks
git checkout main
```

## Lab 11 — Roles

```bash
git checkout main && git pull
git checkout lab-11-roles
# do the lab: run site.yml using the webserver role — follow README.md
git add -A && git commit -m "feat: complete lab-11-roles" && git push origin lab-11-roles
git checkout main
```

## Lab 12 — Molecule Testing

```bash
git checkout main && git pull
git checkout lab-12-molecule-testing
# do the lab: molecule converge/verify/test in roles/webserver — follow README.md
git add -A && git commit -m "feat: complete lab-12-molecule-testing" && git push origin lab-12-molecule-testing
git checkout main
```

## Lab 13 — Terraform → Ansible Integration

```bash
git checkout main && git pull
git checkout lab-13-tf-ansible-integration
# do the lab: make all (terraform apply -> ansible-playbook) — follow README.md
git add -A && git commit -m "feat: complete lab-13-tf-ansible-integration" && git push origin lab-13-tf-ansible-integration
git checkout main
```

## Lab 14 — Dynamic Inventory

```bash
git checkout main && git pull
git checkout lab-14-dynamic-inventory
# do the lab: install collection, ansible-inventory --graph — follow README.md
git add -A && git commit -m "feat: complete lab-14-dynamic-inventory" && git push origin lab-14-dynamic-inventory
git checkout main
```

## Lab 15 — Ansible Vault

```bash
git checkout main && git pull
git checkout lab-15-ansible-vault
# do the lab: ansible-vault create/edit, set ANSIBLE_VAULT_PASSWORD secret — follow README.md
git add -A && git commit -m "feat: complete lab-15-ansible-vault" && git push origin lab-15-ansible-vault
git checkout main
```

## Lab 16 — Ansible CI/CD

```bash
git checkout main && git pull
git checkout lab-16-ansible-cicd
# do the lab: open a PR (lint runs), merge (deploy runs) — follow README.md
git add -A && git commit -m "feat: complete lab-16-ansible-cicd" && git push origin lab-16-ansible-cicd
git checkout main
```

## Lab 17 — Full DevOps Pipeline

```bash
git checkout main && git pull
git checkout lab-17-full-devops-pipeline
# do the lab: set secrets, push, watch terraform -> ansible -> smoke-test jobs — follow README.md
git add -A && git commit -m "feat: complete lab-17-full-devops-pipeline" && git push origin lab-17-full-devops-pipeline
git checkout main
```

---

## Tips

- **Stuck mid-lab?** `git status` and the branch README's Troubleshooting section first. To abandon your changes and start the lab fresh: `git checkout . && git clean -fd` (on the lab branch) — the original lab code returns.
- **Your commits are progress markers, not deliverables.** A one-line `feat: complete lab-NN` commit per lab keeps your history honest; use `fix:` if you repair something.
- **AWS labs (05, 06, 13, 14, 17):** always `make destroy`, then glance at the AWS Billing console. Free tier is 750 EC2 hours/month total.
- **Track progress** by checking boxes in `README.md` on `main` (commit those to `main` with `docs: check off lab-NN`).
