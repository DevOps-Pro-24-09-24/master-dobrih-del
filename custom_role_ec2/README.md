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
for policy_arn in $(jq -r '.[]' attached_policies.json); do
    aws iam attach-role-policy --role-name HW4_CustomRole --policy-arn $policy_arn
done
```
### Create EC2 instance for testin
```sh
aws ec2 run-instances \
    --iam-instance-profile Name=HW4_CustomInstanceProfile \
    --image-id ami-05edb7c94b324f73c \
    --instance-type t3.micro \
    --key-name test \
    --associate-public-ip-address \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=APP},{Key=env,Value=test},{Key=DZ,Value=hw4},{Key=part,Value=APP}]'
```

## cheking
### get instanceID
```sh
InstanceId=$(aws ec2 describe-instances --filters "Name=tag:DZ,Values=hw4" "Name=tag:Name,Values=tect_vm" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].InstanceId' --output text)
```
```sh
aws ec2 describe-instances --instance-ids $InstanceId --query "Reservations[*].Instances[*].IamInstanceProfile"
```
<image src="screenshots/aws_cli-show-profile.png" alt="aws_cli-show-profile.png">

### SSM session with 'aws s3 ls' and 'aws ssm get-parameters'
<image src="screenshots/session-manager-s3-ssm_get.png" alt="session-manager-s3-ssm_get.png">

### Role screenshot from AWS web console
<image src="screenshots/aws-web-role.png" alt="aws-web-role.png">
