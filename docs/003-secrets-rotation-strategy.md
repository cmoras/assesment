# 003 Secrets Rotation Strategy

**Decision:** Use AWS Secrets Manager with automatic rotation enabled for database credentials and API keys.

**Why:** Hardcoded secrets in config files or environment variables create security risks and make rotation difficult. Secrets Manager provides encrypted storage, automatic rotation via Lambda, and audit logging. Combined with External Secrets Operator in Kubernetes, secrets sync automatically to pods without manual updates or pod restarts.

**Trade-offs:**
- Pros: Automatic rotation reduces credential compromise window, centralized secret management, encrypted at rest with KMS, audit trail of secret access, no secrets in Git or container images
- Cons: Additional AWS service costs ($0.40/secret/month + API calls), introduces dependency on AWS service availability, slightly slower pod startup due to secret fetch, requires External Secrets Operator

**Implementation:** Secrets created in infra/terraform/modules/secrets-manager with rotation enabled (30-90 day intervals). External Secrets Operator deployed in platform/k8s/base/external-secrets with ClusterSecretStore configured for AWS provider. ExternalSecret resources reference Secrets Manager ARNs and sync to Kubernetes Secrets mounted as volumes or environment variables.
