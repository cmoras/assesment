module "iam" {
  source = "../../../modules/iam"

  cluster_name = var.cluster_name

  # Reference EKS OIDC provider from remote state
  oidc_provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn
  oidc_provider_url = data.terraform_remote_state.eks.outputs.oidc_provider_url

  # Reference secret ARN from remote state
  secret_arn = data.terraform_remote_state.secrets.outputs.secret_arn

  # Service account configuration
  namespace            = var.namespace
  service_account_name = var.service_account_name
}
