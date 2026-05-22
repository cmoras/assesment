# 004 SLI Selection

**Decision:** Track three core SLIs - availability (uptime), latency (request duration), and error rate (5xx responses).

**Why:** These SLIs directly measure user-facing reliability and performance. Availability indicates if the service is reachable, latency measures responsiveness, and error rate captures request failures. Together they provide comprehensive service health visibility. These are standard Google SRE metrics that enable SLO definition and alerting.

**Trade-offs:**
- Pros: Industry-standard metrics understood by all teams, directly correlate to user experience, enable meaningful SLOs (99.9% uptime, P95 latency <500ms), easy to instrument with Prometheus client libraries, support error budget calculations
- Cons: Don't capture data quality issues, missing business logic errors (200 OK with wrong data), require defining "successful" request, edge cases like timeouts counted as errors or latency spikes

**Implementation:** Flask app exports Prometheus metrics via /metrics endpoint. prometheus_client library instruments request_duration_seconds histogram, requests_total counter (labeled by status code), and up gauge. Grafana dashboards visualize P50/P95/P99 latency, availability percentage over time windows, and error rate trends. AlertManager rules fire when SLOs breach thresholds.
