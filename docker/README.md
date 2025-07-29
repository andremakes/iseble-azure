# Docker Setup for Iseble for Azure

This directory contains Docker configurations for running the Iseble for Azure project in containers. Two approaches are provided:

1. **Simple Docker** - For individual users and quick setup
2. **Docker Compose** - For teams and production environments

## Overview

This Docker setup provides a consistent environment for running the Iseble for Azure Ansible playbooks without requiring local Python or Ansible installation. The container includes all necessary dependencies and is pre-configured for Azure and Cisco ISE automation.

## Quick Start

### Option 1: Simple Docker (Recommended for Individual Use)

```bash
# Build the image
cd docker
./build.sh

# Set up environment variables (first time only)
./setup-env.sh

# Run the container
./run.sh
```

**Note:** The Docker setup has been optimized for reliability. The container runs as root to ensure proper file permissions, and the SSH keys directory is automatically created with correct permissions. The `chattr` issue on mounted volumes has been resolved by setting `ANSIBLE_CRYPTO_OPENSSH_KEYPAIR_CHATTR=false`.

### Option 2: Docker Compose (Recommended for Teams)

```bash
# Development environment
cd docker
docker-compose --profile dev up -d
docker-compose exec iseble bash

# Production environment
docker-compose --profile prod run --rm iseble ansible-playbook playbooks/01-create-infrastructure.yml
```

## Prerequisites

### 1. Docker Installation
Ensure Docker and Docker Compose are installed on your system.

### 2. Azure Credentials
The scripts automatically load environment variables from:
- **Host system environment variables**
- **`.env` file** in the project root (if it exists)

#### Quick Setup:
```bash
cd docker
./setup-env.sh  # Interactive setup
```

#### Manual Setup:
Set environment variables in your shell:
```bash
# Azure credentials
export AZURE_SUBSCRIPTION_ID=your-subscription-id
export AZURE_CLIENT_ID=your-client-id
export AZURE_SECRET=your-client-secret
export AZURE_TENANT=your-tenant-id

# ISE credentials (for configuration after deployment)
export ISE_REST_USERNAME=iseadmin
export ISE_REST_PASSWORD=your-ise-password
```

Or create a `.env` file in the project root:
```bash
# Azure credentials
AZURE_SUBSCRIPTION_ID=your-subscription-id
AZURE_CLIENT_ID=your-client-id
AZURE_SECRET=your-client-secret
AZURE_TENANT=your-tenant-id

# ISE credentials
ISE_REST_USERNAME=iseadmin
ISE_REST_PASSWORD=your-ise-password
ISE_VERIFY=False
ISE_DEBUG=False
```

## Usage Examples

### Simple Docker Commands

```bash
# Interactive shell
docker run -it --rm \
  -v $(pwd)/..:/ansible \
  -e AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID \
  -e AZURE_CLIENT_ID=$AZURE_CLIENT_ID \
  -e AZURE_SECRET=$AZURE_SECRET \
  -e AZURE_TENANT=$AZURE_TENANT \
  -e ISE_REST_USERNAME=$ISE_REST_USERNAME \
  -e ISE_REST_PASSWORD=$ISE_REST_PASSWORD \
  iseble-azure:latest

# Run specific playbook
docker run -it --rm \
  -v $(pwd)/..:/ansible \
  -e AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID \
  -e AZURE_CLIENT_ID=$AZURE_CLIENT_ID \
  -e AZURE_SECRET=$AZURE_SECRET \
  -e AZURE_TENANT=$AZURE_TENANT \
  -e ISE_REST_USERNAME=$ISE_REST_USERNAME \
  -e ISE_REST_PASSWORD=$ISE_REST_PASSWORD \
  iseble-azure:latest \
  ansible-playbook playbooks/01-create-infrastructure.yml

# Run all playbooks sequentially
docker run -it --rm \
  -v $(pwd)/..:/ansible \
  -e AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID \
  -e AZURE_CLIENT_ID=$AZURE_CLIENT_ID \
  -e AZURE_SECRET=$AZURE_SECRET \
  -e AZURE_TENANT=$AZURE_TENANT \
  -e ISE_REST_USERNAME=$ISE_REST_USERNAME \
  -e ISE_REST_PASSWORD=$ISE_REST_PASSWORD \
  iseble-azure:latest \
  bash -c "ansible-playbook playbooks/01-create-infrastructure.yml && \
           ansible-playbook playbooks/02-deploy-ise.yml && \
           ansible-playbook playbooks/03-configure-ise.yml"
```

