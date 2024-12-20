# HW 11: Docker-2
### build docker image and upload to docker hub, 
### need be loginned to docker hub https://docs.docker.com/reference/cli/docker/login/
```bash
docker compose build api
docker tag hw-11-api:latest comeknocking/hw-11:latest
docker push comeknocking/hw-11:latest
```
<image src="screenshots/docker-build.png" alt="docker-build.png">
<image src="screenshots/docker-push.png" alt="docker-push.png">

### clean up local images, flag -a removes all images, -f forces removal - with out question
```bash
docker compose down --volumes --remove-orphans
docker system prune -af
```
<image src="screenshots/docker-image-ls.png" alt="docker-image-ls.png">

### create self-signed certificate
```bash
openssl genpkey -algorithm RSA -out self-sing.key
openssl req -new -key self-sing.key -out self-sing.csr
openssl x509 -req -days 3650 -in self-sing.csr -signkey self-sing.key -out self-sing.crt
```
<image src="screenshots/openssl-gen-certs.png" alt="openssl.png">
<image src="screenshots/openssl-sing-certs.png" alt="openssl.png">

### Start docker and found ip address of proxy container
```bash
docker compose up -d
docker inspect flask-alb-proxy | jq -r '.[0].NetworkSettings.Networks'
```
<image src="screenshots/docker-inspect-proxy.png" alt="docker-inspect-proxy.png">

### screen shot of result from browser:
<image src="screenshots/web01.png" alt="web01.png">
<image src="screenshots/web02.png" alt="web02.png">