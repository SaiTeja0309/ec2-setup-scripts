#!/bin/bash
set -e

echo "=== Updating system packages ==="
sudo yum update -y

echo "=== Installing dependencies ==="
sudo yum install -y curl git wget

echo "=== Installing Docker ==="
sudo amazon-linux-extras enable docker
sudo yum install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user

echo "=== Verifying Docker installation ==="
docker --version

echo "=== Installing K3s (lightweight Kubernetes) ==="
curl -sfL https://get.k3s.io | sh -
sudo systemctl enable k3s
sudo systemctl start k3s

echo "=== Waiting for K3s to be ready ==="
sleep 20
sudo kubectl get nodes

echo "=== Installing Jenkins inside Docker ==="
# Pull official Jenkins LTS image
docker pull jenkins/jenkins:lts

# Create a persistent volume for Jenkins data
sudo mkdir -p /var/jenkins_home
sudo chown -R 1000:1000 /var/jenkins_home

# Run Jenkins container
docker run -d \
  --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v /var/jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts

echo "=== Jenkins container started ==="
docker ps | grep jenkins

echo "=== Jenkins initial admin password ==="
sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

echo "=== Installation Complete! ==="
echo "Access Jenkins at: http://<your-ec2-public-ip>:8080"
