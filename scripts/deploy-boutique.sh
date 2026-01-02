#!/bin/bash
# Google Online Boutique Microservices Deployment Script
# This script deploys the Google Online Boutique sample microservices application
# alongside our Culture Threads application for a comprehensive demo

set -e

echo "🏪 Deploying Google Online Boutique Microservices..."

# Create namespace for boutique services
kubectl create namespace boutique --dry-run=client -o yaml | kubectl apply -f -

# Clone and deploy Google Online Boutique
TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR

echo "📦 Cloning Google Online Boutique repository..."
git clone https://github.com/GoogleCloudPlatform/microservices-demo.git
cd microservices-demo

echo "🎯 Customizing deployment for our infrastructure..."

# Update the deployment to use our project's container registry
sed -i.bak 's/gcr\.io\/google-samples\/microservices-demo/us-central1-docker.pkg.dev\/culture-threads-prod\/boutique/g' release/kubernetes-manifests.yaml

echo "☸️  Deploying Online Boutique to Kubernetes..."
kubectl apply -f release/kubernetes-manifests.yaml -n boutique

echo "🏷️  Adding Prometheus monitoring annotations..."
# Add Prometheus annotations to services
kubectl patch deployment adservice -n boutique -p '{"spec":{"template":{"metadata":{"annotations":{"prometheus.io/scrape":"true","prometheus.io/port":"9555","prometheus.io/path":"/stats/prometheus"}}}}}'
kubectl patch deployment cartservice -n boutique -p '{"spec":{"template":{"metadata":{"annotations":{"prometheus.io/scrape":"true","prometheus.io/port":"7070"}}}}}'
kubectl patch deployment checkoutservice -n boutique -p '{"spec":{"template":{"metadata":{"annotations":{"prometheus.io/scrape":"true","prometheus.io/port":"5050"}}}}}'
kubectl patch deployment currencyservice -n boutique -p '{"spec":{"template":{"metadata":{"annotations":{"prometheus.io/scrape":"true","prometheus.io/port":"7000"}}}}}'
kubectl patch deployment emailservice -n boutique -p '{"spec":{"template":{"metadata":{"annotations":{"prometheus.io/scrape":"true","prometheus.io/port":"8080"}}}}}'
kubectl patch deployment frontend -n boutique -p '{"spec":{"template":{"metadata":{"annotations":{"prometheus.io/scrape":"true","prometheus.io/port":"8080"}}}}}'
kubectl patch deployment paymentservice -n boutique -p '{"spec":{"template":{"metadata":{"annotations":{"prometheus.io/scrape":"true","prometheus.io/port":"50051"}}}}}'
kubectl patch deployment productcatalogservice -n boutique -p '{"spec":{"template":{"metadata":{"annotations":{"prometheus.io/scrape":"true","prometheus.io/port":"3550"}}}}}'
kubectl patch deployment recommendationservice -n boutique -p '{"spec":{"template":{"metadata":{"annotations":{"prometheus.io/scrape":"true","prometheus.io/port":"8080"}}}}}'
kubectl patch deployment shippingservice -n boutique -p '{"spec":{"template":{"metadata":{"annotations":{"prometheus.io/scrape":"true","prometheus.io/port":"50051"}}}}}'

echo "🚀 Deployment complete!"

# Clean up
cd /Users/daquanmcdaniel/Documents/2026/culture-threads-gcp
rm -rf $TEMP_DIR

echo "📊 Checking deployment status..."
kubectl get pods -n boutique
kubectl get services -n boutique

echo "🎉 Google Online Boutique is now deployed!"
echo "🔗 To access the frontend, run: kubectl port-forward -n boutique svc/frontend-external 8080:80"
echo "📈 Metrics will be automatically scraped by Prometheus"
