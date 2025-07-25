#!/bin/bash

# Iseble for Azure - Docker Build Script
# This script builds the Docker image for the project

set -e

# Colors for output
GREEN='\033[0;32m'   # Green text for success messages
BLUE='\033[0;34m'    # Blue text for informational messages
YELLOW='\033[1;33m'  # Yellow text for warning messages
NC='\033[0m'         # No Color: resets text color to default

echo -e "${BLUE}Building Iseble for Azure Docker image...${NC}"

# Build the Docker image
docker build -t iseble-azure:latest .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Docker image built successfully!${NC}"
    echo
    echo "Usage:"
    echo "  Simple Docker:"
    echo "    ./run.sh"
    echo
    echo "  Docker Compose (Development):"
    echo "    docker-compose --profile dev up -d"
    echo "    docker-compose exec iseble bash"
    echo
    echo "  Docker Compose (Production):"
    echo "    docker-compose --profile prod run --rm iseble ansible-playbook playbooks/01-create-infrastructure.yml"
else
    echo -e "\033[0;31m❌ Docker build failed!${NC}"
    exit 1
fi