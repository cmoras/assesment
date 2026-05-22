# 007 Pod Security Enforcement

**Decision:** Enforce Pod Security Standards (PSS) in restricted mode using built-in admission controller

**Why:** Pod Security Standards provide a standardized, Kubernetes-native way to enforce security policies on pods. Restricted mode enforces the most secure baseline, preventing privilege escalation, requiring non-root users, and blocking host access. This is the recommended approach as of Kubernetes 1.25+ when PodSecurityPolicy was deprecated.

**Trade-offs:**
- Pros: Native Kubernetes feature (no external dependencies), well-documented standards, namespace-level enforcement, clear security posture
- Cons: Restrictive defaults may require workload modifications, less granular than custom policies, limited customization without OPA Gatekeeper

**Implementation:** Applied via namespace labels in `platform/security/pod-security-standards.yaml`. Default namespace enforces restricted mode, kube-system and monitoring namespaces use privileged mode for infrastructure components. Audit and warn modes enabled for visibility during policy violations.
