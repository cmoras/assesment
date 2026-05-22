module "eks" {
  source = "../../../modules/eks"

  environment = var.environment
  cluster_name = var.cluster_name

  # Reference VPC outputs from remote state
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  public_subnet_ids  = data.terraform_remote_state.vpc.outputs.public_subnet_ids

  # Node configuration
  node_instance_type = var.node_instance_type
  node_desired_size  = var.node_desired_size
  node_min_size      = var.node_desired_size
  node_max_size      = var.node_desired_size * 2
}
