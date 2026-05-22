# Remote state data source for EKS outputs
data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../eks/terraform.tfstate"
  }
}

# Remote state data source for Secrets Manager outputs
data "terraform_remote_state" "secrets" {
  backend = "local"

  config = {
    path = "../secrets-manager/terraform.tfstate"
  }
}

# For S3 backend (uncomment when migrating):
# data "terraform_remote_state" "eks" {
#   backend = "s3"
#
#   config = {
#     bucket = "your-terraform-state-bucket"
#     key    = "environments/dev/eks/terraform.tfstate"
#     region = "us-east-1"
#   }
# }
#
# data "terraform_remote_state" "secrets" {
#   backend = "s3"
#
#   config = {
#     bucket = "your-terraform-state-bucket"
#     key    = "environments/dev/secrets-manager/terraform.tfstate"
#     region = "us-east-1"
#   }
# }
