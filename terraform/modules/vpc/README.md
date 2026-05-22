# VPC Module

Creates a VPC with public and private subnets across multiple availability zones.

## Features

- VPC with configurable CIDR block
- Public subnets (for NAT gateways, load balancers)
- Private subnets with /19 CIDR (8,192 IPs for VPC CNI scaling)
- Internet Gateway
- NAT Gateways (1 per AZ for HA, or single for cost savings)
- Route tables (public → IGW, private → NAT)
- VPC Flow Logs to CloudWatch

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  environment          = "dev"
  vpc_cidr             = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/19", "10.0.12.0/19"]
  enable_nat_gateway   = true
  single_nat_gateway   = false  # HA: one NAT per AZ
  enable_flow_logs     = true
}
```

## Design Decisions

- **Private subnets use /19 CIDR:** Provides 8,192 IPs per subnet for VPC CNI. AWS VPC CNI assigns subnet IPs directly to pods (not a separate pod CIDR). t3.medium nodes run ~17 pods each consuming a subnet IP. /24 (256 IPs) exhausts quickly in production.

- **NAT Gateway per AZ (HA mode):** Provides high availability. If one AZ fails, other AZs continue to have internet access. Set `single_nat_gateway = true` for cost savings (~$32/month vs ~$65/month).

- **Subnet tags for EKS:** Public subnets tagged with `kubernetes.io/role/elb = 1` for ALB/NLB placement. Private subnets tagged with `kubernetes.io/role/internal-elb = 1` for internal load balancers.

## Inputs

See `variables.tf`

## Outputs

See `outputs.tf`
