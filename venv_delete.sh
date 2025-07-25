#!/bin/bash

# Iseble for Azure - Delete Python Virtual Environment
# This script removes the Python virtual environment for the project

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

# Check if virtual environment exists
check_venv_exists() {
    if [[ ! -d "venv" ]]; then
        print_warning "Virtual environment 'venv' does not exist."
        print_status "Nothing to delete. Exiting."
        exit 0
    fi

    print_status "Found virtual environment: venv/"
}

# Check if virtual environment is currently active
check_venv_active() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        print_warning "Virtual environment is currently active!"
        print_warning "Active environment: $VIRTUAL_ENV"
        echo

        print_warning "This script will delete the virtual environment directory."
        print_status "After deletion, you'll need to deactivate it manually with: deactivate"
        echo

        read -p "Continue with deletion? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Deletion cancelled. Please deactivate manually first: deactivate"
            exit 0
        fi
    fi
}

# Confirm deletion
confirm_deletion() {
    print_warning "This will permanently delete the virtual environment and all installed packages!"
    echo
    print_status "Virtual environment location: $(pwd)/venv/"
    print_status "Size: $(du -sh venv 2>/dev/null | cut -f1 || echo 'unknown')"
    echo
    read -p "Are you sure you want to delete the virtual environment? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Deletion cancelled. Virtual environment preserved."
        exit 0
    fi
}

# Delete virtual environment
delete_venv() {
    print_status "Deleting virtual environment..."

    # Get size before deletion for confirmation
    VENV_SIZE=$(du -sh venv 2>/dev/null | cut -f1 || echo "unknown")

    # Remove the directory
    rm -rf venv

    if [[ $? -eq 0 ]]; then
        print_success "Virtual environment deleted successfully!"
        print_status "Freed space: $VENV_SIZE"
    else
        print_error "Failed to delete virtual environment."
        exit 1
    fi
}

# Clean up any remaining files
cleanup_files() {
    print_status "Checking for any remaining virtual environment files..."

    # Check for common virtual environment related files
    local files_to_check=(
        ".python-version"
        "pyvenv.cfg"
        "pip-log.txt"
        "pip-delete-this-directory.txt"
    )

    local found_files=()
    for file in "${files_to_check[@]}"; do
        if [[ -f "$file" ]]; then
            found_files+=("$file")
        fi
    done

    if [[ ${#found_files[@]} -gt 0 ]]; then
        print_warning "Found additional virtual environment files:"
        for file in "${found_files[@]}"; do
            echo "  - $file"
        done

        read -p "Do you want to delete these files as well? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            for file in "${found_files[@]}"; do
                rm -f "$file"
                print_status "Deleted: $file"
            done
            print_success "Additional files cleaned up!"
        fi
    else
        print_status "No additional virtual environment files found."
    fi
}

# Display completion message
show_completion() {
    echo
    print_success "Virtual environment cleanup complete!"
    echo
    echo -e "${BLUE}What was removed:${NC}"
    echo "  - Python virtual environment (venv/)"
    echo "  - All installed packages and dependencies:"
    echo "    • Ansible and collections (azure.azcollection, cisco.ise)"
    echo "    • Cisco ISE SDK (ciscoisesdk)"
    echo "    • Azure SDK components"
    echo "    • SSH and cryptography libraries"
    echo "  - Virtual environment configuration"
    echo
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo -e "${YELLOW}⚠️  IMPORTANT: You are still in an activated virtual environment!${NC}"
        echo "  The virtual environment directory was deleted, but your shell is still active."
        echo "  To deactivate, run:"
        echo "    deactivate"
        echo "  Or start a new shell session."
        echo
    fi
    echo -e "${BLUE}To recreate the virtual environment:${NC}"
    echo "  ./venv_create.sh"
    echo
    print_status "Cleanup completed successfully! 🧹"
}

# Main execution
main() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Iseble for Azure - Delete Virtual Env${NC}"
    echo -e "${BLUE}================================${NC}"
    echo

    check_venv_exists
    check_venv_active
    confirm_deletion
    delete_venv
    cleanup_files
    show_completion
}

# Run main function
main "$@"