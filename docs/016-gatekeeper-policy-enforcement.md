# 016 Gatekeeper Policy Enforcement

**Decision:** Deploy OPA Gatekeeper with custom ConstraintTemplates to enforce security policies beyond Pod Security Standards

**Why:** While Pod Security Standards provide baseline security, Gatekeeper enables custom policies like requiring read-only root filesystems, blocking privilege escalation, and enforcing resource limits. OPA provides a flexible, declarative policy framework that's more granular than PSS alone. Policies are enforced at admission time, preventing non-compliant resources from being created.

**Trade-offs:**
- Pros: Highly customizable policies, declarative Rego language, audit mode for testing policies, can enforce organizational standards, active community with pre-built policies
- Cons: Additional complexity (learning Rego), more moving parts (Gatekeeper pods), policies can block legitimate workloads if misconfigured, requires ongoing policy maintenance

**Implementation:** Deployed via Kustomize in `platform/security/gatekeeper/` with three ConstraintTemplates: require-non-root, block-privilege-escalation, require-ro-rootfs. Constraints applied to default namespace. Gatekeeper runs in audit mode initially to detect violations, then switched to enforcement mode. Exemptions defined for kube-system and monitoring namespaces.
