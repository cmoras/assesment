# 012 Monitoring Stack

**Decision:** Deploy kube-prometheus-stack (Prometheus Operator, Grafana, Alertmanager) via Helm

**Why:** kube-prometheus-stack is the de-facto standard for Kubernetes monitoring, providing pre-configured dashboards, alerts, and exporters. It includes Prometheus for metrics, Grafana for visualization, and Alertmanager for alert routing. This is a battle-tested, community-supported solution that covers 90% of monitoring needs out-of-the-box.

**Trade-offs:**
- Pros: Comprehensive monitoring with minimal configuration, pre-built dashboards for Kubernetes components, active community support, ServiceMonitor CRDs for easy app integration, includes node-exporter and kube-state-metrics
- Cons: Resource-intensive (requires ~2GB memory for stack), complex when customizing, large number of CRDs, vendor lock-in to Prometheus ecosystem

**Implementation:** Deployed via Helm chart with custom values in `platform/monitoring/kube-prometheus-stack-values.yaml`. SLI alerts configured for availability, latency, and error rate. Prometheus retention set to 7 days. Grafana exposed via NodePort for local access, can be switched to LoadBalancer for production.
