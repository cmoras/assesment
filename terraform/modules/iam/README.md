# IAM Module for IRSA (IAM Roles for Service Accounts)

This module creates an IAM role that can be assumed by Kubernetes service accounts in an EKS cluster using IRSA (IAM Roles for Service Accounts).

## IRSA Pattern

IRSA allows Kubernetes pods to assume AWS IAM roles without requiring AWS credentials to be stored in the cluster. This is achieved through:

1. **OIDC Identity Provider**: EKS creates an OIDC provider that acts as an identity broker
2. **Trust Policy**: The IAM role's trust policy allows the OIDC provider to assume the role
3. **Service Account Annotation**: The Kubernetes service account is annotated with the IAM role ARN
4. **Automatic Token Injection**: EKS injects a web identity token into pods using the service account

## Trust Policy Structure

The trust policy uses two conditions to enforce least-privilege access:

1. **Subject Condition** (`oidc_provider_url:sub`):
   - Restricts role assumption to a specific namespace and service account
   - Format: `system:serviceaccount:<namespace>:<service-account-name>`
   - Prevents other service accounts from assuming the role

2. **Audience Condition** (`oidc_provider_url:aud`):
   - Validates the token is intended for AWS STS
   - Value: `sts.amazonaws.com`
   - Prevents token reuse for other purposes

## Least-Privilege Principle

This module enforces least-privilege access:

- Role can only be assumed by the specific namespace + service account combination
- Secrets Manager policy grants access to a single secret ARN (not wildcards)
- Only the minimum required actions are granted (GetSecretValue, DescribeSecret)

## Usage Example

```hcl
module "app_irsa" {
  source = "./modules/iam"

  cluster_name         = "my-eks-cluster"
  oidc_provider_arn    = module.eks.oidc_provider_arn
  oidc_provider_url    = module.eks.oidc_provider_url
  secret_arn           = module.secrets.secret_arn
  namespace            = "default"
  service_account_name = "app-service-account"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

Then annotate your Kubernetes service account:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-service-account
  namespace: default
  annotations:
    eks.amazonaws.com/role-arn: <module.app_irsa.irsa_role_arn>
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| cluster_name | Name of the EKS cluster | string | yes |
| oidc_provider_arn | ARN of the EKS OIDC provider | string | yes |
| oidc_provider_url | URL of the EKS OIDC provider (without https://) | string | yes |
| secret_arn | ARN of the secret that the role can access | string | yes |
| namespace | Kubernetes namespace for the service account | string | yes |
| service_account_name | Name of the Kubernetes service account | string | yes |
| tags | Tags to apply to resources | map(string) | no |

## Outputs

| Name | Description |
|------|-------------|
| irsa_role_arn | ARN of the IAM role for service account |
| irsa_role_name | Name of the IAM role for service account |
