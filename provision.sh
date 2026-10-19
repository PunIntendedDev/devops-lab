#!/bin/bash
set -e

# Install Docker only if missing
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker not found. Installing..."
  dnf install -y dnf-plugins-core
  dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  dnf install -y docker-ce docker-ce-cli containerd.io
else
  echo "Docker already installed."
fi

# Start Docker
systemctl enable --now docker

# Install curl if missing
if ! command -v curl >/dev/null 2>&1; then
  dnf install -y curl --allowerasing
fi

# Remove old container if it exists
if docker ps -a --format '{{.Names}}' | grep -qx "devops-web"; then
  echo "Removing existing devops-web container..."
  docker rm -f devops-web
fi

# Run the container (label=disable avoids SELinux 403 errors on CentOS)
docker run -d --name devops-web -p 80:80 \
  --security-opt label=disable \
  -v /vagrant/website:/usr/share/nginx/html \
  nginx:alpine

sleep 3

docker ps --filter "name=devops-web"
curl -I http://localhost