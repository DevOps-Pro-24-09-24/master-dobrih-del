FROM python:3.12
WORKDIR /app
RUN apt update && \
    apt install -y \
    python3 \
    python3-venv \
    python3-pip \
    default-libmysqlclient-dev \
    pkg-config &&\
    apt-get clean

COPY flask-alb-app/requirements.txt ./requirements.txt
RUN pip install -r requirements.txt
COPY flask-alb-app/ ./
EXPOSE 8000
CMD ["python3", "app.py"]