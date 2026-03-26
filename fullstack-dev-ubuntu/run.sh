# !/bin/bash
version="v1.0.1"

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
docker push your_dockerhub_username/fullstack-dev-env:${version}

# Mount SSH keys and run the container
sudo umount /mnt/c
sudo mount -t drvfs C: /mnt/c -o metadata,uid=1000,gid=1000

# Docker run
docker run -it --name fullstack-dev-container --restart unless-stopped -v "C:/Users/Jared J D CHEN/.ssh:/root/.ssh" -v "D:/Code:/workspace/code" -p 3000:3000 --user root fullstack-dev-env:v1.0.1


apt install -y libwebkit2gtk-4.1-dev build-essential libssl-dev libayatana-appindicator3-dev librsvg2-dev
