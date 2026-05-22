# 008 Subnet Topology

**Decision:** 3-AZ deployment with public subnets for NAT/load balancers and private subnets for workloads

**Why:** Public subnets host internet-facing resources (NAT Gateways, ALB/NLB) while private subnets isolate workloads from direct internet access. This follows AWS best practices for multi-AZ high availability and defense-in-depth security. Private subnets route outbound traffic through NAT Gateways in public subnets.

**Trade-offs:**
- Pros: High availability across AZs, workload isolation from internet, defense-in-depth security, supports both public and private load balancers
- Cons: NAT Gateway costs (~$0.045/hour per AZ + data transfer), increased routing complexity, slight latency for outbound traffic

**Implementation:** Configured in `infra/terraform/modules/vpc/main.tf` with 3 public subnets (/24 each) and 3 private subnets (/19 each). Public route table points to Internet Gateway, private route tables point to NAT Gateway in corresponding AZ. EKS nodes deployed only in private subnets. Kubernetes service tags applied for ELB auto-discovery.
