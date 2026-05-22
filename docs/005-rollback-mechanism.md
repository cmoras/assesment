# 005 Rollback Mechanism

**Decision:** Implement rollback by redeploying previous known-good container image SHA via kubectl set image or Kustomize overlay update.

**Why:** Kubernetes deployments are declarative and immutable. Rolling back means pointing the deployment at a previous container image version. Using specific SHAs (not :latest tags) ensures deterministic rollbacks to exact known-good versions. Combined with rolling update strategy, rollback is zero-downtime and automatic health check validation.

**Trade-offs:**
- Pros: Simple and fast (kubectl rollout undo or kubectl set image), zero-downtime via rolling update, automatic health check validation before proceeding, preserves immutability (no in-place changes), works with GitOps (revert commit and sync)
- Cons: Doesn't rollback database schema changes, application state may be incompatible with old version, requires keeping old images available, doesn't address data corruption, manual intervention needed for complex failures

**Implementation:** CI/CD pipeline in .github/workflows/ci.yml tags images with git SHA and pushes to registry. Kubernetes deployments reference specific SHA tags. Rollback executes kubectl set image deployment/data-pipeline app=image:previous-sha or kubectl rollout undo deployment/data-pipeline. GitOps flow reverts the kustomization overlay to previous SHA commit.
