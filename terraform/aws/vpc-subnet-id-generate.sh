#!/bin/bash

# Define allowed availability zones for EKS control plane
ALLOWED_ZONES=("us-east-1a" "us-east-1b" "us-east-1c" "us-east-1d" "us-east-1f")

# Automatically pick first VPC (change filter if needed)
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[0].VpcId" --output text)

# Fetch subnets in allowed AZs
SUBNET_IDS=$(aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query "Subnets[?AvailabilityZone=='${ALLOWED_ZONES[0]}' || AvailabilityZone=='${ALLOWED_ZONES[1]}' || AvailabilityZone=='${ALLOWED_ZONES[2]}' || AvailabilityZone=='${ALLOWED_ZONES[3]}' || AvailabilityZone=='${ALLOWED_ZONES[4]}'].SubnetId" \
  --output text)

# Format subnet IDs into Terraform HCL list
HCL_SUBNET_IDS=$(echo $SUBNET_IDS | awk '{printf("[\"%s\"", $1); for(i=2;i<=NF;i++) printf(", \"%s\"", $i); print("]")}')

# Echo outputs
echo "Detected VPC: $VPC_ID"
echo "Detected Subnets in valid AZs: $HCL_SUBNET_IDS"

# Update terraform.tfvars
sed -i '' -E "s|^vpc_id *=.*|vpc_id = \"$VPC_ID\"|" terraform.tfvars
sed -i '' -E "s|^subnet_ids *=.*|subnet_ids = $HCL_SUBNET_IDS|" terraform.tfvars

echo "✅ terraform.tfvars has been updated with valid subnets!"
