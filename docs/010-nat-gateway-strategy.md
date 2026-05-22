# 010 NAT Gateway Strategy

**Decision:** Deploy one NAT Gateway per availability zone (3 total)

**Why:** Multi-AZ NAT deployment ensures high availability - if one AZ fails, workloads in other AZs continue to have internet access. Each private subnet routes through its local NAT Gateway to minimize cross-AZ data transfer costs and latency. This is AWS best practice for production EKS clusters.

**Trade-offs:**
- Pros: High availability (no single point of failure), zone-local routing reduces latency, supports multi-AZ EKS scaling, meets production SLA requirements
- Cons: Higher cost (~$0.135/hour for 3 NAT Gateways vs $0.045 for single NAT), data transfer charges apply per NAT Gateway

**Implementation:** Configured in `infra/terraform/modules/vpc/main.tf` with `enable_nat_gateway = true` and `single_nat_gateway = false`. Each private subnet route table points to NAT Gateway in the same AZ. Production environment uses 3 NAT Gateways; dev environment can optionally use single NAT Gateway to reduce costs.
