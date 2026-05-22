# 011 Security Groups

**Decision:** Separate security groups for EKS cluster control plane and worker nodes with minimal required rules

**Why:** Security groups act as virtual firewalls controlling network traffic. Separating cluster and node security groups follows least privilege - control plane only allows necessary API traffic, nodes allow pod-to-pod and cluster-to-node communication. This reduces attack surface and provides granular control over network access.

**Trade-offs:**
- Pros: Least privilege network access, clear separation of concerns, supports adding custom rules without affecting cluster, easier troubleshooting
- Cons: More complex than single security group, requires understanding of EKS networking requirements

**Implementation:** Implemented in `infra/terraform/modules/eks/main.tf` with two security groups: cluster SG allows port 443 from nodes, node SG allows 1025-65535 from cluster and all traffic between nodes. All egress allowed. Security groups reference each other to prevent circular dependencies during cluster creation.
