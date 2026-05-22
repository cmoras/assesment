module "vpc" {
  source = "../../../modules/vpc"

  environment = var.environment
  vpc_cidr    = var.vpc_cidr

  # Use defaults for other variables (azs, subnet_cidrs, etc.)
  # Can be overridden if needed in future
}
