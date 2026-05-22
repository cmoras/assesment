# 015 Container Scanning

**Decision:** Integrate Trivy container scanning in CI/CD pipeline with severity threshold

**Why:** Trivy is an open-source, comprehensive vulnerability scanner that detects CVEs in container images, OS packages, and application dependencies. Running scans in CI/CD catches vulnerabilities before deployment. It's fast, has low false-positive rates, and integrates easily with GitHub Actions.

**Trade-offs:**
- Pros: Free and open-source, fast scanning (~30 seconds), low false positives, supports SBOM generation, CI/CD integration prevents vulnerable deployments, regularly updated vulnerability database
- Cons: Requires internet access to download vulnerability DB, can fail builds on new CVEs, may require exception process for accepted risks, scanning adds time to CI/CD

**Implementation:** Integrated in `.github/workflows/app-deploy.yml` as a separate job that runs after Docker build. Configured to fail on HIGH and CRITICAL vulnerabilities. Scans both OS packages and application dependencies. Trivy DB updated automatically during each scan. Scan results uploaded as GitHub Actions artifacts for audit trail.
