# AI Attribution Block: AI-assisted Terraform outputs definition.
# Outputs key cluster identifiers, networking attributes, and IAM role ARNs.

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = aws_subnet.database[*].id
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.eks_cluster.id
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider for EKS IRSA"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "workload_role_arn" {
  description = "IAM Role ARN for ForgePay Kubernetes ServiceAccount"
  value       = aws_iam_role.workload_role.arn
}

output "github_actions_role_arn" {
  description = "IAM Role ARN for GitHub Actions OIDC CI/CD"
  value       = aws_iam_role.github_actions.arn
}
