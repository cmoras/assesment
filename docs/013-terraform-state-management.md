# 013 Terraform State Management

**Decision:** Split Terraform state into separate layers (VPC, EKS, IAM, Secrets) per environment with S3 backend

**Why:** Separating infrastructure into layers reduces blast radius - changes to IAM don't risk VPC destruction. Each layer has isolated state, allowing different teams to manage different components independently. S3 backend with DynamoDB locking prevents state corruption from concurrent operations and provides state versioning for rollback.

**Trade-offs:**
- Pros: Reduced blast radius, faster plan/apply cycles, parallel development, state isolation per component, supports RBAC per layer
- Cons: More complex dependencies (must reference outputs via data sources), longer initial setup, requires careful ordering during deployment, more backend configurations to maintain

**Implementation:** Each layer has separate backend configuration in `infra/terraform/environments/{env}/{layer}/backend.tf`. State files stored as `{env}/{layer}/terraform.tfstate` in S3 bucket. DynamoDB table provides state locking. Layers reference each other via terraform_remote_state data sources (e.g., EKS reads VPC outputs).
