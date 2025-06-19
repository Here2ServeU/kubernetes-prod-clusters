# Emmanuel Services – Deploying a Professional Website on AWS EKS (with ECR)

This guide walks you through how to provision infrastructure on AWS EKS, configure Amazon ECR, push a Docker image, deploy the Emmanuel Services website, and enable monitoring and alerting with Slack integration.

---

## 📁 Project Structure

```
emmanuel-k8s-prod/
├── cleanup.sh
├── manifests/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── fluent-bit-elasticsearch.yaml
├── helm/
│   └── prometheus-stack/
│       └── values.yaml
├── terraform/
│   ├── aws/
│   ├── gcp/
│   └── azure/
├── website/
│   └── Dockerfile
└── README.md
```

---

## Step 1: Prerequisites

Ensure you have installed:
- AWS CLI and configured credentials
- Terraform
- kubectl
- Docker
- Helm

Optional:
- Google Cloud SDK (for GKE)
- Azure CLI (for AKS)

---

## Step 2: Provision Infrastructure with Terraform

Navigate to the AWS Terraform directory:

```bash
cd terraform/aws
terraform init
terraform apply -auto-approve
```

Terraform will:
- Create a VPC
- Deploy an EKS cluster
- Configure IAM roles and node groups
- (Optionally) create an Amazon ECR repository

---

## Step 3: Authenticate Docker to Amazon ECR

Create ECR repository:

```bash
aws ecr create-repository --repository-name emmanuel-services
```

Authenticate Docker:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <your_account_id>.dkr.ecr.us-east-1.amazonaws.com
```

---

## Step 4: Build and Push Docker Image

```bash
cd website
docker build -t emmanuel-services .

# Tag and push to ECR
docker tag emmanuel-services:latest <your_account_id>.dkr.ecr.us-east-1.amazonaws.com/emmanuel-services:latest
docker push <your_account_id>.dkr.ecr.us-east-1.amazonaws.com/emmanuel-services:latest
```

---

## Step 5: Deploy the Web App on EKS

```bash
kubectl apply -f ../manifests/deployment.yaml
kubectl apply -f ../manifests/service.yaml
```

---

## Step 6: Access the Website

```bash
kubectl get svc emmanuel-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Open in browser:

```
http://<load-balancer-dns>
```

---

## Step 7: Monitoring (Prometheus + Grafana)

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

Access Grafana:

```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
```

Go to: http://localhost:3000 (login: admin/admin)

---

## Step 8: Slack Alerting Integration

1. Create Slack webhook via **Apps > Incoming WebHooks**
2. Edit `helm/prometheus-stack/values.yaml`:

```yaml
alertmanager:
  config:
    global:
      resolve_timeout: 5m
    route:
      group_by: ['alertname']
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 1h
      receiver: 'slack-notifications'
    receivers:
      - name: 'slack-notifications'
        slack_configs:
          - api_url: 'https://hooks.slack.com/services/your/webhook/url'
            channel: '#alerts'
            send_resolved: true
```

3. Upgrade Helm release:

```bash
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack   -n monitoring -f helm/prometheus-stack/values.yaml
```

---

## Step 9: Optional – Centralized Logging

```bash
kubectl apply -f manifests/fluent-bit-elasticsearch.yaml
```

---

## Optional: Deploy to GCP or Azure

### GKE

```bash
cd terraform/gcp
terraform init && terraform apply -auto-approve
```

### AKS

```bash
cd terraform/azure
terraform init && terraform apply -auto-approve
```

---

## Fixing kubectl Cluster Access Errors

```
error validating data: failed to download openapi: Get "http://localhost:8080/openapi/v2": dial tcp [::1]:8080: connect: connection refused
```

**Fix**:

```bash
kubectl config current-context
aws eks update-kubeconfig --region us-east-1 --name emmanuel-cluster
kubectl get nodes
```

Then retry:

```bash
kubectl apply -f manifests/deployment.yaml
kubectl apply -f manifests/service.yaml
```

---

## Cleanup Resources

To avoid AWS charges:

### Destroy Terraform Infrastructure

```bash
cd terraform/aws
terraform destroy -auto-approve
```

### Delete ECR Images (optional)

```bash
aws ecr delete-repository --repository-name emmanuel-services --force
```

### Clear Kubeconfig Context (optional)

```bash
kubectl config delete-context <context-name>
```

### Run Local Cleanup Script

```bash
chmod +x cleanup.sh
./cleanup.sh
```

---

## Author

**Emmanuel Naweji**  
Cloud | DevOps | SRE | FinOps | AI Engineer  
Modernizing infrastructure and mentoring the next generation of elite engineers.

