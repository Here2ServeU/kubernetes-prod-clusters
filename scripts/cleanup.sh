#!/bin/bash

echo "Starting cleanup process for Docker, Terraform, and Kubernetes resources..."

# --- Docker Cleanup ---

echo "Removing unused Docker containers..."
docker container prune -f

echo "Removing unused Docker images..."
docker image prune -a -f

echo "Removing unused Docker volumes..."
docker volume prune -f

echo "Removing unused Docker networks..."
docker network prune -f

echo "Docker cleanup completed."


# --- Terraform Cleanup ---

echo "Removing Terraform .terraform directories and state files..."
find . -type d -name ".terraform" -exec rm -rf {} +
find . -type f -name "terraform.tfstate" -exec rm -f {} +
find . -type f -name "terraform.tfstate.backup" -exec rm -f {} +
find . -type f -name "terraform.tfvars.lock.hcl" -exec rm -f {} +

echo "Terraform local file cleanup completed."


# --- Kubernetes Config Cleanup ---

echo "Removing Kubernetes kubeconfig from ~/.kube/config..."
rm -f ~/.kube/config
echo "Kubeconfig removed."


echo "Cleanup process completed successfully."
