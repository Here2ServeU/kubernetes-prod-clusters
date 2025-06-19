# Emmanuel Services – Kubernetes Production Cluster Setup

This project sets up a secure, scalable, and observable Kubernetes production cluster to run **Emmanuel Services**. It supports deployment to **AWS (EKS)** with optional configurations for **Azure (AKS)**, **Google Cloud (GKE)**, and **bare-metal via kubeadm**. It includes **Prometheus and Grafana** monitoring for real-time visibility.

---

## Key Features

- Infrastructure as Code with Terraform
- Multi-cloud and kubeadm support (EKS, AKS, GKE, Bare Metal)
- Production-grade cluster setup with RBAC and secrets management
- Built-in observability with Prometheus + Grafana
- Optional centralized logging with Fluent Bit and Elasticsearch

---

## Technology Stack

- Terraform
- Kubernetes (EKS / AKS / GKE / kubeadm)
- Helm
- Prometheus + Grafana (Monitoring)
- Fluent Bit + Elasticsearch (Logging)
- AWS / Azure / GCP support

---

## Project Structure

```
.
├── terraform/              # Cloud-specific infrastructure provisioning
│   ├── aws/                # AWS EKS scripts
│   ├── azure/              # Azure AKS scripts
│   ├── gcp/                # Google GKE scripts
├── helm/
│   └── prometheus-stack/   # Prometheus + Grafana Helm values
├── manifests/
│   └── rbac.yaml           # RBAC policy templates
├── kubeadm/
│   └── install.sh          # Bare-metal kubeadm installer
└── README.md
```

---

## Step-by-Step Deployment

### Step 1: Clone the Project

```bash
git clone https://github.com/Here2ServeU/emmanuel-k8s-prod.git
cd emmanuel-k8s-prod
```

---

### Step 2: Deploy to AWS EKS

```bash
cd terraform/aws
terraform init
terraform apply -auto-approve
```

This creates the VPC, subnets, EKS control plane, and worker nodes.

---

### Step 3: Connect to the EKS Cluster

```bash
aws eks update-kubeconfig --region us-east-1 --name emmanuel-cluster
kubectl get nodes
```

---

### Step 4: Install Prometheus + Grafana for Monitoring

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace
```

Access Grafana:
```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
```
Then open [http://localhost:3000](http://localhost:3000) and log in (default: admin/admin).

---

### Step 5: Apply RBAC Policies

```bash
kubectl apply -f manifests/rbac.yaml
```

---

### Step 6 (Optional): Deploy to GKE or AKS

```bash
cd terraform/gcp   # or terraform/azure
terraform init
terraform apply -auto-approve
```

---

### Step 7 (Optional): Install on Bare Metal

```bash
cd kubeadm
bash install.sh
```

---

## `kubeadm/install.sh` (Bare Metal)

```bash
#!/bin/bash
# Kubeadm Bare-Metal Installer (Ubuntu 20.04+)

set -e

sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https ca-certificates curl
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

sudo kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

---

## Real-Time Monitoring with Grafana

- Dashboards: Kubernetes Cluster, Node Exporter, API Server, etc.
- Metrics via Prometheus scraping `/metrics` endpoints
- Visual alerts and SLO dashboard for Emmanuel Services

---

## Author

**Emmanuel Naweji**  
Cloud | DevOps | SRE | FinOps | AI Engineer  
Modernizing infrastructure and building top 1% engineers with real-world projects

![AWS Certified](https://img.shields.io/badge/AWS-Certified-blue?logo=amazonaws)
![Azure Solutions Architect](https://img.shields.io/badge/Azure-Solutions%20Architect-0078D4?logo=microsoftazure)
![CKA](https://img.shields.io/badge/Kubernetes-CKA-blue?logo=kubernetes)
![FinOps](https://img.shields.io/badge/FinOps-Cost%20Optimization-green?logo=money)
![OpenAI](https://img.shields.io/badge/AI-OpenAI-ff9900?logo=openai)

---

## Connect with Me

- [LinkedIn](https://www.linkedin.com/in/ready2assist/)
- [GitHub](https://github.com/Here2ServeU)
- [Medium](https://medium.com/@here2serveyou)

---

## Book a Consultation

Need help with Kubernetes or production-grade DevOps pipelines?  
[Schedule a free 1:1 call](https://bit.ly/letus-meet)

