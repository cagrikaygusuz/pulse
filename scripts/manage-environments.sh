#!/bin/bash
# manage-environments.sh

set -e

ENVIRONMENT=${1:-staging}
ACTION=${2:-deploy}

case $ACTION in
  "deploy")
    echo "Deploying to $ENVIRONMENT environment..."
    ./scripts/deploy-firebase.sh $ENVIRONMENT
    ;;
  "setup")
    echo "Setting up $ENVIRONMENT environment..."
    firebase use $ENVIRONMENT
    firebase init
    ;;
  "switch")
    echo "Switching to $ENVIRONMENT environment..."
    firebase use $ENVIRONMENT
    ;;
  *)
    echo "Invalid action: $ACTION"
    echo "Usage: $0 [environment] [action]"
    echo "Actions: deploy, setup, switch"
    exit 1
    ;;
esac
