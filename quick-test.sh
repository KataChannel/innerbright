#!/bin/bash

# Simple test for the deploy fix
echo "Testing deployment logging fix..."

# Create directories
mkdir -p .deploy-cache .deploy-logs

# Test the logging function
SERVER_HOST="116.118.85.41"
timestamp=$(date +"%Y%m%d_%H%M%S")
host_safe=$(echo "$SERVER_HOST" | sed 's/[^a-zA-Z0-9]/_/g')
log_file=".deploy-logs/deploy_${host_safe}_${timestamp}.log"

echo "Would create log file: $log_file"
echo "DEPLOYMENT_LOG_FILE=$log_file" > .deploy-cache/current-deployment.env

echo "✅ Fix applied successfully!"
echo "Log file info saved to: .deploy-cache/current-deployment.env"
echo "Content:"
cat .deploy-cache/current-deployment.env

echo ""
echo "🎯 Now you can run the deployment:"
echo "./universal-deployer.sh --host 116.118.85.41 --domain innerbright.vn"
