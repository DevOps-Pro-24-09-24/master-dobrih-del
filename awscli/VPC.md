<!-- ## resources witch support tagging:
# instance (EC2 instances)
# volume (EBS volumes)
# internet-gateway (Internet Gateways)
# subnet (Subnets)
# vpc (VPCs)
# security-group (Security Groups)
# network-interface (Network Interfaces)
# route-table (Route Tables)
# natgateway (NAT Gateways) -->
## 0. Preparations
### Vars-list
```txt
$DB_PRIVATE_IP
$FRONT_PUBLIC_IP
$IMAGE_ID
$INTERNET_GATEWAY_ID
$ROUTE_TABLE_ID_PRIVATE
$ROUTE_TABLE_ID_PUBLIC
$SG_ID_BACK
$SG_ID_FRONT
$SUBNET_ID_PRIVATE
$SUBNET_ID_PUBLIC
$VPC_ID
```
### Vars-list from optional task
```txt
$AIM_ID_FOR_DB
$DB_IP
$IMAGE_ID
```
### Setup AWS cli; AWS Access Key ID and AWS Secret Access Key in AWS IAM https://us-east-1.console.aws.amazon.com/iam/home?region=eu-north-1#/users/details/master?section=permissions
```sh
aws configure
```
<details>
  <summary>screenshots</summary>
<image src="screenshots/aws-config.png" alt="Example aws config">
<image src="./screenshots/aws-iam-list-keys.png" alt="Example aws key list">
</details>

