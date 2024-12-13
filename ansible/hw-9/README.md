### Set IMAGE_ID to latest debian image
```bash
IMAGE_ID=$(aws ec2 describe-images --owners 136693071363 --filters "Name=name,Values=debian-12-amd64-*" "Name=architecture,Values=x86_64" --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' --output text)
```
### run instances for DB and APP 
```bash
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type t3.micro \
    --key-name test \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=DB},{Key=env,Value=test},{Key=DZ,Value=hw9},{Key=part,Value=db}]' 
aws ec2 run-instances \
    --image-id $IMAGE_ID \
    --instance-type t3.micro \
    --key-name test \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=APP},{Key=env,Value=test},{Key=DZ,Value=hw9},{Key=part,Value=app}]'
```
### Get ip addresses
```bash
APP_IP=$(aws ec2 describe-instances --filters "Name=tag:DZ,Values=hw9" "Name=tag:Name,Values=APP" --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
DB_IP=$(aws ec2 describe-instances --filters "Name=tag:DZ,Values=hw9" "Name=tag:Name,Values=DB" --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
```
### Add hosts to ssh config 
```bash
echo -e "
Host app-host
    HostName $APP_IP
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    SendEnv LANG LC_*
    user ubuntu
    IdentityFile ~/.ssh/test.pem

Host db-host
    HostName $DB_IP
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    SendEnv LANG LC_*
    user ubuntu
    ProxyJump aws-front
    IdentityFile ~/.ssh/test.pem
" >> ~/.ssh/config
```

## 
### run playbook
```bash
ansible-playbook flask-alb-pb.yaml
```
### Proofs
### Debian (у скиншотилки сломался режим прокрути, разбил на 3 скрина) :
### ansible-playbook flask-alb-pb.yaml
<image src="screenshots/01.run-pb-deb.png" alt="01.run-pb-deb.png">
<image src="screenshots/02.run-pb-deb.png" alt="02.run-pb-deb.png">
<image src="screenshots/03.run-pb-deb.png" alt="03.run-pb-deb.png">

### Web
<image src="screenshots/04.web-deb.png" alt="04.web-deb.png">
<image src="screenshots/05.web-deb.png" alt="05.web-deb.png">

## RHEL
### тут амазон решил что нужно с меня списать 60 баксов, делать я этого коннечно же не буду:)
### дальше продолжил в parallel 
### ansible-playbook flask-alb-pb.yaml
<image src="screenshots/06.run-pb-fedora1.png" alt="06.run-pb-fedora1.png">
<image src="screenshots/07.run-pb-fedora2.png" alt="07.run-pb-fedora2.png">

### Web
<image src="screenshots/08-web-fedora1.png" alt="08-web-fedora1.png">
<image src="screenshots/09-web-fedora2.png.png" alt="09-web-fedora2.png.png">
