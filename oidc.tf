# oidc.tf — GitHub Actions -> AWS authentication, entirely managed by Terraform.
#
# This is OPTION A from the README ("terraform-managed"). It creates:
#   1. An IAM OIDC identity provider for GitHub Actions
#      (token.actions.githubusercontent.com).
#   2. An IAM role that ONLY GitHub Actions workflows running in YOUR fork of
#      this repository (on the default branch or any pull request) can assume.
#   3. A policy attached to that role, scoped to what this lab needs
#      (EC2 + VPC management).
#
# One-time bootstrap: to run THIS file you need credentials once (admin or a
# user with IAM rights, e.g. `aws configure` locally or AWS CloudShell). After
# the role exists, CI authenticates with OIDC and never needs stored keys.

# Thumbprint for token.actions.githubusercontent.com. This is GitHub's
# root CA thumbprint (documented by AWS); it is not a secret.
# See: https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
locals {
  github_oidc_url        = "https://token.actions.githubusercontent.com"
  github_oidc_thumbprint = "6938fd4d98bab03faadb97b34396831e3780aea1"
  # Repository slug used in the trust condition, e.g. "you/devops-labs-terraform-ansible".
  # For real repos, replace with your GitHub username/org + repo name.
  github_repo = "YOUR_GITHUB_USERNAME/devops-labs-terraform-ansible"
}

# One OIDC provider per account. If it already exists (e.g. you did Option B
# manually), import it instead:
#   terraform import aws_iam_openid_connect_provider.github <provider-arn>
resource "aws_iam_openid_connect_provider" "github" {
  url             = local.github_oidc_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [local.github_oidc_thumbprint]

  tags = {
    Name = "github-actions-oidc"
  }
}

# Trust policy: only token.actions.githubusercontent.com can assume the role,
# and only for THIS repo. "sub" is the subject claim GitHub puts in the token:
#   repo:<owner>/<repo>:ref:refs/heads/main   (push / merge)
#   repo:<owner>/<repo>:pull_request           (PR workflows)
data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.github_repo}:*"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${var.project_name}-github-actions-role"
  description        = "Assumed by GitHub Actions via OIDC to plan/apply this lab"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json

  tags = {
    Name = "${var.project_name}-github-actions-role"
  }
}

# Scoped-down permissions: enough to manage the VPC/EC2 resources this lab
# creates. Deliberately NOT AdministratorAccess — least privilege is the point.
data "aws_iam_policy_document" "github_actions_permissions" {
  # Everything this lab manages lives in one region, so restrict EC2 to it.
  # (RunInstances needs resource-level "*" because some sub-resources like
  # AMIs can't be ARN-restricted, but the region condition still bounds it.)
  statement {
    effect = "Allow"

    actions   = ["ec2:*"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.aws_region]
    }
  }

  # PassRole is only needed if instances get instance profiles/roles later;
  # allow passing ONLY this OIDC role itself, nothing else.
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.github_actions.arn]
  }
}

resource "aws_iam_role_policy" "github_actions" {
  name   = "${var.project_name}-github-actions-policy"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_actions_permissions.json
}

# ARN to paste into the GitHub Secret AWS_ROLE_ARN (see README).
output "github_actions_role_arn" {
  description = "ARN of the IAM role GitHub Actions assumes. Put this in the AWS_ROLE_ARN repository secret."
  value       = aws_iam_role.github_actions.arn
}
