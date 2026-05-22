# Secrets Manager Module

This module creates an AWS Secrets Manager secret with an initial placeholder value. Secrets Manager provides secure storage, rotation, and auditing of sensitive application configuration data.

## Secret Rotation Strategy

AWS Secrets Manager supports automatic secret rotation through multiple approaches:

### 1. AWS Lambda Rotation

AWS provides Lambda rotation functions for supported services (RDS, DocumentDB, Redshift). For custom rotation:

```hcl
resource "aws_secretsmanager_secret_rotation" "example" {
  secret_id           = aws_secretsmanager_secret.this.id
  rotation_lambda_arn = aws_lambda_function.rotation.arn

  rotation_rules {
    automatically_after_days = 30
  }
}
```

The Lambda function must:
- Create a new secret version (createSecret)
- Set the new version (setSecret)
- Test the new version (testSecret)
- Finalize the rotation (finishSecret)

### 2. External Secrets Operator (Kubernetes)

For EKS environments, External Secrets Operator syncs secrets from AWS Secrets Manager to Kubernetes:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-config
  namespace: default
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
    kind: SecretStore
  target:
    name: app-config-k8s
    creationPolicy: Owner
  data:
    - secretKey: config.json
      remoteRef:
        key: app-config
```

Benefits:
- Automatic sync to Kubernetes secrets
- No application code changes required
- Centralized secret management

### 3. Reloader (Kubernetes)

Reloader watches for secret changes and triggers pod restarts:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    reloader.stakater.com/auto: "true"
spec:
  template:
    spec:
      containers:
        - name: app
          envFrom:
            - secretRef:
                name: app-config-k8s
```

When secrets change, Reloader automatically restarts pods to pick up new values.

## Updating Secrets

### Manual Update via AWS CLI

```bash
aws secretsmanager update-secret \
  --secret-id app-config \
  --secret-string '{"key": "new-value"}'
```

### Terraform Update

Update the secret value in Terraform (not recommended for production secrets):

```hcl
resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    database_url = "postgresql://..."
    api_key      = "prod-key-123"
  })
}
```

**Best Practice**: Manage secret values outside Terraform to avoid storing sensitive data in state files. Use Terraform to create the secret resource, then populate values via AWS CLI or console.

## Usage Example

```hcl
module "app_secrets" {
  source = "./modules/secrets"

  environment = "production"
  secret_name = "prod-app-config"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Application = "data-pipeline"
  }
}

# After applying, update the secret value:
# aws secretsmanager update-secret \
#   --secret-id prod-app-config \
#   --secret-string '{"db_host": "prod-db.example.com", "api_key": "xyz"}'
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| environment | Environment name (e.g., dev, staging, production) | string | yes |
| secret_name | Name of the secret in AWS Secrets Manager | string | yes |
| tags | Tags to apply to resources | map(string) | no |

## Outputs

| Name | Description |
|------|-------------|
| secret_arn | ARN of the secret |
| secret_name | Name of the secret |
| secret_id | ID of the secret |

## Security Considerations

- Secrets are encrypted at rest using AWS KMS
- Access should be granted via IAM policies with least-privilege principle
- Enable CloudTrail logging to audit secret access
- Use VPC endpoints for private access from EKS
- Rotate secrets regularly (recommended: every 30-90 days)
