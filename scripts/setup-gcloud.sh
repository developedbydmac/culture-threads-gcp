#!/bin/bash
set -e

echo "🚀 Setting up GCP environment for Culture Threads..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}❌ gcloud CLI not found${NC}"
    echo "Install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

echo -e "${GREEN}✓ gcloud CLI found${NC}"

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform not found${NC}"
    echo "Install it from: https://developer.hashicorp.com/terraform/downloads"
    exit 1
fi

echo -e "${GREEN}✓ Terraform found${NC}"

# Set project
echo -e "${YELLOW}Setting GCP project...${NC}"
gcloud config set project culture-threads-prod

# Enable required APIs
echo -e "${YELLOW}Enabling required GCP APIs...${NC}"
gcloud services enable \
  compute.googleapis.com \
  container.googleapis.com \
  sqladmin.googleapis.com \
  cloudresourcemanager.googleapis.com \
  secretmanager.googleapis.com \
  cloudbuild.googleapis.com \
  artifactregistry.googleapis.com \
  storage-api.googleapis.com

echo -e "${GREEN}✓ APIs enabled${NC}"

# Create GCS bucket for Terraform state if it doesn't exist
echo -e "${YELLOW}Checking for Terraform state bucket...${NC}"
if gsutil ls gs://culture-threads-terraform-state &> /dev/null; then
    echo -e "${GREEN}✓ Terraform state bucket already exists${NC}"
else
    echo -e "${YELLOW}Creating Terraform state bucket...${NC}"
    gsutil mb -p culture-threads-prod -l us-east1 gs://culture-threads-terraform-state
    gsutil versioning set on gs://culture-threads-terraform-state
    echo -e "${GREEN}✓ Terraform state bucket created${NC}"
fi

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. cd terraform"
echo "2. terraform init"
echo "3. terraform plan"
echo "4. terraform apply"