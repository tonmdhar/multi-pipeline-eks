# Atlas Platform — Multi-Pipeline EKS

A production-grade multi-environment Kubernetes platform on AWS EKS with independent CI/CD pipelines per environment, built using reusable Terraform modules, Kustomize-based deployments, and CloudWatch observability.

## Architecture

```
┌─ GitHub ──────────────────────────────────────────────────────────────┐
│  git push (main)                                                        │
└──────┬────────────────────────────────────────────────────────────────┘
       │
       ▼
┌─ CodePipeline (per environment) ──────────────────────────────────────┐
│                                                                         │
│  Source → Build (Docker→ECR) → [Approval: prod only] → Deploy (EKS)    │
│                                                                         │
└──────────────────────────────────────────────────────┬────────────────┘
                                                       │
       ┌───────────────────────────────────────────────┘
       │
       ▼
┌─ EKS Cluster (per environment) ───────────────────────────────────────┐
│                                                                         │
│  ┌─ Private Subnets (no public IPs) ─────────────────────────────┐     │
│  │  Node Group (t3.medium/large)                                   │     │
│  │  ┌─────┐  ┌─────┐  ┌─────┐                                     │     │
│  │  │Pod 1│  │Pod 2│  │Pod 3│  ← HPA auto-scales (1-6 pods)       │     │
│  │  └──┬──┘  └──┬──┘  └──┬──┘                                     │     │
│  │     └────────┼────────┘                                         │     │
│  │              │                                                   │     │
│  │     Service (ClusterIP :80→8080)                                │     │
│  └──────────────────────────────────────────────────────────────────┘     │
│                                                                         │
│  NAT Gateway → Outbound internet (ECR pulls, logs)                      │
└─────────────────────────────────────────────────────────────────────────┘
       │
       ▼
┌─ CloudWatch ──────────────────────────────────────────────────────────┐
│  Container Insights → Alarms → SNS → Email                             │
│  Dashboard: CPU, Memory, Pods, Network                                  │
└─────────────────────────────────────────────────────────────────────────┘
```

## Tech Stack

| Category | Technology |
|---|---|
| Cloud | AWS (EKS, ECR, VPC, CodePipeline, CodeBuild, Secrets Manager, CloudWatch, SNS) |
| IaC | Terraform (reusable modules per service) |
| Container | Docker (multi-stage, amazoncorretto:21-alpine3.21) |
| Orchestration | Kubernetes (EKS) with Kustomize overlays |
| Application | Java 21, Spring Boot 3.3, Spring Actuator |
| CI/CD | AWS CodePipeline + CodeBuild (per-env pipelines) |
| Monitoring | CloudWatch Container Insights, Alarms, Dashboards, SNS |
| Security | Private subnets, non-root containers, Secrets Manager, IRSA |

## Project Structure

```
multi-pipeline-eks/
├── terraform/
│   ├── modules/
│   │   ├── vpc/                # VPC + subnets + NAT Gateway
│   │   ├── eks/                # EKS cluster + node groups + IAM
│   │   ├── ecr/                # Docker image registry + lifecycle
│   │   ├── secrets/            # Secrets Manager + IRSA read policy
│   │   ├── pipeline/           # CodePipeline + CodeBuild + EKS access
│   │   ├── sns/                # SNS topics + email subscriptions
│   │   └── monitoring/         # CloudWatch alarms + dashboard
│   └── environments/
│       ├── dev/                # providers.tf + locals.tf + main.tf
│       ├── staging/            # providers.tf + locals.tf + main.tf
│       └── prod/               # providers.tf + locals.tf + main.tf
├── k8s/
│   ├── base/                   # deployment, service, hpa, pdb, namespace
│   └── overlays/
│       ├── dev/                # 256m CPU, HPA 1-3, profile=dev
│       ├── staging/            # 512m CPU, HPA 2-4, profile=staging
│       └── prod/               # 1 CPU, HPA 3-6, PDB=2, profile=prod
├── src/main/                   # Spring Boot application
│   ├── java/com/atlas/platform/
│   │   ├── AtlasPlatformApplication.java
│   │   ├── config/AppConfig.java
│   │   └── controller/HealthController.java
│   └── resources/
│       ├── application.yml
│       ├── application-dev.yml
│       ├── application-staging.yml
│       └── application-prod.yml
├── Dockerfile                  # Multi-stage (maven build → JRE runtime)
├── .dockerignore
├── buildspec-build.yml         # CI: Docker build → ECR push
├── buildspec-deploy.yml        # CD: kubectl apply → EKS
├── pom.xml                     # Maven config (Java 21, Spring Boot 3.3)
├── Makefile                    # Shortcuts: make init-all, make apply ENV=dev
└── SESSION_HISTORY.md          # Full build log with all decisions & errors
```

## Environment Comparison

