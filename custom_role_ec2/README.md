### Create the role using AWS CLI
```sh
aws iam create-role --role-name HW4_CustomRole --assume-role-policy-document file://role.json
```
### Attach the policy to the role
```sh
aws iam put-role-policy --role-name HW4_CustomRole --policy-name HW4_CustomRolePolicy --policy-document file://policy.json
```
### Create IAM Instance Profile
```sh
aws iam create-instance-profile --instance-profile-name HW4_CustomInstanceProfile
```
### Add the role to the Instance Profile
```sh
aws iam add-role-to-instance-profile --instance-profile-name HW4_CustomInstanceProfile --role-name HW4_CustomRole
```
### Create EC2 instance for testin
```sh
IMAGE_ID=$(aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-*-*-amd64-server-*" "Name=architecture,Values=x86_64" --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' --output text)
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type t3.micro \
    --key-name test \
    --associate-public-ip-address \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=tect_vm},{Key=env,Value=test},
    {Key=DZ,Value=hw4},{Key=part,Value=test}]'
```
### get instanceID
```sh
InstanceId=$(aws ec2 describe-instances --filters "Name=tag:DZ,Values=hw4" "Name=tag:Name,Values=tect_vm" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].InstanceId' --output text)
```
### Attach the role to your EC2 instance
```sh
aws ec2 associate-iam-instance-profile --instance-id $InstanceId --iam-instance-profile Name=HW4_CustomInstanceProfile
```

### cheking
```sh
aws ec2 describe-instances --instance-ids $InstanceId --query "Reservations[*].Instances[*].IamInstanceProfile"
```
