#!/bin/bash

# Debug script to check paths and permissions in Docker container
echo "=== Docker Container Path Debug ==="
echo "Current working directory: $(pwd)"
echo "Current user: $(whoami)"
echo "User ID: $(id)"
echo
echo "=== Directory Structure ==="
ls -la /
echo
echo "=== Ansible Directory ==="
ls -la /ansible/
echo
echo "=== SSH Keys Directory ==="
ls -la /ansible/files/ssh_keys/ 2>/dev/null || echo "SSH keys directory does not exist"
echo
echo "=== Environment Variables ==="
env | grep -E "(ANSIBLE|AZURE|HOME|PWD)" | sort
echo
echo "=== Python Path ==="
which python3
python3 --version
echo
echo "=== Ansible Version ==="
ansible --version
echo
echo "=== Ansible Collections ==="
ansible-galaxy collection list | grep -E "(azure|cisco)"
echo
echo "=== SSH Key Generation Test ==="
echo "Testing SSH key generation in /ansible/files/ssh_keys/"
mkdir -p /ansible/files/ssh_keys
chmod 777 /ansible/files/ssh_keys
ssh-keygen -t rsa -b 4096 -f /ansible/files/ssh_keys/test-key -N "" -C "test@example.com"
ls -la /ansible/files/ssh_keys/
echo "SSH key generation test completed"
