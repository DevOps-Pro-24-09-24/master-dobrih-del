# HW 10: Docker-1
## Dockerfile sets up a Python 3.12 environment, installs necessary dependencies, and runs the Flask application.
## compose file build the Dockerfile and runs the Flask application with mariadb as the database, with dependencies with database; used the .env file for environment variables.

## Run application in background and check logs
```bash
docker compose up -d
docker compose logs
```
## screen shot of result:
<image src="screenshots/docker_compose_run.png" alt="docker_compose_run.png">

## browser screenshot:
<image src="screenshots/web.png" alt="web.png">
<image src="screenshots/web-log.png" alt="web-log.png">