| | Dev | Staging | Prod |
|---|---|---|---|
| VPC CIDR | 10.10.0.0/16 | 10.20.0.0/16 | 10.30.0.0/16 |
| Availability Zones | 2 | 2 | 3 |
| NAT Gateway | Single | Single | Multi (one per AZ) |
| Node Type | t3.medium | t3.large | t3.large |
| Node Count | 2 (max 3) | 2 (max 3) | 3 (max 6) |
| HPA Range | 1-3 pods | 2-4 pods | 3-6 pods |
| CPU (req/limit) | 256m / 512m | 512m / 1 | 1 / 2 |
| Memory (req/limit) | 512Mi / 1Gi | 512Mi / 1Gi | 1Gi / 2Gi |
| PDB minAvailable | 1 | 1 | 2 |
| Pipeline Approval | None | None | Manual gate |
| Log Retention | 7 days | 7 days | 30 days |
| Alarm Thresholds | CPU>80%, Mem>85% | CPU>80%, Mem>85% | CPU>70%, Mem>75% |

## Getting Started

### Prerequisites

- AWS CLI configured (`aws sts get-caller-identity`)
- Terraform >= 1.7.0
- kubectl
- Docker

### 1. Bootstrap (One-Time)

```bash
# Create S3 bucket for Terraform state
aws s3api create-bucket \
  --bucket atlas-platform-terraform-state \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket atlas-platform-terraform-state \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name atlas-platform-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### 2. Deploy Infrastructure

```bash
# Initialize and deploy all environments
cd terraform/environments/dev
terraform init
terraform apply

cd ../staging
terraform init
terraform apply

cd ../prod
terraform init
terraform apply
```

Or use the Makefile:
```bash
make init-all
make apply ENV=dev
make apply ENV=staging
make apply ENV=prod
```

### 3. Connect kubectl

```bash
aws eks update-kubeconfig --name atlas-platform-dev --region us-east-1
kubectl get nodes
```

### 4. Trigger Pipeline

```bash
git push origin main
# Pipeline auto-triggers → builds Docker image → deploys to EKS
```

### 5. Verify

```bash
kubectl get pods -n atlas-platform
kubectl port-forward svc/atlas-platform 8080:80 -n atlas-platform
curl http://localhost:8080/api/info
```

## API Endpoints

| Endpoint | Purpose |
|---|---|
| `GET /actuator/health/liveness` | Kubernetes liveness probe |
| `GET /actuator/health/readiness` | Kubernetes readiness probe |
| `GET /api/info` | Environment, uptime, feature flags |
| `GET /api/health/deep` | Memory usage, detailed health |

## Pipeline Flow

```
GitHub Push
    │
    ▼
┌── Source ──┐     ┌── Build ──────────────┐     ┌── Deploy ─────────────────┐
│ CodeStar   │ ──► │ Docker build (amd64)  │ ──► │ kubectl apply -k overlay  │
│ Connection │     │ Push to ECR           │     │ kubectl set image         │
└────────────┘     │ Output: imageDetail   │     │ kubectl rollout status    │
                   └───────────────────────┘     └───────────────────────────┘
                                                         │
                                                   [Prod only]
                                                         │
                                                   Manual Approval
```

## Security Practices

- **No public IPs** on any EKS nodes (private subnets only)
- **Non-root container** user in Dockerfile
- **Secrets Manager** for credentials (never hardcoded)
- **IAM Roles for Service Accounts (IRSA)** for pod-level permissions
- **CodeBuild in VPC** with security group rules
- **Manual approval gate** before production deployments
- **EKS API_AND_CONFIG_MAP** auth (explicit access entries)

## Monitoring & Alerting

| Alarm | Condition | Action |
|---|---|---|
| Node CPU High | >70-80% for 15 min | SNS → Email |
| Node Memory High | >75-85% for 15 min | SNS → Email |
| Pod Restarts | >3-5 in 5 min | SNS → Email |
| No Running Pods | 0 pods for 2 min | SNS → Email (CRITICAL) |
| Node Not Ready | Any node NotReady | SNS → Email |

## Key Design Decisions

| Decision | Rationale |
|---|---|
| Separate pipeline per env | Independent deploys, one env can't block another |
| Reusable Terraform modules | DRY — same VPC/EKS code across all envs |
| Kustomize overlays | Single base manifests, per-env patches |
| Multi-stage Dockerfile | Final image ~150MB (JRE only, no build tools) |
| JVM container flags | `MaxRAMPercentage=75%` respects K8s memory limits |
| Single NAT (dev/staging) | Cost saving ~$32/month per env |
| Multi NAT (prod) | High availability — survives AZ failure |
| Liveness delay 60s | JVM needs warmup time, prevents restart loops |

## Cost Estimate (Monthly)

| Resource | Dev | Staging | Prod |
|---|---|---|---|
| EKS Control Plane | $73 | $73 | $73 |
| NAT Gateway | $32 | $32 | $96 (3x) |
| EC2 Nodes (t3.medium/large) | ~$60 | ~$120 | ~$180 |
| ECR + S3 + CloudWatch | ~$10 | ~$10 | ~$15 |
| **Total** | **~$175** | **~$235** | **~$364** |

## Author

**Tonmoy Dhar** — DevOps Engineer 2, Amazon

## License

MIT
