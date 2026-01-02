#!/bin/bash
set -euo pipefail

# Culture Threads Production Deployment Script
# Usage: ./scripts/deploy.sh [environment]

ENVIRONMENT=${1:-production}
PROJECT_ID="culture-threads-prod"
CLUSTER_NAME="culture-threads-gke-cluster"
REGION="us-east1"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# Pre-flight checks
preflight_checks() {
    log "🔍 Running pre-flight checks..."
    
    # Check required tools
    command -v gcloud >/dev/null 2>&1 || error "gcloud CLI not found"
    command -v kubectl >/dev/null 2>&1 || error "kubectl not found"
    command -v terraform >/dev/null 2>&1 || error "terraform not found"
    
    # Check authentication
    gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "." || error "Not authenticated with gcloud"
    
    # Check project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
    if [[ "$CURRENT_PROJECT" != "$PROJECT_ID" ]]; then
        error "Current project is $CURRENT_PROJECT, expected $PROJECT_ID"
    fi
    
    log "✅ Pre-flight checks passed"
}

# Deploy infrastructure
deploy_infrastructure() {
    log "🏗️ Deploying infrastructure..."
    
    cd terraform
    
    # Initialize Terraform
    terraform init -upgrade
    
    # Validate configuration
    terraform validate || error "Terraform validation failed"
    
    # Plan deployment
    terraform plan -out=tfplan
    
    # Apply if approved
    if [[ "${CI:-false}" == "true" ]] || [[ "${AUTO_APPROVE:-false}" == "true" ]]; then
        terraform apply -auto-approve tfplan
    else
        read -p "Apply this plan? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            terraform apply tfplan
        else
            warn "Deployment cancelled"
            exit 0
        fi
    fi
    
    cd ..
    log "✅ Infrastructure deployed"
}

# Configure kubectl
configure_kubectl() {
    log "⚙️ Configuring kubectl..."
    
    gcloud container clusters get-credentials $CLUSTER_NAME --region=$REGION --project=$PROJECT_ID
    
    # Verify connection
    kubectl cluster-info || error "Failed to connect to cluster"
    
    log "✅ kubectl configured"
}

# Deploy applications (placeholder for ArgoCD integration)
deploy_applications() {
    log "🚀 Preparing for application deployment..."
    
    # Check if ArgoCD is installed
    if kubectl get namespace argocd >/dev/null 2>&1; then
        info "ArgoCD detected - applications will be managed by GitOps"
        # Sync ArgoCD applications
        kubectl annotate app culture-threads argocd.argoproj.io/sync=force -n argocd || warn "ArgoCD sync annotation failed"
    else
        warn "ArgoCD not found - manual application deployment required"
        info "Install ArgoCD first: kubectl create namespace argocd && kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
    fi
    
    log "✅ Application deployment prepared"
}

# Health check
health_check() {
    log "🏥 Running health checks..."
    
    # Check cluster health
    kubectl get nodes || error "Cluster nodes not healthy"
    
    # Check system pods
    kubectl get pods -n kube-system | grep -v Running | grep -v Completed || true
    
    # Check ArgoCD if installed
    if kubectl get namespace argocd >/dev/null 2>&1; then
        kubectl get pods -n argocd | grep -v Running | grep -v Completed || true
    fi
    
    log "✅ Health checks completed"
}

# Main deployment flow
main() {
    log "🚀 Starting Culture Threads deployment to $ENVIRONMENT..."
    
    preflight_checks
    deploy_infrastructure
    configure_kubectl
    deploy_applications
    health_check
    
    log "🎉 Deployment completed successfully!"
    info "🔗 Access your cluster: https://console.cloud.google.com/kubernetes/list?project=$PROJECT_ID"
    info "📊 View logs: https://console.cloud.google.com/logs/query?project=$PROJECT_ID"
}

# Run main function
main "$@"