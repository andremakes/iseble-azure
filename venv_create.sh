#!/bin/bash

# Iseble for Azure - Create Python Virtual Environment
# This script creates a Python 3.12 virtual environment for the project

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check and install required packages for virtual environment
check_and_install_packages() {
    print_status "Checking for required packages..."

    # Check if we're on a Debian/Ubuntu system
    if [[ -f /etc/debian_version ]]; then
        print_status "Detected Debian/Ubuntu system"

        # Check if python3-venv is installed
        if ! dpkg -l | grep -q python3-venv; then
            print_warning "python3-venv package not found. Installing required packages..."

            # Check if we have sudo privileges
            if [[ $EUID -eq 0 ]]; then
                print_status "Running as root, updating package lists..."
                apt update
                print_status "Installing python3-venv..."
                apt install -y python3-venv
            else
                print_status "Requesting sudo privileges to install packages..."
                sudo apt update
                print_status "Installing python3-venv..."
                sudo apt install -y python3-venv
            fi

            if [[ $? -eq 0 ]]; then
                print_success "python3-venv installed successfully!"
            else
                print_error "Failed to install python3-venv. Please install it manually:"
                print_error "  sudo apt update && sudo apt install python3-venv"
                exit 1
            fi
        else
            print_success "python3-venv package already installed"
        fi
    else
        print_warning "Not a Debian/Ubuntu system. Please ensure python3-venv is installed manually."
    fi
}

# Check if Python 3.12 is available
check_python() {
    print_status "Checking for Python 3.12..."

    if command -v python3.12 &> /dev/null; then
        PYTHON_CMD="python3.12"
        print_success "Python 3.12 found: $(python3.12 --version)"
    elif command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
        if [[ "$PYTHON_VERSION" == "3.12" ]]; then
            PYTHON_CMD="python3"
            print_success "Python 3.12 found: $(python3 --version)"
        else
            print_error "Python 3.12 not found. Found version: $PYTHON_VERSION"
            print_error "Please install Python 3.12 and try again."
            exit 1
        fi
    else
        print_error "Python 3 not found. Please install Python 3.12 and try again."
        exit 1
    fi
}

# Check if virtual environment already exists
check_existing_venv() {
    if [[ -d "venv" ]]; then
        print_warning "Virtual environment 'venv' already exists!"
        read -p "Do you want to remove it and create a new one? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Removing existing virtual environment..."
            rm -rf venv
            print_success "Existing virtual environment removed."
        else
            print_status "Keeping existing virtual environment. Exiting."
            exit 0
        fi
    fi
}

# Create virtual environment
create_venv() {
    print_status "Creating Python 3.12 virtual environment..."
    $PYTHON_CMD -m venv venv

    if [[ $? -eq 0 ]]; then
        print_success "Virtual environment created successfully!"
    else
        print_error "Failed to create virtual environment."
        exit 1
    fi
}

# Activate virtual environment and install requirements
setup_venv() {
    print_status "Activating virtual environment..."
    source venv/bin/activate

    print_status "Upgrading pip..."
    pip install --upgrade pip

    if [[ -f "requirements.txt" ]]; then
        print_status "Installing requirements from requirements.txt..."
        pip install -r requirements.txt
        print_success "Requirements installed successfully!"
    else
        print_status "Installing core packages manually..."
        print_status "Installing Ansible..."
        pip install ansible

        print_status "Installing Cisco ISE SDK..."
        pip install ciscoisesdk
    fi

    print_status "Installing Azure collection via ansible-galaxy..."
    ansible-galaxy collection install azure.azcollection --force

    print_status "Installing Cisco ISE collection via ansible-galaxy..."
    ansible-galaxy collection install cisco.ise --force

    print_status "Installing Azure collection Python requirements..."
    AZURE_REQUIREMENTS="$HOME/.ansible/collections/ansible_collections/azure/azcollection/requirements.txt"
    if [[ -f "$AZURE_REQUIREMENTS" ]]; then
        pip install -r "$AZURE_REQUIREMENTS"
        print_success "Azure collection requirements installed successfully!"
    else
        print_warning "Azure collection requirements file not found at: $AZURE_REQUIREMENTS"
        print_warning "Some Azure modules may not work properly. Installing common Azure dependencies..."
        pip install azure-identity azure-mgmt-resource azure-mgmt-compute azure-mgmt-network
    fi
}

# Display next steps
show_next_steps() {
    echo
    print_success "Virtual environment setup complete!"
    echo
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Activate the virtual environment:"
    echo "   source venv/bin/activate"
    echo
    echo "2. Verify installation:"
    echo "   ansible --version"
    echo "   ansible-galaxy collection list"
    echo "   python -c 'import ciscoisesdk; print(f\"ISE SDK: {ciscoisesdk.__version__}\")'"
    echo "
    echo "3. Set your Azure and ISE environment variables:"
    echo "   # Azure credentials"
    echo "   export AZURE_CLIENT_ID=<your_client_id>"
    echo "   export AZURE_SECRET=<your_secret>"
    echo "   export AZURE_SUBSCRIPTION_ID=<your_subscription_id>"
    echo "   export AZURE_TENANT=<your_tenant_id>"
    echo "   # ISE credentials (for configuration)"
    echo "   export ISE_REST_USERNAME=iseadmin"
    echo "   export ISE_REST_PASSWORD=<your_ise_password>"
    echo "
    echo "4. Configure your variables in vars/main.yml"
    echo "
    echo "5. Run your Ansible playbooks:"
    echo "   ansible-playbook playbooks/01-create-infrastructure.yml"
    echo
    echo "6. To deactivate the virtual environment:"
    echo "   deactivate"
    echo
    print_status "Happy Isebling! 🚀"
}

# Main execution
main() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Iseble for Azure - Create Virtual Env${NC}"
    echo -e "${BLUE}================================${NC}"
    echo

    check_and_install_packages
    check_python
    check_existing_venv
    create_venv
    setup_venv
    show_next_steps
}

# Run main function
main "$@"
