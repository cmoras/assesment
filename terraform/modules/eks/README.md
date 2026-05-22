# EKS Module

Creates an Amazon EKS cluster with managed node groups.

## Features

- EKS cluster with configurable Kubernetes version
- Public + Private endpoint access
- Managed node group in private subnets
- OIDC provider for IRSA (IAM Roles for Service Accounts)
- Security groups for cluster and nodes
- EKS addons (VPC CNI, kube-proxy, CoreDNS) with version pinning
- CloudWatch logging enabled

## Usage

```hcl
module "eks" {
  source = "../../modules/eks"

  environment  = "dev"
  cluster_name = "data-pipeline-dev"
  vpc_id       = module.vpc.vpc_id

  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids

  cluster_endpoint_public_access        = true
  cluster_endpoint_private_access       = true
  cluster_endpoint_public_access_cidrs  = ["0.0.0.0/0"]

  node_instance_type = "t3.medium"
  node_desired_size  = 2
  node_min_size      = 2
  node_max_size      = 4
}
```

## Design Decisions

- **Public + Private endpoint access:** External tools (GitHub Actions, developers) use public endpoint. Internal cluster traffic (pods, controllers) uses private endpoint and stays within VPC. More secure and performant than public-only.

- **Public endpoint CIDR:** Set to `0.0.0.0/0` for assignment simplicity. Production would restrict to GitHub Actions IP ranges or use OIDC federation for authentication without IP restrictions.

- **OIDC provider:** Enables IRSA (IAM Roles for Service Accounts) for secure pod-to-AWS authentication without static credentials.

- **EKS addons version-pinned:** Prevents unexpected upgrades. Update intentionally via Terraform.

- **Nodes in private subnets:** More secure. Nodes access internet via NAT gateway.

## Inputs

See `variables.tf`

## Outputs

See `outputs.tf`
