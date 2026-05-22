# Local backend for development
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Uncomment and configure for production use:
# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "environments/dev/eks/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }
#
# Migration instructions:
# 1. Uncomment the S3 backend configuration above
# 2. Update bucket name and region
# 3. Run: terraform init -migrate-state
# 4. Confirm state migration when prompted
# 5. Comment out or remove local backend configuration
