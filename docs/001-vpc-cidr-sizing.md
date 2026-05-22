# 001 VPC CIDR Sizing

**Decision:** Use /19 private subnets providing 8,192 IPs per availability zone.

**Why:** AWS VPC CNI assigns subnet IPs directly to pods, not overlay IPs. Each pod consumes a VPC IP from the node's subnet. With autoscaling EKS clusters, we need substantial IP headroom to prevent exhaustion during scale-up events. A /19 provides ~24,000 total pod IPs across 3 AZs, supporting hundreds of nodes and future growth.

**Trade-offs:**
- Pros: Prevents IP exhaustion, supports autoscaling headroom, future-proof for additional workloads, enables VPC CNI prefix delegation mode
- Cons: Consumes significant RFC1918 address space, over-provisioned for dev environments, cannot reuse IP ranges across VPCs without peering conflicts

**Implementation:** VPC CIDR 10.0.0.0/16 with private subnets 10.0.0.0/19, 10.0.32.0/19, 10.0.64.0/19 across three AZs. Public subnets use smaller /24 blocks (256 IPs) as they only host NAT Gateways and Load Balancers. Reserved space 10.0.99.0/24+ for future database subnets or peering connections.
