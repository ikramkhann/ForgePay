# ForgePay Infrastructure as Code (Terraform)

## AI Attribution Block

AI-assisted Terraform infrastructure specification. All HCL declarations, resource topologies, CIDR blocks, IAM role definitions, and cluster parameters describe target AWS EKS and networking architecture for ForgePay. No live AWS resources are claimed to be provisioned. Static review of HCL manifests reflects designed compliance with RBI and PCI-DSS v4.0 boundaries.

---

## Overview

The `pipeline/terraform/` directory contains the complete modular Infrastructure-as-Code (IaC) configuration for deploying ForgePay's underlying AWS foundation, including:

1. **Multi-AZ VPC Network:** 3 Availability Zones, public ingress subnets, private worker subnets, and air-gapped database subnets.
2. **Amazon EKS Cluster v1.29:** Dedicated Kubernetes control plane with private-only endpoint access, KMS envelope encryption for Secrets, and managed node groups.
3. **IAM & Workload Identity Federation:**
   - **IRSA (IAM Roles for Service Accounts):** Fine-grained, temporary AWS STS credentials for ForgePay microservices without embedded access keys.
   - **GitHub Actions OIDC:** Keyless CI/CD authentication via AWS STS `AssumeRoleWithWebIdentity`.
4. **Isolated PostgreSQL Database Subnets:** Dedicated network perimeter for PostgreSQL 16 Multi-AZ deployment without route to Internet Gateways or NAT.

---

## File Structure

```
pipeline/terraform/
├── main.tf          # Provider configurations (AWS, Kubernetes, Helm) and S3 remote backend
├── variables.tf     # Configurable input variables with validation constraints
├── vpc.tf           # VPC, subnets, route tables, Internet Gateway, and NAT Gateways
├── eks.tf           # EKS Cluster, KMS key, control plane logging, and managed node group
├── iam.tf           # OIDC providers, IRSA workload role, and GitHub Actions CI role
├── outputs.tf       # Exported cluster endpoints, subnets, and IAM role ARNs
└── README.md        # Architecture overview and validation status
```

---

## Network Architecture

```
VPC: 10.0.0.0/16 (ap-south-1)
├── AZ ap-south-1a
│   ├── Public Subnet (10.0.101.0/24)  -> NAT Gateway A, Internet Gateway
│   ├── Private Subnet (10.0.1.0/24)   -> EKS Worker Nodes (outbound via NAT A)
│   └── Database Subnet (10.0.201.0/24)-> PostgreSQL 16 (Isolated, no IGW/NAT)
├── AZ ap-south-1b
│   ├── Public Subnet (10.0.102.0/24)  -> NAT Gateway B, Internet Gateway
│   ├── Private Subnet (10.0.2.0/24)   -> EKS Worker Nodes (outbound via NAT B)
│   └── Database Subnet (10.0.202.0/24)-> PostgreSQL 16 Standby (Isolated)
└── AZ ap-south-1c
    ├── Public Subnet (10.0.103.0/24)  -> NAT Gateway C, Internet Gateway
    ├── Private Subnet (10.0.3.0/24)   -> EKS Worker Nodes (outbound via NAT C)
    └── Database Subnet (10.0.203.0/24)-> Witness / Backup (Isolated)
```

---

## Security & Compliance Controls

| Control | Implementation | Regulatory Standard |
| :--- | :--- | :--- |
| **KMS Envelope Encryption** | Customer Managed Key (CMK) encrypts all Kubernetes Secrets at rest | PCI-DSS v4.0 Req 3.4, RBI Cyber Security Framework |
| **Zero Long-Lived Keys** | GitHub Actions & EKS Pods authenticate via OIDC token exchange | RBI Master Direction Sec 4.1 |
| **Private Control Plane** | `endpoint_public_access = false` restricts API server to private VPC | CIS AWS Benchmark 5.4.1 |
| **Air-Gapped Database** | Database subnets have no default route (`0.0.0.0/0`) to NAT or IGW | PCI-DSS v4.0 Req 1.3 |
| **Multi-AZ High Availability** | 3 AZs for worker nodes, NAT gateways, and database subnets | RBI Business Continuity Plan (BCP) requirements |

---

## Validation Status

- **HCL Syntax & Formatting:** Formatted in standard HashiCorp HCL syntax.
- **Terraform CLI Validation:** Not executed locally (the `terraform` binary is not installed in this execution environment; recorded in platform evidence classification as *Designed / Statically Specified*).
