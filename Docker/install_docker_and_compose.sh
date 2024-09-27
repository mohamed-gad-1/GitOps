#!/bin/bash

# Update the package list
sudo apt update

# Install required packages to allow apt to use a repository over HTTPS
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package list again
sudo apt update

# Install Docker Engine, containerd, and Docker CLI
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Verify Docker installation
sudo docker run hello-world

# Manage Docker as a non-root user (optional)
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

# Download Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/2.29.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Apply executable permissions to the binary
sudo chmod +x /usr/local/bin/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Verify Docker Compose installation
docker-compose --version

echo "Docker and Docker Compose have been successfully installed."


sudo apt-get update
sudo apt-get install docker-compose-plugin
