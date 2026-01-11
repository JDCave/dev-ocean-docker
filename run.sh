# !/bin/bash
version="v1.0.0"

# Build the Docker image without using cache
docker build --no-cache -t fullstack-dev-env:{version} .

# Save the Docker image to a tar file
docker save -o fullstack-dev-env_${version}.tar fullstack-dev-env:${version}

# ======================================================
# docker login
docker login

# tag the image
docker tag fullstack-dev-env:${version} your_dockerhub_username/fullstack-dev-env:${version}

# push the image to Docker Hub
c

# Mount SSH keys and run the container
sudo umount /mnt/c
sudo mount -t drvfs C: /mnt/c -o metadata,uid=1000,gid=1000

# Docker run
docker run -it --name fullstack-dev-container --restart unless-stopped -v "/mnt/c/Users/Jared J D CHEN/.ssh:/root/.ssh" -v "/mnt/c/Code:/workspace/code" --user root fullstack-dev-env:v1.0.0
docker run -it --name fullstack-dev-container --restart unless-stopped -v "C:/Users/Jared J D CHEN/.ssh:/root/.ssh" -v "D:/Code:/workspace/code" -p 3000:3000 --user root fullstack-dev-env:v1.0.0

# 同时挂载：
# 1. Windows本地.ssh目录 → 容器内/root/.ssh（Git认证用）
# 2. Windows本地代码目录 → 容器内/app（项目开发用）
docker run -it ^
  -v C:/Users/你的用户名/.ssh:/root/.ssh ^  # 挂载ssh目录（Git认证）
  -v D:/Code:/workspace/code ^         # 挂载代码目录（项目开发）
  -p 3000:3000 ^                            # 端口映射（按需调整）
  --name my-dev-container ^
