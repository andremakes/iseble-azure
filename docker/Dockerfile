FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and add Ansible PPA
RUN apt-get update && apt-get install -y \
    software-properties-common \
    python3-pip \
    git \
    curl \
    vim \
    openssh-client \
    openssh-server \
    sshpass \
    && add-apt-repository --yes --update ppa:ansible/ansible \
    && apt-get install -y ansible \
    && rm -rf /var/lib/apt/lists/*

# Create ansible user for running as non-root
RUN useradd -m -s /bin/bash ansible



# Install Ansible collections and dependencies globally
RUN ansible-galaxy collection install azure.azcollection --force
RUN ansible-galaxy collection install cisco.ise --force

# Copy requirements.txt and install Python dependencies (ignore system packages conflicts)
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --break-system-packages --ignore-installed PyYAML -r /tmp/requirements.txt
RUN pip3 install --break-system-packages -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements.txt

# Create working directory and ensure tmp directory exists
WORKDIR /ansible
RUN mkdir -p /tmp/.ansible && chmod 777 /tmp/.ansible
RUN mkdir -p /ansible/files/ssh_keys && chmod 777 /ansible/files/ssh_keys

# Set up default ansible.cfg for container
RUN echo '[defaults]' > /ansible/ansible.cfg && \
    echo 'host_key_checking = False' >> /ansible/ansible.cfg && \
    echo 'retry_files_enabled = False' >> /ansible/ansible.cfg && \
    echo 'stdout_callback = yaml' >> /ansible/ansible.cfg && \
    echo 'local_tmp = /tmp/.ansible' >> /ansible/ansible.cfg && \
    echo 'remote_tmp = /tmp/.ansible' >> /ansible/ansible.cfg

# Create pip configuration to allow system packages override
RUN mkdir -p /etc/pip && \
    echo '[global]' > /etc/pip/pip.conf && \
    echo 'break-system-packages = true' >> /etc/pip/pip.conf

# Ensure PATH includes user's local bin
ENV PATH="/home/ansible/.local/bin:$PATH"

# Create startup script to ensure proper permissions
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'mkdir -p /ansible/files/ssh_keys' >> /start.sh && \
    echo 'chmod 777 /ansible/files/ssh_keys' >> /start.sh && \
    echo 'export ANSIBLE_CRYPTO_OPENSSH_KEYPAIR_CHATTR=false' >> /start.sh && \
    echo 'export ANSIBLE_CRYPTO_OPENSSH_KEYPAIR_USE_CHATTR=false' >> /start.sh && \
    echo 'export ANSIBLE_CRYPTO_OPENSSH_KEYPAIR_USE_ATTR=false' >> /start.sh && \
    echo 'export ANSIBLE_UNSAFE_WRITES=true' >> /start.sh && \
    echo 'mv /usr/bin/chattr /usr/bin/chattr.disabled 2>/dev/null || true' >> /start.sh && \
    echo 'exec "$@"' >> /start.sh && \
    chmod +x /start.sh

# Default command
ENTRYPOINT ["/start.sh"]
CMD ["bash"]