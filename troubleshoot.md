
# Troubleshooting Guide – Emmanuel Services on AWS EKS

This guide provides step-by-step fixes for common issues when deploying Emmanuel Services on AWS EKS using Terraform and Kubernetes.

---

## 1. Terraform Errors – Unsupported Arguments

**Error:**
```
Unsupported argument
```

**Cause:**
The EKS module may have changed or deprecated arguments like:
- `subnets`
- `node_groups`
- `enable_aws_auth`
- `manage_aws_auth_configmap`

**Fix:**
Update to supported arguments as per the module documentation. Replace deprecated `node_groups` with `eks_managed_node_groups`.

---

## 2. Output Error – Unsupported Attribute

**Error:**
```
module.eks.kubeconfig – This object does not have an attribute named "kubeconfig".
```

**Fix:**
Use supported output values like:

```hcl
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
```

Update your kubeconfig with:

```bash
aws eks update-kubeconfig --region us-east-1 --name emmanuel-cluster
```

---

## 3. Availability Zone Error

**Error:**
```
UnsupportedAvailabilityZoneException
```

**Fix:**
Ensure selected subnets are in EKS-supported AZs such as `us-east-1a`, `us-east-1b`, `us-east-1c`.

---

## 4. Kubernetes API Server Credentials

**Error:**
```
You must be logged in to the server (the server has asked for the client to provide credentials)
```

**Fix:**
Update kubeconfig:

```bash
aws eks update-kubeconfig --region us-east-1 --name emmanuel-cluster
```

---

## 5. Timeout During kubectl apply

**Error:**
```
failed to download openapi: connection refused or i/o timeout
```

**Fix:**
Check your cluster connection and ensure endpoint access:

```bash
kubectl config current-context
aws eks update-kubeconfig --region us-east-1 --name emmanuel-cluster
```

If cluster is private, temporarily enable public access:

```bash
aws eks update-cluster-config   --region us-east-1   --name emmanuel-cluster   --resources-vpc-config endpointPublicAccess=true,publicAccessCidrs=<your_ip>/32
```

---

## 6. sts:AssumeRole Access Denied

**Error:**
```
AccessDenied: Not authorized to perform sts:AssumeRole
```

**Fix:**
Update the trust policy of the IAM role to allow your IAM user to assume it.

---

## 7. Empty VPC or Subnet IDs in terraform.tfvars

**Fix:**
Ensure subnet detection script only includes valid, public subnets in supported AZs. Regenerate using AWS CLI or updated Bash script.

---

## 8. Load Balancer Not Accessible

**Fix:**
Ensure service type is LoadBalancer:

```yaml
spec:
  type: LoadBalancer
```

Fetch public endpoint:

```bash
kubectl get svc emmanuel-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

---

## 9. Cleanup Resources

**Command:**
```bash
terraform destroy -auto-approve
aws ecr delete-repository --repository-name emmanuel-services --force
```

---


## Author

**Emmanuel Naweji**  
Cloud | DevOps | SRE | FinOps | AI Engineer  
Modernizing infrastructure and mentoring the next generation of elite engineers. 
