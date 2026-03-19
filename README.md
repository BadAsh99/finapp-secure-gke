# finapp-secure-gke

> Production-grade secure financial application on GKE — Flask API, Nginx frontend, Kubernetes hardening, Terraform IaC

![Python](https://img.shields.io/badge/Python-3.11-blue?logo=python&logoColor=white)
![Go](https://img.shields.io/badge/GKE-Kubernetes-blue?logo=kubernetes)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple?logo=terraform)
![GCP](https://img.shields.io/badge/GCP-google_5.x-red?logo=googlecloud)

---

## Overview

A security-first financial microservices application running on **Google Kubernetes Engine (GKE)**. Demonstrates Kubernetes hardening best practices end-to-end: private cluster, Workload Identity, network policies, non-root containers, read-only filesystems, and CI/CD via Cloud Build. The Terraform IaC provisions the full GKE stack including Artifact Registry and Cloud Build IAM.

---

## Architecture

```
Internet
    │
    ▼
LoadBalancer Service (frontend)
    │
    ▼
Nginx Frontend (alpine, non-root, port 8080)
    │  /api/* → proxy_pass
    ▼
Flask API (Python 3.11 + Gunicorn, non-root UID 10001, port 5000)

── Kubernetes (GKE Private Cluster) ──────────────────────────────
Namespace: finapp
  ├─ NetworkPolicy: default-deny-all
  ├─ NetworkPolicy: allow frontend → api (port 5000)
  ├─ NetworkPolicy: allow api → DNS egress
  ├─ NetworkPolicy: allow frontend ingress
  └─ SecurityContext (both containers):
       ├─ runAsNonRoot: true
       ├─ readOnlyRootFilesystem: true
       ├─ allowPrivilegeEscalation: false
       ├─ seccompProfile: RuntimeDefault
       └─ capabilities: drop ALL

── GCP Infrastructure (Terraform) ───────────────────────────────
  ├─ GKE Private Cluster (e2-standard-2, 2 nodes)
  ├─ VPC with NAT (no public node IPs)
  ├─ Workload Identity (Pod SA → GCP SA binding)
  ├─ Artifact Registry (container image storage)
  └─ Cloud Build (CI/CD: build → push → deploy)
```

---

## Features

### Kubernetes Security
- **Private cluster** — nodes have no public IPs, all egress via Cloud NAT
- **Default-deny network policies** — Calico enforces explicit allow rules only
- **Non-root containers** — both API and frontend run as non-root users
- **Read-only root filesystems** — prevents runtime file writes
- **Dropped capabilities** — `ALL` capabilities dropped, none added
- **Seccomp RuntimeDefault** — syscall filtering enforced by default
- **Workload Identity** — pods bind to GCP service accounts without credential files

### Application
- **Flask API** (`/healthz`, `/`) — lightweight Python microservice on Gunicorn
- **Nginx frontend** — alpine image, proxies `/api/` to backend ClusterIP service
- **Kustomize overlays** — environment-specific config (dev/prod) without duplication

### Infrastructure (Terraform)
- GKE cluster with private nodes and managed master
- VPC with subnet, secondary IP ranges for pods/services, Cloud NAT
- Artifact Registry for container images
- Cloud Build with minimal IAM permissions for CI/CD

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| API | Python 3.11, Flask, Gunicorn |
| Frontend | Nginx (alpine) |
| Orchestration | Google Kubernetes Engine (GKE) |
| Networking | Calico network policies, Cloud NAT |
| IaC | Terraform, google ~5.36 |
| CI/CD | Cloud Build, Kustomize |
| Registry | Artifact Registry |
| Identity | Workload Identity |

---

## Getting Started

### Prerequisites

- `gcloud` CLI authenticated
- Terraform v1.5+
- Docker (for local image builds)

### Deploy Infrastructure

```bash
cd iac/terraform/envs/dev
terraform init
terraform apply
```

### Build & Push Images

```bash
# Cloud Build handles this automatically on push
# For manual build:
docker build -t us-docker.pkg.dev/PROJECT/finapp/api:latest app/api/
docker push us-docker.pkg.dev/PROJECT/finapp/api:latest
```

### Deploy to GKE

```bash
gcloud container clusters get-credentials finapp-cluster --region us-central1
kubectl apply -k app/k8s/overlays/dev/
```

---

## File Structure

```
finapp-secure-gke/
├── app/
│   ├── api/
│   │   ├── src/main.py          # Flask API
│   │   └── Dockerfile           # Non-root Python image
│   ├── frontend/
│   │   ├── html/                # Static content + nginx config
│   │   └── Dockerfile           # Non-root Nginx image
│   └── k8s/
│       ├── base/                # Core K8s manifests
│       │   ├── deploy-api.yaml
│       │   ├── deploy-frontend.yaml
│       │   ├── netpol-*.yaml    # Network policies
│       │   └── svc-*.yaml
│       └── overlays/dev/        # Kustomize dev overrides
└── iac/
    └── terraform/
        ├── envs/dev/            # Dev environment entry point
        └── modules/
            ├── gke/             # GKE cluster module
            ├── network/         # VPC + NAT module
            ├── artifact-registry/
            └── cloud-build-iam/
```

---

## Author

**Ash Clements** — Sr. Principal Security Consultant | Cloud & AI Security
[github.com/BadAsh99](https://github.com/BadAsh99)
