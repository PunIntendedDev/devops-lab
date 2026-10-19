#!/bin/bash
set -e

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker not found. Installing..."
  apt-get update -y
  apt-get install -y docker.io
else
  echo "Docker already installed."
fi

systemctl enable --now docker

if ! command -v curl >/dev/null 2>&1; then
  apt-get install -y curl
fi

if docker ps -a --format '{{.Names}}' | grep -qx "devops-web"; then
  echo "Removing existing devops-web container..."
  docker rm -f devops-web
fi

docker run -d --name devops-web -p 80:80 \
  -v /vagrant/website:/usr/share/nginx/html \
  nginx:alpine

sleep 3

docker ps --filter "name=devops-web"
curl -I http://localhost