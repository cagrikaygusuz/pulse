#!/bin/bash
# deploy-firebase.sh

set -e

ENVIRONMENT=${1:-staging}
PROJECT_ID=""

case $ENVIRONMENT in
  "staging")
    PROJECT_ID="pulse-timer-staging"
    ;;
  "production")
    PROJECT_ID="pulse-timer-prod"
    ;;
  *)
    echo "Invalid environment: $ENVIRONMENT"
    echo "Usage: $0 [staging|production]"
    exit 1
    ;;
esac

echo "Deploying to Firebase project: $PROJECT_ID"

# Set Firebase project
firebase use $PROJECT_ID

# Deploy Firestore rules
echo "Deploying Firestore rules..."
firebase deploy --only firestore:rules

# Deploy Storage rules
echo "Deploying Storage rules..."
firebase deploy --only storage

# Deploy Cloud Functions
echo "Deploying Cloud Functions..."
firebase deploy --only functions

# Deploy Hosting
echo "Deploying Hosting..."
firebase deploy --only hosting

echo "Deployment completed successfully!"
