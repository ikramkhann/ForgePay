# AI Attribution Block: AI-assisted Terraform IAM and OIDC workload identity configuration.
# Defines IAM OIDC Provider for EKS, IAM Roles for Service Accounts (IRSA),
# and GitHub Actions federated OIDC credentials for passwordless CI/CD.

# --- TLS Certificate for EKS OIDC Provider ---

data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-oidc"
  }
}

# --- Workload IAM Role (IRSA: forgepay-serviceaccount) ---

data "aws_iam_policy_document" "workload_irsa_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.project_name}:${var.project_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "workload_role" {
  name               = "${var.project_name}-${var.environment}-workload-role"
  assume_role_policy = data.aws_iam_policy_document.workload_irsa_assume.json

  tags = {
    Name = "${var.project_name}-${var.environment}-workload-role"
  }
}

# --- Least Privilege Policy for Workload ---

data "aws_iam_policy_document" "workload_policy" {
  statement {
    sid    = "KMSDecryptOnly"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.eks.arn]
  }

  statement {
    sid    = "DenyDirectDatabaseAdministration"
    effect = "Deny"
    actions = [
      "rds:DeleteDBInstance",
      "rds:ModifyDBInstance",
      "rds:RebootDBInstance"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "workload" {
  name        = "${var.project_name}-${var.environment}-workload-policy"
  description = "Scoped policy for ForgePay Spring Boot application runtime"
  policy      = data.aws_iam_policy_document.workload_policy.json
}

resource "aws_iam_role_policy_attachment" "workload" {
  role       = aws_iam_role.workload_role.name
  policy_arn = aws_iam_policy.workload.arn
}

# --- GitHub Actions OIDC Provider ---

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f8d2649e73"]

  tags = {
    Name = "${var.project_name}-github-oidc"
  }
}

# --- GitHub Actions CI/CD IAM Role ---

data "aws_iam_policy_document" "github_actions_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org}/${var.github_repo}:*"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.github.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${var.project_name}-${var.environment}-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume.json

  tags = {
    Name = "${var.project_name}-${var.environment}-github-actions-role"
  }
}

# --- GitHub Actions ECR Publish-Only Policy ---

data "aws_iam_policy_document" "github_actions_ecr" {
  statement {
    sid    = "ECRAuthToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPushScoped"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    resources = ["arn:aws:ecr:${var.aws_region}:*:repository/${var.project_name}"]
  }
}

resource "aws_iam_policy" "github_actions_ecr" {
  name        = "${var.project_name}-${var.environment}-github-actions-ecr-policy"
  description = "Scoped ECR publish policy for GitHub Actions CI/CD"
  policy      = data.aws_iam_policy_document.github_actions_ecr.json
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ecr.arn
}
