locals {
  oidc_url      = "https://token.actions.githubusercontent.com"
  oidc_jwks_url = "https://token.actions.githubusercontent.com/.well-known/jwks"
  github_org    = "chilledornaments"
  github_repositories = [
    "dog-api",
  ]

  thumbprint_list = var.create_github_actions_resources ? [
    data.tls_certificate.github_actions_oidc_jwks[0].certificates[0].sha1_fingerprint
  ] : []

  client_id_list = ["sts.amazonaws.com"]

  runner_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}

data "aws_caller_identity" "current" {}

data "tls_certificate" "github_actions_oidc_jwks" {
  count = var.create_github_actions_resources ? 1 : 0

  url = local.oidc_jwks_url
}

data "aws_iam_policy_document" "github_actions_runner_assume_role" {
  count = var.create_github_actions_resources ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github[0].arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        for repo in local.github_repositories : "repo:${local.github_org}/${repo}:*"
      ]
    }
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_github_actions_resources ? 1 : 0

  url             = local.oidc_url
  client_id_list  = local.client_id_list
  thumbprint_list = local.thumbprint_list

}

resource "aws_iam_role" "runner" {
  count = var.create_github_actions_resources ? 1 : 0

  name                 = "dog-api-gha-runner-oidc"
  description          = "GitHub Actions runner OIDC for dog-api project"
  assume_role_policy   = data.aws_iam_policy_document.github_actions_runner_assume_role[0].json
  max_session_duration = 3600 // 3600 is minimum
}

resource "aws_iam_role_policy_attachment" "runner" {
  for_each = var.create_github_actions_resources ? toset(local.runner_policy_arns) : []

  role       = aws_iam_role.runner[0].id
  policy_arn = each.value
}
