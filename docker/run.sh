#!/bin/bash

# Iseble for Azure - Simple Docker Run Script
# This script runs the project in a Docker container

set -e

# Define color codes for terminal output to enhance readability:
GREEN='\033[0;32m'   # Green text for success messages
BLUE='\033[0;34m'    # Blue text for informational messages
YELLOW='\033[1;33m'  # Yellow text for warning messages
NC='\033[0m'         # No Color: resets text color to default

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if Docker image exists
if ! docker image inspect iseble-azure:latest >/dev/null 2>&1; then
    print_warning "Docker image 'iseble-azure:latest' not found!"
    print_info "Building image first..."
    ./build.sh
fi

# Load environment variables from .env file if it exists
if [[ -f "../.env" ]]; then
    print_info "Loading environment variables from .env file..."
    export $(grep -v '^#' ../.env | xargs)
fi

# Check if Azure environment variables are set
if [[ -z "$AZURE_SUBSCRIPTION_ID" || -z "$AZURE_CLIENT_ID" || -z "$AZURE_SECRET" || -z "$AZURE_TENANT" ]]; then
    print_warning "Azure environment variables not set!"
    print_info "Please set the following environment variables:"
    echo "  export AZURE_SUBSCRIPTION_ID=your-subscription-id"
    echo "  export AZURE_CLIENT_ID=your-client-id"
    echo "  export AZURE_SECRET=your-client-secret"
    echo "  export AZURE_TENANT=your-tenant-id"
    echo
    print_info "Or create a .env file in the project root with these variables."
    print_info "Example .env file:"
    echo "  AZURE_SUBSCRIPTION_ID=your-subscription-id"
    echo "  AZURE_CLIENT_ID=your-client-id"
    echo "  AZURE_SECRET=your-client-secret"
    echo "  AZURE_TENANT=your-tenant-id"
    echo
    print_warning "Continuing without Azure credentials - some operations may fail."
fi

print_info "Starting Iseble for Azure in Docker container..."

# Ensure SSH keys directory exists with proper permissions
mkdir -p ../files/ssh_keys
chmod 755 ../files/ssh_keys
chown -R $(id -u):$(id -g) ../files/ssh_keys 2>/dev/null || true

print_info "Container will start in /ansible directory"
print_info "SSH keys directory: /ansible/files/ssh_keys"

# Run the Docker container (as root for reliability)
docker run -it --rm \
    -v "$(pwd)/..:/ansible" \
    -w /ansible \
    -e AZURE_SUBSCRIPTION_ID="$AZURE_SUBSCRIPTION_ID" \
    -e AZURE_CLIENT_ID="$AZURE_CLIENT_ID" \
    -e AZURE_SECRET="$AZURE_SECRET" \
    -e AZURE_TENANT="$AZURE_TENANT" \
    -e ANSIBLE_LOCAL_TMP=/tmp/.ansible \
    -e ANSIBLE_REMOTE_TMP=/tmp/.ansible \
    -e HOME=/ansible \
    -e ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3 \
    -e ANSIBLE_CRYPTO_OPENSSH_KEYPAIR_CHATTR=false \
    -e ANSIBLE_CRYPTO_OPENSSH_KEYPAIR_USE_CHATTR=false \
    -e ANSIBLE_CRYPTO_OPENSSH_KEYPAIR_USE_ATTR=false \
    -e ANSIBLE_UNSAFE_WRITES=true \
    --user root \
    iseble-azure:latest

# Fix file permissions after container exits
print_info "Fixing file permissions..."
if [[ -d "../files/ssh_keys" ]]; then
    chown -R $(id -u):$(id -g) ../files/ssh_keys 2>/dev/null || true
    chmod 600 ../files/ssh_keys/iseble-azure 2>/dev/null || true
    chmod 644 ../files/ssh_keys/iseble-azure.pub 2>/dev/null || true
fi

print_success "Container exited successfully!"