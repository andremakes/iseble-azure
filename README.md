# Iseble for Azure

Iseble, an anthropomorphic name derived from the fusion of [Cisco ISE](https://www.cisco.com/site/us/en/products/security/identity-services-engine/index.html) and [Ansible](https://docs.ansible.com/), is a project tailored for [Azure](https://azure.microsoft.com/en-us/products/cloud-services/) and does not utilize [ARM templates](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/overview).

Core principles:
- Simplicity
- Modularity
- User Experience

## Quick Start

```bash

# Create Python Virtual Environment
./venv_create.sh

# Run the playbooks
ansible-playbook playbooks/01-create-infrastructure.yml
ansible-playbook playbooks/02-deploy-ise.yml
ansible-playbook playbooks/03-configure-ise.yml
ansible-playbook playbooks/98-destroy-ise-only.yml
ansible-playbook playbooks/99-destroy-resources.yml

# Delete Python Virtual Environment
./delete_create.sh
```
If you need more details, read on.

## Prerequisites

### System Requirements
- **Ubuntu Linux** (recommended) or other Linux distribution
- **Ansible** 2.15+ with Python 3.8+
- **Azure CLI** configured with service principal
- **SSH key** management capability
- **Network connectivity** to Azure and target devices

### Azure Requirements
- **Azure subscription** with appropriate permissions
- **Service principal** with Contributor role
- **ISE image** available in your region (`cisco-ise_3_4`)

## 🔧 Azure Authentication Setup

### Method 1: Service Principal Authentication (Recommended)

This method is suitable for automation and CI/CD:

#### Step 1: Create Service Principal
```bash
# Login to Azure CLI first
az login

# Create service principal
az ad sp create-for-rbac --name "iseble-azure-sp" --role contributor --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID"
```

#### Step 2: Set Environment Variables
```bash
export AZURE_SUBSCRIPTION_ID="your-subscription-id"
export AZURE_TENANT="your-tenant-id"
export AZURE_CLIENT_ID="your-client-id"
export AZURE_SECRET="your-client-secret"
```

#### Step 3: Create .env File (Optional)
```bash
cat > .env << EOF
# Azure Authentication
AZURE_SUBSCRIPTION_ID=your-subscription-id
AZURE_TENANT=your-tenant-id
AZURE_CLIENT_ID=your-client-id
AZURE_SECRET=your-client-secret

# ISE Configuration (optional)
ISE_PASSWORD=ISEisC00LISE
ISE_DOMAIN=local

# VPN Configuration (optional)
VPN_SHARED_KEY=YourSharedKey123!
EOF

# Set secure permissions
chmod 600 .env
```

### Method 2: Azure CLI Authentication (Interactive)
```bash
# Login to Azure CLI
az login

# Verify login
az account show
```

### Method 3: Managed Identity (Azure VM/Container)
If running on an Azure VM or in Azure Container Instances:
```bash
# No additional setup required - uses the VM's managed identity
# Ensure the VM has appropriate permissions assigned
```

## Installation and Setup

### 1. Install System Dependencies (Ubuntu)
```bash
# Update system
sudo apt update

# Install Ansible
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

# Install Ansible az collection for interacting with Azure
ansible-galaxy collection install azure.azcollection --force

# Install Ansible modules for Azure
sudo pip3 install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements.txt
```

### 2. Install on Docker
See [README](docker/README.md) in the docker folder.

### 3. Configure Variables
Edit `vars/main.yml` to customize your deployment:
```bash
# Edit the main variables file
vim vars/main.yml
```

Key variables to review:
- `project_name`: Change if needed (default: "iseble-azure")
- `azure.region`: Change Azure region if needed (default: "westus")
- `ise.vm_size`: Change VM size if needed (default: "Standard_D4s_v3")

## Project Structure

```
iseble-azure/
├── playbooks/
│   ├── 01-create-infrastructure.yml  # Azure infrastructure deployment
│   ├── 02-deploy-ise.yml            # ISE VM deployment
│   ├── 03-configure-ise.yml         # ISE configuration automation
│   ├── 04-create-vpn.yml            # VPN gateway deployment (optional)
│   ├── 98-destroy-ise-only.yml      # Destroy ISE VM only
│   └── 99-destroy-resources.yml     # Destroy all resources
├── vars/
│   └── main.yml                     # Configuration variables
├── collections/
│   └── requirements.yml             # Ansible collections
├── files/
│   └── ssh_keys/                    # SSH key storage
├── inventory/
│   ├── azure_rm.yml                 # Azure dynamic inventory
│   └── localhost.yml                # Localhost inventory
├── examples/
│   └── env_example.sh               # Environment variables template
├── docker/                          # Docker containerization (see docker/README.md)
├── setup.sh                         # Main setup script
├── venv_create.sh                   # Create virtual environment
├── venv_delete.sh                   # Delete virtual environment
└── README.md                        # This file
```

## Deployment Workflow

### Phase 1: Infrastructure (01-create-infrastructure.yml)
- **SSH Key** generation and management
- **Azure Resource Group** creation
- **Virtual Network** with subnets (192.168.100.0/23)
- **Network Security Group** with ISE rules
- **Storage Account** for boot diagnostics
- **Public IP** and network interface

### Phase 2: ISE Deployment (02-deploy-ise.yml)
- **Virtual Machine** deployment with ISE image
- **SSH Key** injection for secure access
- **User Data** configuration for ISE initialization
- **Boot Diagnostics** enablement
- **Deployment Validation** and status reporting

### Phase 3: ISE Configuration (03-configure-ise.yml)
> **Note**
> This playbook is a work in progress and will be updated with additional configuration tasks for Cisco ISE.

- **SCP Repository** creation for backups/patches
- **Network Access Devices** (switches, APs) registration
- **Endpoint Identity Groups** (Corporate, Guest, IoT, BYOD)
- **Guest Portal** with self-registration
- **BYOD Portal** for employee device registration
- **Authorization Policies** for network access control

### Phase 4: VPN (Optional) (04-create-vpn.yml)
> **Note**
> This playbook is a work in progress and will be updated with additional configuration tasks for Cisco ISE.

- **VPN Gateway** public IP
- **Virtual Network Gateway**
- **Local Network Gateway**
- **VPN Connection**

## Architecture

### Network Configuration
- **Region**: westus2
- **VNet**: 192.168.100.0/23
- **Private Subnet**: 192.168.100.0/24 (for ISE)
- **Gateway Subnet**: 192.168.101.0/24 (for VPN)
- **ISE Private IP**: 192.168.100.10

### Security Configuration
- **SSH Key Authentication**: Enabled (no password)
- **Network Security Group**: Minimal required rules
- **Ports Open**: 22 (SSH), 80 (HTTP), 443 (HTTPS), 9060 (ERS), 8910 (PXGrid), 1812/1813 (RADIUS)

### ISE Configuration
- **VM Size**: Standard_D4s_v3 (4 vCPUs, 16 GB RAM)
- **OS Disk**: 300 GB Premium SSD
- **Image**: cisco-ise_3_4 (latest)
- **Admin User**: iseadmin
- **Services**: ERS API, Open API, PXGrid, PXGrid Cloud

## Customization

### Modifying Variables
Edit `vars/main.yml` to adjust the project to your environment.

## Cleanup and Maintenance

### Destroy ISE VM Only (Preserves Infrastructure)
```bash
ansible-playbook playbooks/98-destroy-ise-only.yml
```

This will delete:
- ISE Virtual Machine
- SSH Keys (optional)

But preserve:
- Resource Group
- Virtual Network and Subnets
- Network Security Group
- Storage Account
- Network Interface
- Public IP Address
- VPN Gateway (if deployed)

### Destroy All Resources
```bash
ansible-playbook playbooks/99-destroy-resources.yml
```

## Troubleshooting

### Common Issues

#### 1. Azure Authentication Errors
**Error**: `Authentication failed for Azure`

**Solution**:
- Verify your Azure service principal credentials are correct
- Check that the service principal has the necessary permissions (Contributor role)
- Ensure environment variables are properly set:
  ```bash
  echo $AZURE_CLIENT_ID
  echo $AZURE_SECRET
  echo $AZURE_SUBSCRIPTION_ID
  echo $AZURE_TENANT
  ```

#### 2. Resource Group Already Exists
**Error**: `Resource group already exists`

**Solution**:
```bash
# Delete the existing resource group manually
az group delete --name rg-iseble-azure --yes

# Or use the cleanup playbook
ansible-playbook playbooks/99-destroy-resources.yml
```

#### 3. SSH Connection Issues
**Error**: `SSH connection failed`

**Solution**:
- Wait for the VM to fully boot (can take 10-15 minutes)
- Verify the SSH key was properly generated
- Check network security group rules allow SSH (port 22)
- Try connecting manually:
  ```bash
  ssh -i files/ssh_keys/iseble-azure iseadmin@<public-ip>
  ```

#### 4. ISE Services Not Starting
**Error**: `ISE services not running`

**Solution**:
- Wait longer for ISE to fully initialize (up to 30 minutes)
- Check ISE logs via Azure serial console
- Verify the user data configuration is correct
- Check if the ISE image is compatible with your region

#### 5. SSH Key Issues
**Error**: `file not found: files/ssh_keys/iseble-azure.pub`

**Solution**:
```bash
# The deploy playbook automatically generates SSH keys if they don't exist
# You can also manually generate SSH keys if needed:
mkdir -p files/ssh_keys
ssh-keygen -t rsa -b 2048 -f files/ssh_keys/iseble-azure -N ""
```

### Debugging Commands

#### Check Azure Resources
```bash
# List resource groups
az group list --output table

# List VMs
az vm list --resource-group rg-iseble-azure --output table

# Check VM status
az vm show --resource-group rg-iseble-azure --name ise-iseble-azure --show-details
```

#### Check ISE Status
```bash
# Connect to ISE and check services
ssh -i files/ssh_keys/iseble-azure iseadmin@<public-ip>
show application status ise
show version
show system info
```

#### Check Network Configuration
```bash
# List network interfaces
az network nic list --resource-group rg-iseble-azure --output table

# Check public IP
az network public-ip show --resource-group rg-iseble-azure --name pip-iseble-azure
```

### Log Locations
- **Ansible Logs**: Use `-v`, `-vv`, or `-vvv` flags
- **Azure Logs**: Azure Portal → Resource → Activity Log
- **ISE Logs**: ISE Admin → Operations → Reports → Diagnostics

## Docker Support

For Docker-based deployment, see the [docker/README.md](docker/README.md) file for complete documentation.

## Documentation References

- [Cisco ISE 3.4 Administration Guide](https://www.cisco.com/c/en/us/support/security/identity-services-engine/products-installation-and-configuration-guides-list.html)
- [Ansible Cisco ISE Collection](https://galaxy.ansible.com/cisco/ise)
- [Azure Ansible Collection](https://galaxy.ansible.com/azure/azcollection)
- [Azure ISE Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cisco-ise)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
