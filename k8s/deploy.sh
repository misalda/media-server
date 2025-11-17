#!/bin/bash

# Media Server Deployment Script
# This script deploys all media server components to the media namespace

set -e

echo "🚀 Deploying Media Server to Kubernetes..."

# Set kubeconfig
export KUBECONFIG=/Users/miguel/development/media-server/kubeconfig.yaml

# Create namespace if it doesn't exist
kubectl create namespace media --dry-run=client -o yaml | kubectl apply -f -

echo "📦 Applying shared resources..."
kubectl apply -f shared/

echo "🐳 Deploying applications..."
echo "  - Jackett..."
kubectl apply -f jackett/
echo "  - Plex..."
kubectl apply -f plex/
echo "  - Radarr..."
kubectl apply -f radarr/
echo "  - Sonarr..."
kubectl apply -f sonarr/
echo "  - Transmission..."
kubectl apply -f transmission/

echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/jackett-vpn -n media
kubectl wait --for=condition=available --timeout=300s deployment/plex-kube-plex -n media
kubectl wait --for=condition=available --timeout=300s deployment/radarr -n media
kubectl wait --for=condition=available --timeout=300s deployment/sonarr -n media
kubectl wait --for=condition=available --timeout=300s deployment/transmission-transmission-openvpn -n media

echo "✅ All deployments are ready!"
echo ""
echo "📊 Current status:"
kubectl get pods -n media
echo ""
echo "🔗 Service endpoints:"
kubectl get services -n media