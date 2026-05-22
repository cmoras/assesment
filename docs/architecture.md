# Data Pipeline Infrastructure Architecture

## Overview
Production-ready containerized data pipeline on AWS EKS with comprehensive security, observability, and CI/CD.

## Infrastructure Components

### Networking (VPC)
- VPC CIDR: 10.0.0.0/16 (dev) or 10.1.0.0/16 (prod)
- Public subnets: /24 for NAT gateways and load balancers
- Private subnets: /19 for EKS nodes (8,192 IPs to support VPC CNI pod IP allocation)
- Internet Gateway for public internet access
- NAT Gateways (1 per AZ for HA) for private subnet internet access
- VPC Flow Logs to CloudWatch for network traffic monitoring

### EKS Cluster
- Kubernetes 1.28
- Public + private endpoint access (secure external + internal access)
- OIDC provider for IRSA (IAM Roles for Service Accounts)
- Managed node groups in private subnets
- Version-pinned addons: vpc-cni, kube-proxy, coredns

### Security Layers
1. **Network Security:** NetworkPolicies with default-deny + explicit allows
2. **Admission Control:** OPA Gatekeeper enforcing non-root, no privilege escalation, read-only root filesystem
3. **Pod Security:** PSS restricted mode at namespace level
4. **IAM Security:** IRSA for pod-level AWS permissions (least privilege)
5. **Secrets Management:** AWS Secrets Manager with versioned secrets

### Application
- Python Flask service with /healthz, /process, /metrics endpoints
- Structured JSON logging for cloud-native observability
- Prometheus metrics exposition
- Multi-stage Docker build, non-root user (uid 1000)
- 2 replicas (dev) or 3 replicas (prod) with RollingUpdate strategy

### Monitoring & Observability
- kube-prometheus-stack (Prometheus, Grafana, AlertManager)
- ServiceMonitor scraping application metrics every 30s
- SLI-based alerts: availability, latency (p99 > 500ms), error rate (> 5%)
- 7-day metric retention

### CI/CD Pipeline
- Terraform validation on PR (all environments and layers)
- Application deployment: build → Trivy scan → push to ECR → deploy to EKS → smoke test → rollback on failure
- Dependabot for automated dependency updates
- SHA-based rollback mechanism for deterministic deployments
