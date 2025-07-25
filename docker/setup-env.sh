#!/bin/bash

# Iseble for Azure - Environment Setup Script
# This script helps set up Azure environment variables

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if .env file already exists
if [[ -f "../.env" ]]; then
    print_warning ".env file already exists!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Keeping existing .env file."
        exit 0
    fi
fi

print_info "Setting up Azure environment variables..."

# Get Azure credentials from user
echo
echo "Please enter your Azure Service Principal credentials:"
echo

read -p "Azure Subscription ID: " AZURE_SUBSCRIPTION_ID
read -p "Azure Client ID: " AZURE_CLIENT_ID
read -s -p "Azure Client Secret: " AZURE_SECRET
echo
read -p "Azure Tenant ID: " AZURE_TENANT

echo
echo "Please enter your ISE credentials (for configuration after deployment):"
echo

read -p "ISE Admin Username [iseadmin]: " ISE_USERNAME
ISE_USERNAME=${ISE_USERNAME:-iseadmin}
read -s -p "ISE Admin Password: " ISE_PASSWORD
echo

# Validate inputs
if [[ -z "$AZURE_SUBSCRIPTION_ID" || -z "$AZURE_CLIENT_ID" || -z "$AZURE_SECRET" || -z "$AZURE_TENANT" ]]; then
    print_warning "All Azure fields are required!"
    exit 1
fi

if [[ -z "$ISE_PASSWORD" ]]; then
    print_warning "ISE password is required!"
    exit 1
fi

# Create .env file
cat > ../.env << EOF
# Azure Service Principal Credentials
AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID
AZURE_CLIENT_ID=$AZURE_CLIENT_ID
AZURE_SECRET=$AZURE_SECRET
AZURE_TENANT=$AZURE_TENANT

# ISE Configuration
ISE_REST_USERNAME=$ISE_USERNAME
ISE_REST_PASSWORD=$ISE_PASSWORD
ISE_VERIFY=False
ISE_DEBUG=False

# Optional: VPN Configuration (if using VPN)
VPN_SHARED_KEY=YourSharedKey123!
EOF

print_success ".env file created successfully!"
print_info "You can now run: ./run.sh"
print_info "Or use Docker Compose: docker-compose --profile dev up -d"

# Set file permissions
chmod 600 ../.env
print_info "Set .env file permissions to 600 (read/write for owner only)"