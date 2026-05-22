# Key Architecture Decisions

This document summarizes the top 5 architecture decisions made for this data pipeline infrastructure project.

## 1. Multi-Environment Terraform with Split State

**Decision:** Use separate Terraform state files per infrastructure layer (vpc, eks, iam, secrets-manager) within each environment (dev, prod).

**Why:** Split state reduces blast radius, enables parallel execution by different teams, and allows independent lifecycle management of infrastructure components.

**Trade-offs:**
- **Pros:** Safer (corrupting one state doesn't affect others), parallel workflows, granular permissions
- **Cons:** More complex state management, requires remote state data sources for cross-layer references

**Implementation:** `infra/terraform/environments/{dev,prod}/{vpc,eks,iam,secrets-manager}/backend.tf` with S3 backend migration path documented.

→ See [docs/decisions/013-terraform-state-management.md](docs/decisions/013-terraform-state-management.md)

## 2. EKS Endpoint Access: Public + Private

**Decision:** Configure EKS cluster with both public and private endpoint access enabled.

**Why:** Balances security and operability - private access for nodes/pods (no internet traversal), public access for CI/CD and emergency kubectl access.

**Trade-offs:**
- **Pros:** Secure node-to-control-plane communication, CI/CD can deploy without VPN, emergency access from anywhere
- **Cons:** Public endpoint exposed to internet (mitigated by CIDR restrictions and authentication)

**Production Note:** Restrict `cluster_endpoint_public_access_cidrs` to known IP ranges (CI/CD runners, VPN, bastion hosts) instead of default 0.0.0.0/0.

→ See [docs/decisions/009-eks-endpoint-access.md](docs/decisions/009-eks-endpoint-access.md)

## 3. VPC Subnet Sizing for VPC CNI

**Decision:** Use /19 CIDR blocks for private subnets (8,192 IPs per subnet) instead of /24 (256 IPs).

**Why:** AWS VPC CNI assigns subnet IPs directly to pods (not a separate pod CIDR). T3.medium nodes run ~17 pods each consuming a subnet IP. /24 subnets exhaust quickly in production.

**Trade-offs:**
- **Pros:** Prevents IP exhaustion, supports cluster scaling, accommodates VPC CNI prefix delegation
- **Cons:** Wastes RFC1918 address space if not fully utilized

**Implementation:** VPC module defaults to `["10.0.64.0/19", "10.0.96.0/19"]` for private subnets.

→ See [docs/decisions/001-vpc-cidr-sizing.md](docs/decisions/001-vpc-cidr-sizing.md)

## 4. Defense-in-Depth Security

**Decision:** Layer multiple security controls: Pod Security Standards (PSS) restricted mode + OPA Gatekeeper admission policies + NetworkPolicies.

**Why:** Single security layer can fail or be bypassed. Defense-in-depth ensures that if one control fails, others still provide protection.

**Trade-offs:**
- **Pros:** Multiple fail-safes, different attack vectors covered, compliance-friendly
- **Cons:** More complex to configure and troubleshoot, potential policy conflicts

**Implementation:**
- PSS restricted labels on namespace (enforce mode)
- Gatekeeper constraint templates with Rego policies
- NetworkPolicies with default-deny + explicit allows

→ See [docs/decisions/007-pod-security-enforcement.md](docs/decisions/007-pod-security-enforcement.md)  
→ See [docs/decisions/016-gatekeeper-policy-enforcement.md](docs/decisions/016-gatekeeper-policy-enforcement.md)

## 5. SLI Selection for Observability

**Decision:** Monitor availability, latency (p99), and error rate instead of resource metrics (CPU/memory).

**Why:** These Service Level Indicators (SLIs) measure user experience directly. CPU/memory are symptoms, not causes. Users care about "does it work?" and "is it fast?" not "what's the CPU%?"

**Trade-offs:**
- **Pros:** User-centric, actionable alerts, aligns with SLO/SLA frameworks
- **Cons:** Requires application instrumentation, harder to troubleshoot root cause without resource metrics

**Implementation:** PrometheusRules with alerts on:
- Availability < 99.9% over 5m
- p99 latency > 500ms over 5m
- Error rate > 5% over 5m

→ See [docs/decisions/004-sli-selection.md](docs/decisions/004-sli-selection.md)


## Portions generated using llm
- application code
- portions of terraform module related work.
- all kustomize build related work.   
