# 006 VPC CNI Configuration

**Decision:** Use AWS VPC CNI as a managed EKS addon with version pinning

**Why:** AWS VPC CNI is the default networking plugin for EKS and provides native AWS integration. Pods receive IP addresses directly from VPC subnets, enabling seamless communication with other AWS services without NAT. Managed addon ensures AWS handles security patches and compatibility updates.

**Trade-offs:**
- Pros: Native AWS integration, no overlay network complexity, direct pod-to-service communication, AWS-managed updates, simpler security group rules
- Cons: Consumes VPC IP addresses (requires larger subnets), no network isolation between pods without NetworkPolicies, tied to AWS ecosystem

**Implementation:** Deployed as EKS addon in `infra/terraform/modules/eks/main.tf` with version v1.15.0-eksbuild.2 pinned to prevent unexpected upgrades. Configured with OVERWRITE conflict resolution to ensure consistent configuration. Requires AmazonEKS_CNI_Policy IAM permissions on node role.
