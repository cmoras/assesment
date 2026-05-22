# 009 EKS Endpoint Access

**Decision:** Enable both public and private API endpoint access for EKS cluster

**Why:** Public access allows kubectl/CI/CD pipelines to manage the cluster from outside the VPC without VPN/bastion setup. Private access enables pods and nodes to communicate with the control plane using VPC networking without internet routing. This provides flexibility for both external management and internal pod operations.

**Trade-offs:**
- Pros: Flexible access (no VPN required for ops), secure internal communication for pods, supports CI/CD from GitHub Actions, reduced latency for pod-to-API traffic
- Cons: Public endpoint is attack surface (mitigated by IP allowlisting), more complex network architecture than private-only

**Implementation:** Configured in `infra/terraform/modules/eks/main.tf` with `endpoint_private_access = true` and `endpoint_public_access = true`. Public access can be restricted via `public_access_cidrs` variable to allow only specific IP ranges. Control plane security group restricts access to authorized sources.
