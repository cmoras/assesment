# Local Testing Guide (k3d)

## Prerequisites
- Docker
- k3d
- kubectl
- helm

## 1. Create k3d Cluster

```bash
k3d cluster create data-pipeline \
  --port "5000:5000@loadbalancer" \
  --registry-create data-pipeline-registry:5000
```

## 2. Build and Push Application

```bash
cd app
docker build -t localhost:5000/data-pipeline:latest .
docker push localhost:5000/data-pipeline:latest
```

## 3. Deploy Application

```bash
kubectl apply -k platform/overlays/local/
```

## 4. Test Endpoints

```bash
# Port-forward to access service
kubectl port-forward -n data-pipeline svc/data-pipeline 5000:5000

# In another terminal:
curl http://localhost:5000/healthz
curl -X POST http://localhost:5000/process -H "Content-Type: application/json" -d '{"test":"data"}'
curl http://localhost:5000/metrics
```

## 5. Deploy Monitoring (Optional)

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f platform/monitoring/kube-prometheus-stack-values.yaml
```

Access Grafana:
```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Visit http://localhost:3000 (admin/changeme)
```

## 6. Test NetworkPolicies

```bash
# Create test pod
kubectl run test-pod --image=busybox -n data-pipeline -- sleep 3600

# Try to access application (should work due to allow rules)
kubectl exec -n data-pipeline test-pod -- wget -O- http://data-pipeline:5000/healthz

# Try to access external (should fail due to default-deny)
kubectl exec -n data-pipeline test-pod -- wget -O- http://google.com
```

## 7. Test Gatekeeper

Try deploying a non-compliant pod (should be rejected):
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: bad-pod
  namespace: data-pipeline
spec:
  containers:
  - name: nginx
    image: nginx
    securityContext:
      runAsUser: 0  # Running as root - should be denied
EOF
```

Expected: Admission webhook denies the pod.

## 8. Cleanup

```bash
k3d cluster delete data-pipeline
```
