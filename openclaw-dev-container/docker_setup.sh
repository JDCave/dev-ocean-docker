#!/bin/bash
docker_username="magicalocean"
container_name="openclaw-dev-container"
version="v1.0.0"
network_name="openclaw-network"

# Build the Docker image without using cache
docker build --no-cache -t ${container_name}:${version} .

# Save the Docker image to a tar file
docker save -o ${container_name}_${version}.tar ${container_name}:${version}

# ======================================================
# docker login
docker login

# tag the image
docker tag ${container_name}:${version} ${docker_username}/${container_name}:${version}

# push the image to Docker Hub
docker push ${docker_username}/${container_name}:${version}

# Mount SSH keys and run the container
sudo umount /mnt/c
sudo mount -t drvfs C: /mnt/c -o metadata,uid=1000,gid=1000

# Detect current user
current_user=$(whoami)

ssh_dir="C:/Users/$current_user/.ssh"
code_dir="D:/Code"
config_dir="D:/OpenClaw/config"
workspace_dir="D:/OpenClaw/workspace"

# Check and create necessary directories
mkdir -p "$code_dir"
mkdir -p "$config_dir"
mkdir -p "$workspace_dir"

# Docker run
docker run -it --name "${container_name}" \
        --restart unless-stopped \
        -v "${ssh_dir}:/root/.ssh" \
        -v "${code_dir}:/workspace/code" \
        -v "${config_dir}:/root/.openclaw/config" \
        -v "${workspace_dir}:/root/.openclaw/workspace" \
        -p 18789:18789 \
        -e "TERM=xterm-256color" \
        --user root \
        "${container_name}:${version}" || error_exit "Failed to start container"
