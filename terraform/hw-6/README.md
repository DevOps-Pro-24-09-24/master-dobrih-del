# Terraform Configuration for AWS Infrastructure

## Overview
```txt
This Terraform configuration sets up the following AWS infrastructure:
1. A VPC with two subnets:
   - Public subnet with internet access.
   - Private subnet without internet access.
2. Security Groups:
   - `sg_front`: Allows inbound traffic on TCP ports 22 (SSH), 80 (HTTP), and 443 (HTTPS). Allows all outbound traffic.
   - `sg_back`: Allows inbound traffic only from `sg_front`. Allows all outbound traffic.
3. EC2 Instances:
   - `web`: An instance in the public subnet.
   - `db`: An instance in the private subnet.

## Files
- `provider.tf`: AWS provider configuration.
- `backend.tf`: Configuration for the `db` instance.
- `main.tf`: Main resources including VPC, subnets, and `web` instance.
- `variables.tf`: Input variables.
- `sg.tf`: Security groups.
- `outputs.tf`: Output variables.
```
## How to Apply
### 1. **Initialize Terraform**:
```sh
terraform init
```
### 2. Check the Plan:
```sh
terraform plan
```
### 3. Apply the Plan:
```sh
terraform apply
```
### Confirm the apply with yes.

## How to Verify
### After applying the configuration, you can verify the created resources in the AWS Management Console:
###     VPC: Check the VPC and subnets.
###     Security Groups: Verify the security group rules.
###     EC2 Instances: Verify the instances and their IP addresses.
###     You can also check the output variables in the terminal to see the IDs and IP addresses of the created resources. 