## 1. Створити VPC з двома підмережами
### setup CIRD vars
```sh
CIRD_PVC='192.168.0.0/24'
CIRD_SUBNET_PUBLIC='192.168.0.0/25'
CIRD_SUBNET_PRIVATE='192.168.0.128/25'
```
### create VPC
```sh
aws ec2 create-vpc \
    --cidr-block $CIRD_PVC  \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=test-VPC},{Key=env,Value=test},{Key=DZ,Value=hw3}]'
```
### store VPC_ID in variable 
```sh
VPC_ID=($(aws ec2 describe-vpcs \
    --filters "Name=tag:DZ,Values=hw3" \
    --query "Vpcs[*].VpcId" \
    --output text))
```
### Create two subnets (private and public) and store id's in vars
```sh
aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $CIRD_SUBNET_PUBLIC     --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=test-VPC},{Key=env,Value=test},{Key=DZ,Value=hw3}, {Key=access_type, Value=public}]'
aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $CIRD_SUBNET_PRIVATE     --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=test-subnet},{Key=env,Value=test},{Key=DZ,Value=hw3}, {Key=access_type, Value=private }]'

SUBNET_ID_PUBLIC=$(aws ec2 describe-subnets --filters "Name=tag:DZ,Values=hw3" "Name=tag:access_type,Values=public" --query 'Subnets[*].SubnetId' --output text)
SUBNET_ID_PRIVATE=$(aws ec2 describe-subnets --filters "Name=tag:DZ,Values=hw3" "Name=tag:access_type,Values=private" --query 'Subnets[*].SubnetId' --output text)
```
### Create internet gateway for public routing and store id to var INTERNET_GATEWAY_ID
```sh
aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=test-gateway},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=access_type,Value=public}]'
INTERNET_GATEWAY_ID=$(aws ec2 describe-internet-gateways --filters "Name=tag:DZ,Values=hw3" "Name=tag:access_type,Values=public" --query 'InternetGateways[*].InternetGatewayId' --output text)
```
### Ataach internet gateway to public VPC
```sh
aws ec2 attach-internet-gateway --internet-gateway-id $INTERNET_GATEWAY_ID --vpc-id $VPC_ID
```
<!-- ## check attaching 
➜  master-dobrih-del git:(hw-3) ✗ INTERNET_GATEWAY_ATTACH=$(
    
aws ec2 describe-internet-gateways --filters "Name=tag:DZ,Values=hw3" "Name=tag:access_type,Values=public" --query 'InternetGateways[*].Attachments' --output text -->

### Create routing tables
```sh
aws ec2 create-route-table --vpc-id $VPC_ID  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=test-routetable-public},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=access_type,Value=public}]'

aws ec2 create-route-table --vpc-id $VPC_ID  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=test-routetable-private},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=access_type,Value=private}]'
```
### Store route tables id's to vars
```sh
ROUTE_TABLE_ID_PUBLIC=$(aws ec2 describe-route-tables --filters "Name=tag:DZ,Values=hw3" "Name=tag:access_type,Values=public" --query 'RouteTables[*].RouteTableId' --output text)

ROUTE_TABLE_ID_PRIVATE=$(aws ec2 describe-route-tables --filters "Name=tag:DZ,Values=hw3" "Name=tag:access_type,Values=private" --query 'RouteTables[*].RouteTableId' --output text)
```
### add subnets to touting tables
```sh
aws ec2 associate-route-table --route-table-id $ROUTE_TABLE_ID_PUBLIC  --subnet-id $SUBNET_ID_PUBLIC
aws ec2 associate-route-table --route-table-id $ROUTE_TABLE_ID_PRIVATE --subnet-id $SUBNET_ID_PRIVATE
```
### check associating 
```sh
aws ec2 describe-route-tables --filters "Name=tag:DZ,Values=hw3" --query "RouteTables[*].Associations" --output json | cat
```
### add default route to public table
```sh
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID_PUBLIC --gateway-id $INTERNET_GATEWAY_ID --destination-cidr-block 0.0.0.0/0
```
<!-- aws ec2 create-route --route-table-id $ROUTE_TABLE_ID_PUBLIC --gateway-id $INTERNET_GATEWAY_ID --destination-cidr-block 192.168.0.0/24
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID_PRIVATE --gateway-id $INTERNET_GATEWAY_ID --destination-cidr-block 192.168.0.0/24 -->

### checking routes in tables
```sh
aws ec2 describe-route-tables --route-table-id $ROUTE_TABLE_ID_PRIVATE | cat
aws ec2 describe-route-tables --route-table-id $ROUTE_TABLE_ID_PRIVATE | cat
```
## 2. Налаштувати Security Groups (SG)
### Creating security-group
```sh
aws ec2 create-security-group --vpc-id $VPC_ID --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=sg-FRONT},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=part,Value=front}]' --group-name "FRONT" --description "create security sg-FRONT group for HW3"
aws ec2 create-security-group --vpc-id $VPC_ID --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=sg-BACK},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=part,Value=back}]' --group-name "BACK" --description "create security sg-BACK group for HW3"
```
### store SG-id
```sh
SG_ID_FRONT=$(aws ec2 describe-security-groups --filters "Name=tag:DZ,Values=hw3" "Name=tag:Name,Values=sg-FRONT" --query 'SecurityGroups[*].GroupId' --output text)
SG_ID_BACK=$(aws ec2 describe-security-groups --filters "Name=tag:DZ,Values=hw3" "Name=tag:Name,Values=sg-BACK" --query 'SecurityGroups[*].GroupId' --output text)
```
### add rules to SG
### allow port 22/tcp ingress to SG front
```sh
aws ec2 authorize-security-group-ingress --group-id $SG_ID_FRONT --protocol tcp --port 22 --cidr 0.0.0.0/0
```
### allow ingress trfaic from SG front to SG back
```sh
aws ec2 authorize-security-group-ingress --group-id $SG_ID_BACK --source-group $SG_ID_FRONT --protocol -1
```
## 3. Створити два EC2 інстанси
### run instalnces 
```sh
aws ec2 run-instances --image-id "ami-0133c99f5f7850892" --count "1" --instance-type "t3.micro" --key-name "WEB" --security-group-ids $SG_ID_FRONT  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=WEB},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=part,Value=front}]'
```
### run VM WEB and DB with SG, PVE, subnets and public IP for VM WEB
```sh
IMAGE_ID=$(aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-*-*-amd64-server-*" "Name=architecture,Values=x86_64" --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' --output text)
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type t3.micro \
    --key-name test \
    --security-group-ids $SG_ID_FRONT \
    --associate-public-ip-address \
    --subnet-id $SUBNET_ID_PUBLIC \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=WEB},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=part,Value=front}]'

aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type t3.micro \
    --key-name test \
    --security-group-ids $SG_ID_BACK \
    --subnet-id $SUBNET_ID_PRIVATE \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=DB},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=part,Value=database}]'    
```
### Generate ssh_config
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
# optional part
## Створити AMI образ для інстансу з БД:
### Get latest imageid for ubuntu
```sh
IMAGE_ID=$(aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-*-*-amd64-server-*" "Name=architecture,Values=x86_64" --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' --output text)
```
### running instastance with script in user-data.
### install and config mariaDB
```s
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type t3.micro \
    --key-name test \
    --security-group-ids $SG_ID_FRONT \
    --associate-public-ip-address \
    --subnet-id $SUBNET_ID_PUBLIC \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=DB-FOR-AMI},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=part,Value=tmp}]' --user-data file://optional-stage/mariadb.sh
```
### get instalce ID and make IAM image from this instance
```s
VM_FOR_IMAGE=$(aws ec2 describe-instances --filters "Name=tag:DZ,Values=hw3" "Name=tag:Name,Values=DB-FOR-AMI" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].InstanceId' --output text)
aws ec2 create-image --instance-id $VM_FOR_IMAGE --name "HW3-AMI-MARIADB-10-3" --description "ubuntu image with MariaDB-10.3 installed" --no-reboot --tag-specifications 'ResourceType=image,Tags=[{Key=Name,Value=DB-FOR-AMI},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=part,Value=image}]'
```
### run instance with DB
```sh
AIM_ID_FOR_DB=$(aws ec2 describe-images --owners self --filters "Name=tag:DZ,Values=hw3" "Name=tag:Name,Values=DB-FOR-AMI" --query 'Images[*].ImageId' --output text)
aws ec2 run-instances \
    --image-id $AIM_ID_FOR_DB \
    --instance-type t3.micro \
    --key-name test \
    --security-group-ids $SG_ID_BACK \
    --subnet-id $SUBNET_ID_PRIVATE \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=DB},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=part,Value=back}]'
```
### get DB IP address and change it in userdata-script
```sh
DB_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=DB" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].PrivateIpAddress" --output text | cat)
sed -i "s/^Environment=MYSQL_HOST=.*/Environment=MYSQL_HOST=\"$DB_IP\"/" optional-stage/app.sh
```
### run instance with APP 
```sh
IMAGE_ID=$(aws ec2 describe-images --owners 136693071363 --filters "Name=name,Values=debian-12-amd64-*" "Name=architecture,Values=x86_64" --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' --output text)
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type t3.micro \
    --key-name test \
    --security-group-ids $SG_ID_FRONT \
    --associate-public-ip-address \
    --subnet-id $SUBNET_ID_PUBLIC \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=APP},{Key=env,Value=test},{Key=DZ,Value=hw3},{Key=part,Value=APP}]' --user-data file://optional-stage/app.sh
```
### open APP port (8080/tcp) for all IP addresses
```sh
SG_ID_FRONT=$(aws ec2 describe-security-groups --filters "Name=tag:DZ,Values=hw3" "Name=tag:Name,Values=sg-FRONT" --query 'SecurityGroups[*].GroupId' --output text)
aws ec2 authorize-security-group-ingress --group-id $SG_ID_FRONT --protocol tcp --port 8080 --cidr 0.0.0.0/0
```
## Results
### curl -I
<details>
  <summary>screenshots</summary>
<image src="screenshots/curl_result.png" alt="curl -I">
</details>

### check rows in mysql
<details>
  <summary>screenshots</summary>
<image src="screenshots/mysql_select_result.png" alt="rows in mysql">
</details>
