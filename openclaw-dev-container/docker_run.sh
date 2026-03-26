#!/bin/bash
# Configuration
container_name="openclaw-dev-container"
version="v1.0.0"
network_name="openclaw-network"

# Detect current user
current_user=$(whoami)

ssh_dir="C:/Users/$current_user/.ssh"
code_dir="D:/Code"
config_dir="D:/OpenClaw/config"
workspace_dir="D:/OpenClaw/workspace"

echo "Starting OpenClaw Development Environment..."
echo "Current user: $current_user"
echo "SSH directory: $ssh_dir"
echo "Code directory: $code_dir"
echo "Config directory: $config_dir"
echo "Workspace directory: $workspace_dir"

# Check and create necessary directories
mkdir -p "$code_dir"
mkdir -p "$config_dir"
mkdir -p "$workspace_dir"

# Check SSH directory
if [ ! -d "$ssh_dir" ]; then
    echo "Warning: SSH directory $ssh_dir does not exist"
fi

# Verify directory contents
echo "Code directory: $code_dir"
ls -la "$code_dir" || echo "Directory is empty or inaccessible"
echo "Config directory: $config_dir"
ls -la "$config_dir" || echo "Directory is empty or inaccessible"
echo "Workspace directory: $workspace_dir"
ls -la "$workspace_dir" || echo "Directory is empty or inaccessible"


docker run -it --name "$container_name" \
        --restart unless-stopped \
        -v "${ssh_dir}:/root/.ssh" \
        -v "${code_dir}:/workspace/code" \
        -v "${config_dir}:/root/.openclaw/config" \
        -v "${workspace_dir}:/root/.openclaw/workspace" \
        -p 18789:18789 \
        -e "TERM=xterm-256color" \
        --user root \
        "${container_name}:${version}" || error_exit "Failed to start container"