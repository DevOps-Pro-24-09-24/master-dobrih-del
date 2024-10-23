## resources witch support tagging:
# instance (EC2 instances)
# volume (EBS volumes)
# internet-gateway (Internet Gateways)
# subnet (Subnets)
# vpc (VPCs)
# security-group (Security Groups)
# network-interface (Network Interfaces)
# route-table (Route Tables)
# natgateway (NAT Gateways)

## 1.
## create VPC
```sh
aws ec2 create-vpc \
    --cidr-block 192.168.0.0/24  \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=test-VPC},{Key=env,Value=test},{Key=DZ,Value=hw3}]'
```
## store VPC_ID in variable 
```sh
VPC_ID=($(aws ec2 describe-vpcs \
    --filters "Name=tag:DZ,Values=hw3" \
    --query "Vpcs[*].VpcId" \
    --output text))
```
## Create two subnets (private and public) and store id's in vars
```sh
aws ec2 create-subnet --vpc-id $VPCID --cidr-block 192.168.0.0/25     --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=test-VPC},{Key=env,Value=test},{Key=DZ,Value=hw3}, {Key=access_type, Value=public}]'
aws ec2 create-subnet --vpc-id $VPCID --cidr-block 192.168.0.128/25     --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=test-subnet},{Key=env,Value=test},{Key=DZ,Value=hw3}, {Key=access_type, Value=private }]'

SUBNET_ID_PUBLIC=$(aws ec2 describe-subnets --filters "Name=tag:DZ,Values=hw3" "Name=tag:access_type,Values=public" --query 'Subnets[*].SubnetId' --output text)
SUBNET_ID_PRIVATE=$(aws ec2 describe-subnets --filters "Name=tag:DZ,Values=hw3" "Name=tag:access_type,Values=private" --query 'Subnets[*].SubnetId' --output text)
```
## Create internet gateway for public routing
```sh
aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=test-gateway},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=access_type,Value=public}]'
INTERNET_GATEWAY_ID=$(aws ec2 describe-internet-gateways --filters "Name=tag:DZ,Values=hw3" "Name=tag:access_type,Values=public" --query 'InternetGateways[*].InternetGatewayId' --output text)
```
## Ataach internet gateway to public VPC
```sh
aws ec2 attach-internet-gateway --internet-gateway-id $INTERNET_GATEWAY_ID --vpc-id $VPC_ID
```
<!-- ## check attaching 
➜  master-dobrih-del git:(hw-3) ✗ INTERNET_GATEWAY_ATTACH=$(
    
aws ec2 describe-internet-gateways --filters "Name=tag:DZ,Values=hw3" "Name=tag:access_type,Values=public" --query 'InternetGateways[*].Attachments' --output text -->

## Create routing tables
```sh
aws ec2 create-route-table --vpc-id $VPC_ID  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=test-routetable-public},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=access_type,Value=public}]'

aws ec2 create-route-table --vpc-id $VPC_ID  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=test-routetable-private},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=access_type,Value=private}]'
```
## Store route tables id's to vars
```sh
ROUTE_TABLE_ID_PUBLIC=$(aws ec2 describe-route-tables --filters "Name=tag:DZ,Values=hw3" "Name=tag:access_type,Values=public" --query 'RouteTables[*].RouteTableId' --output text)

ROUTE_TABLE_ID_PRIVATE=$(aws ec2 describe-route-tables --filters "Name=tag:DZ,Values=hw3" "Name=tag:access_type,Values=private" --query 'RouteTables[*].RouteTableId' --output text)
```
## add subnets to touting tables
```sh
aws ec2 associate-route-table --route-table-id $ROUTE_TABLE_ID_PUBLIC  --subnet-id $SUBNET_ID_PUBLIC
aws ec2 associate-route-table --route-table-id $ROUTE_TABLE_ID_PRIVATE --subnet-id $SUBNET_ID_PRIVATE
```
## check associating 
```sh
aws ec2 describe-route-tables --filters "Name=tag:DZ,Values=hw3" --query "RouteTables[*].Associations" --output json | cat
```
## add default route to public table
```sh
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID_PUBLIC --gateway-id $INTERNET_GATEWAY_ID --destination-cidr-block 0.0.0.0/0
```
<!-- aws ec2 create-route --route-table-id $ROUTE_TABLE_ID_PUBLIC --gateway-id $INTERNET_GATEWAY_ID --destination-cidr-block 192.168.0.0/24
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID_PRIVATE --gateway-id $INTERNET_GATEWAY_ID --destination-cidr-block 192.168.0.0/24 -->

## checking routes in tables
```sh
aws ec2 describe-route-tables --route-table-id $ROUTE_TABLE_ID_PRIVATE | cat
aws ec2 describe-route-tables --route-table-id $ROUTE_TABLE_ID_PRIVATE | cat
```
## 2.
## Creating security-group
```sh
aws ec2 create-security-group --vpc-id $VPC_ID --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=sg-FRONT},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=part,Value=front}]' --group-name "FRONT" --description "create security sg-FRONT group for HW3"
aws ec2 create-security-group --vpc-id $VPC_ID --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=sg-BACK},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=part,Value=back}]' --group-name "BACK" --description "create security sg-BACK group for HW3"
```
## store SG-id
```sh
SG_ID_FRONT=$(aws ec2 describe-security-groups --filters "Name=tag:DZ,Values=hw3" "Name=tag:Name,Values=sg-FRONT" --query 'SecurityGroups[*].GroupId' --output text)
SG_ID_BACK=$(aws ec2 describe-security-groups --filters "Name=tag:DZ,Values=hw3" "Name=tag:Name,Values=sg-BACK" --query 'SecurityGroups[*].GroupId' --output text)
```
## add rules to SG
# allow port 22/tcp ingress to SG front
```sh
aws ec2 authorize-security-group-ingress --group-id $SG_ID_FRONT --protocol tcp --port 22 --cidr 0.0.0.0/0
```
# allow ingress trfaic from SG front to SG back
```sh
aws ec2 authorize-security-group-ingress --group-id $SG_ID_BACK --source-group $SG_ID_FRONT --protocol -1
```
## 3.
## run instalnces
```sh
aws ec2 run-instances --image-id "ami-0133c99f5f7850892" --count "1" --instance-type "t3.micro" --key-name "WEB" --security-group-ids $SG_ID_PUBLIC  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=WEB},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=part,Value=front}]'
```
## run VM WEB and DB with SG, PVE, subnets and public IP for VM WEB
```sh
aws ec2 run-instances \
    --image-id ami-0133c99f5f7850892 \
    --instance-type t3.micro \
    --key-name test \
    --security-group-ids $SG_ID_FRONT \
    --associate-public-ip-address \
    --subnet-id $SUBNET_ID_PUBLIC \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=WEB},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=part,Value=front}]'

aws ec2 run-instances \
    --image-id ami-0133c99f5f7850892 \
    --instance-type t3.micro \
    --key-name test \
    --security-group-ids $SG_ID_BACK \
    --subnet-id $SUBNET_ID_PRIVATE \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=DB},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=part,Value=database}]'    
```
## Generate ssh_config
```sh
FRONT_PUBLIC_IP=$(aws ec2 describe-instances --filters "Name=tag:DZ,Values=hw3" "Name=tag:Name,Values=WEB" --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
DB_PRIVATE_IP=$(aws ec2 describe-instances --filters "Name=tag:DZ,Values=hw3" "Name=tag:Name,Values=DB" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)

echo -e "
Host aws-front
    HostName $FRONT_PUBLIC_IP
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    SendEnv LANG LC_*
    user ubuntu
    IdentityFile ~/.ssh/test.pem

Host db-host
    HostName $DB_PRIVATE_IP
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    SendEnv LANG LC_*
    user ubuntu
    ProxyJump aws-front
    IdentityFile ~/.ssh/test.pem
"
```
## optionl part
