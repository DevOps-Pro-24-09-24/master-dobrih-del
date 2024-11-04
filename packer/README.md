### create iam-role
```bash
aws iam create-role --role-name HW5-custom-role --assume-role-policy-document file://iam-role/trust-policy.json
for policy_arn in $(jq -r '.[]' ./iam-role/policies.json); 
do
    aws iam attach-role-policy --role-name HW5-custom-role --policy-arn $policy_arn
done
aws iam create-instance-profile --instance-profile-name HW5-InstanceProfile
aws iam add-role-to-instance-profile --instance-profile-name HW5-InstanceProfile --role-name HW5-custom-role
```
### run DB 
```bash
IMAGE_ID=$(aws ec2 describe-images --owners self --filters "Name=tag:part,Values=db" "Name=tag:DZ,Values=hw5" --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' --output text)
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type t3.micro \
    --key-name test \
    --iam-instance-profile Name=HW5-InstanceProfile \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=DB},{Key=env,Value=test},{Key=DZ,Value=hw5},{Key=part,Value=db}]' \
    --user-data file://scripts/userdata-db.sh
```
### run APP
```bash
IMAGE_ID=$(aws ec2 describe-images --owners self --filters "Name=tag:part,Values=app" "Name=tag:DZ,Values=hw5" --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' --output text)
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type t3.micro \
    --key-name test \
    --iam-instance-profile Name=HW5-InstanceProfile \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=APP},{Key=env,Value=test},{Key=DZ,Value=hw5},{Key=part,Value=app}]'
```