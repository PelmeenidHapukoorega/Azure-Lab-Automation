# Lab 11 — Kubernetes Networking

Hands-on exploration of Kubernetes internal networking by deploying a two-service application (frontend nginx + backend Flask) on AKS, demonstrating how Kubernetes DNS resolves service names internally.

## Demo

<!-- Demo video coming soon -->

## What this deploys

- AKS cluster with autoscaling (1-3 nodes)
- Azure Container Registry for Docker images
- Backend Flask service with health endpoint
- Frontend nginx serving static HTML
- Kubernetes Deployments and Services for both

## The core concept

Inside a Kubernetes cluster, every Service gets an internal DNS name. Pods can reach other pods using just the Service name — `backend-service` resolves to the ClusterIP, which forwards to a healthy pod. This works only inside the cluster. External DNS (your browser) cannot resolve Kubernetes internal service names.

Proved by running `wget http://backend-service:5000/health` from inside the frontend pod — returned the backend JSON response correctly.

## Key findings

**Custom NSGs break AKS** — the networking module's deny-all-inbound rule blocked AKS health probes and kubectl exec. AKS requires specific inbound rules for internal traffic. Easiest solution: let AKS manage its own networking.

**Kubelet identity changes on recreate** — every time the cluster is destroyed and recreated, AKS generates a new kubelet managed identity. ACR pull role assignment must be updated each time.

**Internal DNS only** — Kubernetes service DNS (`service-name.namespace.svc.cluster.local`) only resolves inside the cluster. Frontend JavaScript fetching `http://backend-service:5000` works from a pod but fails from a browser.

## Tech stack

| Layer | Technology |
|-------|-----------|
| Infrastructure | Terraform |
| Container registry | Azure Container Registry |
| Orchestration | AKS (Azure Kubernetes Service) |
| Backend | Flask (Python) |
| Frontend | nginx |

## How to run

```bash
cd terraform
terraform init
terraform apply -auto-approve
az aks get-credentials --name k8sNet-aks1 --resource-group k8sNet-rg --overwrite-existing
kubectl apply -f ../manifests/
```

**Destroy when done:**
```bash
terraform destroy -auto-approve
```

## Notes

Full debugging process documented in [LEARNINGS.md](./LEARNINGS.md).