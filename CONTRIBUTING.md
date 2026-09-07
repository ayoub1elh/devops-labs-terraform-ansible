# Contributing to DevOps Labs

Thanks for helping improve the labs! This document explains how the repository is organized and how to add a new lab.

## Repository Structure

- **`main`** contains only this roadmap (`README.md`), this file, and a placeholder workflow. It never contains lab code.
- **Each lab lives on its own branch** (e.g., `lab-05-aws-free-tier`), branched from `main`.
- Every lab branch is self-contained: its own `README.md`, `Makefile`, `.gitignore`, code, and CI workflow.

## Branch Naming

Branches are always:

```
lab-NN-short-topic-name
```

- `NN` is a zero-padded two-digit number.
- The name is lowercase, hyphen-separated, and describes the topic.
- Existing examples: `lab-03-modules`, `lab-13-tf-ansible-integration`.

## Commit Message Conventions

This repository uses [Conventional Commits](https://www.conventionalcommits.org/). Every commit starts with one of these prefixes:

| Prefix    | Use when                                      | Example |
|-----------|-----------------------------------------------|---------|
| `feat:`   | Adding a new lab or major feature             | `feat: add lab-05 AWS free-tier VPC and EC2` |
| `docs:`   | Adding/updating READMEs, diagrams, instructions | `docs: add architecture diagram for lab-03` |
| `ci:`     | Adding or modifying GitHub Actions workflows  | `ci: add terraform plan workflow for lab-08` |
| `fix:`    | Correcting errors in labs or configs          | `fix: correct security group CIDR block in lab-05` |
| `chore:`  | Tooling, formatting, `.gitignore`, Makefile tweaks | `chore: add terraform lock file to gitignore` |
| `test:`   | Molecule tests, checkov configs, fixtures     | `test: add molecule verify step for lab-12` |

Write commits in the imperative mood (`add`, `fix`, `remove`), keep the subject under 72 characters, and don't end it with a period.

### Per-lab commit pattern

When creating or updating a lab, commit in logical chunks rather than one giant commit:

```bash
git checkout -b lab-18-my-new-lab
# ... create base files: .gitignore, Makefile skeleton, directories
git add .gitignore Makefile
git commit -m "feat: initialize lab-18 with base structure"
# ... create the lab code
git add *.tf roles/ inventory/
git commit -m "feat: add terraform and ansible code for lab-18"
# ... add the workflow (if any)
git add .github/workflows/
git commit -m "ci: add github actions workflow for lab-18"
# ... README always lands last
git add README.md
git commit -m "docs: add README with objectives, steps, and verification"
git push -u origin lab-18-my-new-lab
git checkout main
```

## What Every Lab Must Include

1. **README.md** with:
   - Learning Objectives
   - Architecture diagram (Mermaid)
   - Prerequisites (tools, free accounts, environment variables)
   - Step-by-step instructions
   - Verification steps ("How do I know this worked?")
   - Cleanup steps
   - Troubleshooting (3 common errors with fixes)
   - Free-tier notes / cost warnings where cloud resources are used
2. **Makefile** with the standard targets: `setup`, `lint`, `test`, `deploy`, `destroy`, `clean`
3. **`.gitignore`** appropriate for Terraform and Ansible
4. **Code quality gates**:
   - Terraform passes `terraform fmt` and `terraform validate`
   - Ansible YAML passes `ansible-lint` and `yamllint`
   - No hardcoded secrets — use variables, GitHub Secrets, or Ansible Vault
5. **Free-tier compatibility** — no paid resources, ever

## Updating the Roadmap

When you add a lab, update the checklist in `README.md` on `main` in a separate `docs:` commit.

## Pull Request Checklist

- [ ] Branch named `lab-NN-topic` and based on `main`
- [ ] Conventional commit history in logical chunks
- [ ] `make lint` and `make test` pass on the lab
- [ ] README covers all required sections
- [ ] No secrets, no paid resources
- [ ] Roadmap checkbox updated
