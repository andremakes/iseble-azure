#!/bin/bash

# Iseble for Azure Setup Script
# This script installs the required Ansible collections for the project

set -e

echo "Installing Ansible collections for Iseble for Azure..."

# Install required collections
ansible-galaxy collection install -r collections/requirements.yml

echo "Collections installed successfully!"
echo ""
echo "Next steps:"
echo "1. Set your Azure environment variables:"
echo "   export AZURE_CLIENT_ID=<your_client_id>"
echo "   export AZURE_SECRET=<your_secret>"
echo "   export AZURE_SUBSCRIPTION_ID=<your_subscription_id>"
echo "   export AZURE_TENANT=<your_tenant_id>"
echo ""
echo "2. Configure your variables in vars/main.yml"
echo ""
echo "3. Run the deployment:"
echo "   ansible-playbook playbooks/01-create-infrastructure.yml" 