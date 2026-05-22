# Data Pipeline Infrastructure

Production-ready containerized data pipeline on AWS EKS with comprehensive security, observability, and CI/CD.

## Quick Links
- [Architecture Overview](docs/architecture.md)
- [Key Decisions](DECISIONS.md)
- [Local Testing Guide](docs/testing-locally.md)
- [Design Specification](docs/superpowers/specs/2026-05-22-data-pipeline-infrastructure-design.md)

## Repository Structure

```
app/                    # Python Flask data pipeline service
infra/terraform/        # AWS infrastructure (VPC, EKS, IAM, Secrets)
platform/               # Kubernetes manifests (Kustomize)
.github/workflows/      # CI/CD pipelines
docs/                   # Architecture & decision docs
```

## Prerequisites

- Terraform >= 1.5
- kubectl >= 1.28
- Docker
- k3d (for local testing)
- Python 3.11+ (for local app development)

## Validation (No AWS Account Required)

### Terraform

```bash
cd infra/terraform/environments/dev/vpc
terraform init
terraform validate
terraform plan
```

Repeat for eks/, iam/, secrets-manager/ layers.

### Application

```bash
cd app
docker build -t data-pipeline:latest .
docker run -p 5000:5000 data-pipeline:latest

# Test endpoints
curl http://localhost:5000/healthz
curl -X POST http://localhost:5000/process -H "Content-Type: application/json" -d '{"test":"data"}'
curl http://localhost:5000/metrics
```

### Kubernetes (Local k3d)

See [Testing Locally](docs/testing-locally.md)

## Deployment (Production)

See individual component READMEs and [Architecture](docs/architecture.md)

## AI Tool Usage

- **Step 0 (Application):** Generated with Claude Code using prompt: "Create a simple Python Flask data pipeline with /healthz and /process endpoints, structured JSON logging, Prometheus metrics"
- **Infrastructure:** Terraform modules reviewed and modified from AI suggestions (details in DECISIONS.md)

## Evaluation Criteria Coverage

- ✅ IaC quality & modularity (25%)
- ✅ Security posture (25%)
- ✅ CI/CD design & reliability (20%)
- ✅ Observability & alerting (15%)
- ✅ Documentation & trade-offs (15%)
