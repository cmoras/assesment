# 002 IRSA Implementation

**Decision:** Use IAM Roles for Service Accounts (IRSA) for pod-level AWS permissions instead of node IAM roles.

**Why:** Node IAM roles grant all pods on a node the same permissions, violating least-privilege security. IRSA leverages EKS's OIDC provider to let pods assume specific IAM roles via Kubernetes service accounts. This provides fine-grained, pod-level AWS access control without requiring static credentials or IMDSv2 access.

**Trade-offs:**
- Pros: Least-privilege access per workload, no shared credentials on nodes, automatic credential rotation, audit trail via CloudTrail showing exact pod identity, prevents lateral movement if pod is compromised
- Cons: Requires OIDC provider setup, slightly more complex than node roles, debugging requires understanding IAM trust policy, 1-hour STS token TTL

**Implementation:** EKS OIDC provider created during cluster setup. Pipeline service account in platform/k8s/overlays/dev/sa.yaml annotated with IAM role ARN. Trust policy in infra/terraform/modules/iam allows eks.amazonaws.com principal to assume role. Pod uses AWS SDK with default credential chain to auto-discover IRSA token.
