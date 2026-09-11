# AI Attribution Block: AI-assisted variable definitions for ForgePay EKS infrastructure.
# All variables define configurable parameters for the target AWS deployment.

variable "aws_region" {
  description = "AWS region for ForgePay infrastructure deployment"
  type        = string
  default     = "ap-south-1"

  validation {
    condition     = can(regex("^(ap|us|eu)-(south|north|east|west|central|southeast|northeast)-[0-9]+$", var.aws_region))
    error_message = "AWS region must be a valid region identifier."
  }
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production."
  }
}

variable "project_name" {
  description = "Project identifier used for resource naming and tagging"
  type        = string
  default     = "forgepay"
}

# --- VPC Configuration ---

variable "vpc_cidr" {
  description = "CIDR block for the ForgePay VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones for multi-AZ deployment"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for isolated database subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
}

# --- EKS Configuration ---

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "eks_node_instance_types" {
  description = "EC2 instance types for EKS managed node groups"
  type        = list(string)
  default     = ["m6i.large", "m6i.xlarge"]
}

variable "eks_node_min_size" {
  description = "Minimum number of nodes in the EKS managed node group"
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Maximum number of nodes in the EKS managed node group"
  type        = number
  default     = 10
}

variable "eks_node_desired_size" {
  description = "Desired number of nodes in the EKS managed node group"
  type        = number
  default     = 3
}

# --- Database Configuration ---

variable "rds_instance_class" {
  description = "RDS instance class for PostgreSQL 16"
  type        = string
  default     = "db.r6g.large"
}

variable "rds_multi_az" {
  description = "Enable Multi-AZ deployment for RDS"
  type        = bool
  default     = true
}

variable "rds_backup_retention_period" {
  description = "Number of days to retain RDS automated backups"
  type        = number
  default     = 30
}

# --- GitHub Actions OIDC ---

variable "github_org" {
  description = "GitHub organization name for OIDC federation"
  type        = string
  default     = "forgepay-org"
}

variable "github_repo" {
  description = "GitHub repository name for OIDC federation"
  type        = string
  default     = "forgepay"
}
