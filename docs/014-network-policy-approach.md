# 014 Network Policy Approach

**Decision:** Implement default-deny-all NetworkPolicy with explicit allow rules for required traffic

**Why:** Default-deny is security best practice - start with zero trust and explicitly allow only necessary traffic. This prevents lateral movement if a pod is compromised and forces developers to document network requirements. AWS VPC CNI supports NetworkPolicies natively without additional CNI plugins.

**Trade-offs:**
- Pros: Zero-trust security posture, prevents unauthorized pod-to-pod communication, forces explicit traffic documentation, detects misconfigurations early
- Cons: Breaks workloads if allow rules are incomplete, requires understanding of all traffic patterns, debugging connectivity issues is harder, may block legitimate traffic initially

**Implementation:** Implemented in `platform/security/network-policies/` with default-deny-all applied to default namespace. Explicit allow rules for DNS (port 53), Prometheus scraping (port 5000), and app ingress. NetworkPolicies use pod and namespace selectors to target specific workloads. Applied via Kustomize overlays per environment.