### Docker Compose Commands

```bash
# Development environment (interactive)
docker-compose --profile dev up -d
docker-compose exec iseble bash

# Development environment (run playbook)
docker-compose --profile dev run --rm iseble ansible-playbook playbooks/01-create-infrastructure.yml

# Production environment (run playbook)
docker-compose --profile prod run --rm iseble ansible-playbook playbooks/01-create-infrastructure.yml

# Stop development environment
docker-compose down
```

## Container Features

### Pre-installed Components
- **Ubuntu 24.04** base image
- **Ansible** (latest from PPA)
- **Azure Collection** (`azure.azcollection`) with dependencies
- **Cisco ISE Collection** (`cisco.ise`) with SDK
- **SSH tools** (client, server, sshpass)
- **Essential utilities** (git, curl, vim)
- **Python 3** with pip

### Python Packages
- **`ciscoisesdk`** - Required for ISE automation
- **Azure SDK components** - For Azure resource management
- **SSH and cryptography libraries** - For secure connections
- **All required dependencies** - Ready to run ISE and Azure playbooks

### Environment Variables
The container supports these environment variables:
```bash
# Azure credentials
AZURE_SUBSCRIPTION_ID
AZURE_CLIENT_ID
AZURE_SECRET
AZURE_TENANT

# ISE credentials (for configuration)
ISE_REST_USERNAME=iseadmin
ISE_REST_PASSWORD
ISE_VERIFY=False
ISE_DEBUG=False
```

## File Structure

```
docker/
├── Dockerfile              # Main Docker image
├── docker-compose.yml      # Docker Compose configuration
├── build.sh               # Build script
├── run.sh                 # Simple run script
├── setup-env.sh           # Environment setup script
├── debug-paths.sh         # Debug script for troubleshooting
├── requirements.txt       # Python dependencies (copied from root)
├── README.md              # This file
```

## Environment Differences

### Development Profile
- **Full project mount**: Live code editing
- **Interactive shell**: For development and debugging
- **All files accessible**: Complete project structure

### Production Profile
- **Selective mounts**: Only necessary files (read-only)
- **Security focused**: Minimal file access
- **CI/CD ready**: Suitable for automated deployments

## Troubleshooting

### Common Issues

1. **SSH Key Generation Issues**
   ```bash
   # If SSH key generation fails, run the debug script
   docker run --rm -v $(pwd)/..:/ansible iseble-azure:latest /ansible/docker/debug-paths.sh

   # Check SSH keys directory permissions
   ls -la files/ssh_keys/

   # If you get chattr errors, ensure ANSIBLE_CRYPTO_OPENSSH_KEYPAIR_CHATTR=false is set
   export ANSIBLE_CRYPTO_OPENSSH_KEYPAIR_CHATTR=false
   ```

2. **Permission Issues**
   ```bash
   # Fix SSH key permissions (if needed)
   chmod 600 files/ssh_keys/iseble-azure
   chmod 644 files/ssh_keys/iseble-azure.pub
   ```

3. **Azure Authentication**
   ```bash
   # Verify Azure environment variables
   echo $AZURE_SUBSCRIPTION_ID
   echo $AZURE_CLIENT_ID
   echo $AZURE_SECRET
   echo $AZURE_TENANT
   ```

4. **ISE Authentication**
   ```bash
   # Verify ISE environment variables
   echo $ISE_REST_USERNAME
   echo $ISE_REST_PASSWORD
   ```

5. **Docker Image Not Found**
   ```bash
   # Rebuild the image
   cd docker
   ./build.sh
   ```

### Debugging

```bash
# Check container logs
docker-compose logs iseble

# Enter container for debugging
docker-compose exec iseble bash

# Check Ansible version
docker run --rm iseble-azure:latest ansible --version

# Run debug script inside container
docker run --rm -v $(pwd)/..:/ansible iseble-azure:latest /ansible/docker/debug-paths.sh
```

## Migration from Virtual Environment

If you're currently using the virtual environment approach:

1. **Build Docker image**: `cd docker && ./build.sh`
2. **Set environment variables**: Export Azure credentials
3. **Run playbooks**: Use Docker commands instead of `ansible-playbook`

### When to Use Each Approach

**Use Simple Docker when:**
- Individual development
- Quick testing
- Minimal setup required

**Use Docker Compose when:**
- Team development
- Production deployments
- Complex volume mounting needed
- CI/CD integration
