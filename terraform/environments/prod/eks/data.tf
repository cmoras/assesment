# Remote state data source for VPC outputs
# Comment this out if VPC state is not yet available and use direct values instead
data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../vpc/terraform.tfstate"
  }
}

# For S3 backend (uncomment when migrating):
# data "terraform_remote_state" "vpc" {
#   backend = "s3"
#
#   config = {
#     bucket = "your-terraform-state-bucket"
#     key    = "environments/dev/vpc/terraform.tfstate"
#     region = "us-east-1"
#   }
# }
