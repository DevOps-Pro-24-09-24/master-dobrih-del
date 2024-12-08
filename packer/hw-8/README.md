### Copy from hw-5 but with changes: provisioners -> ansible 

### run DB. change tags DZ to hw8
```bash
IMAGE_ID=$(aws ec2 describe-images --owners self --filters "Name=tag:part,Values=db" "Name=tag:DZ,Values=hw8" --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' --output text)
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type t3.micro \
    --key-name test \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=DB},{Key=env,Value=test},{Key=DZ,Value=hw8},{Key=part,Value=db}]' 
```
### run APP, same, change tags DZ to hw8
```bash
IMAGE_ID=$(aws ec2 describe-images --owners self --filters "Name=tag:part,Values=app" "Name=tag:DZ,Values=hw8" --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' --output text)
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type t3.micro \
    --key-name test \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=APP},{Key=env,Value=test},{Key=DZ,Value=hw8},{Key=part,Value=app}]'


## 
### paker build db

<image src="screenshots/packer-db-done.png" alt="packer-db-done.png">

### paker build app 

<image src="screenshots/packer-app-done.png" alt="packer-app-done.png">

### Proofs
### ansible-palybook deploy.yml

<image src="screenshots/deploy-playbook.png" alt="deploy-playbook.png">

### web

<image src="screenshots/check_web.png" alt="check_web.png">

