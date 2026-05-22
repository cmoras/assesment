module "secrets" {
  source = "../../../modules/secrets"

  environment = var.environment
  secret_name = var.secret_name
}
