#!/bin/bash

# Example environment variables for Azure ISE deployment
# Copy this file to env.sh and update with your values

# Azure Service Principal Credentials
export AZURE_CLIENT_ID="your-service-principal-client-id"
export AZURE_SECRET="your-service-principal-secret"
export AZURE_SUBSCRIPTION_ID="your-azure-subscription-id"
export AZURE_TENANT="your-azure-tenant-id"

# ISE Configuration
export ISE_PASSWORD="ISEisC00L"
export ISE_DOMAIN="your-domain.com"

# SSH Configuration (optional - will be generated if not set)
export SSH_PRIVATE_KEY_FILE="files/ssh_keys/iseble-azure"

# VPN Configuration (optional)
export VPN_SHARED_KEY="YourSharedKey123!"
export LOCAL_GATEWAY_IP="10.0.0.1"

# To use this file:
# 1. Copy to env.sh: cp examples/env_example.sh env.sh
# 2. Edit env.sh with your values
# 3. Source the file: source env.sh
# 4. Run deployment: ansible-playbook playbooks/01-create-infrastructure.yml