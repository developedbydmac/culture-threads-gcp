# Culture Threads - GCP Infrastructure

Production-grade e-commerce platform deployed on Google Cloud Platform demonstrating SRE best practices.

## Architecture

- **Compute**: Google Kubernetes Engine (GKE)
- **Database**: Cloud SQL (PostgreSQL)
- **Storage**: Cloud Storage
- **Secrets**: Secret Manager
- **CI/CD**: GitHub Actions + Cloud Build
- **Monitoring**: Cloud Monitoring + Prometheus
- **IaC**: Terraform

## Prerequisites

- Google Cloud SDK (`gcloud`)
- Terraform >= 1.5.0
- kubectl
- Docker
- Git

## Project Structure
```
.
├── terraform/          # Infrastructure as Code
│   ├── network/       # VPC, subnets, firewall rules
│   ├── gke/           # Kubernetes cluster configuration
│   ├── database/      # Cloud SQL setup
│   └── secrets/       # Secret Manager configuration
├── k8s/               # Kubernetes manifests
├── scripts/           # Deployment and utility scripts
└── .github/workflows/ # CI/CD pipelines
```

## Quick Start
```bash
# 1. Set up GCP credentials
./scripts/setup-gcloud.sh

# 2. Initialize Terraform
cd terraform
terraform init

# 3. Plan infrastructure
terraform plan

# 4. Deploy infrastructure
terraform apply
```

## Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed deployment instructions.

## Cost Estimation

Expected monthly cost: ~$150-200 for production workload

- GKE: ~$75/month (cluster management)
- Cloud SQL: ~$50/month (db-custom-2-7680)
- Compute: ~$30-50/month (3 e2-standard-4 nodes)
- Load Balancer: ~$20/month
- Monitoring/Logging: ~$10/month

## Monitoring

- **Metrics**: Cloud Monitoring Dashboard
- **Logs**: Cloud Logging
- **Alerts**: Cloud Monitoring Alert Policies

## Contact

Daquan - D Mac Solutions