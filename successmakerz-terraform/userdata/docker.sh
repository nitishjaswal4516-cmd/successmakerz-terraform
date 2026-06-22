#!/bin/bash

apt update -y
apt upgrade -y

apt install -y \
git \
curl \
wget \
unzip \
nginx \
certbot \
python3-certbot-nginx

curl -fsSL https://get.docker.com | sh

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

mkdir -p /opt/apps

cd /opt/apps

git clone https://github.com/nitishjaswal4516-cmd/successmakerz-frontend.git frontend

git clone https://github.com/nitishjaswal4516-cmd/successmakerz-backend.git backend

# Frontend Deploy
cd /opt/apps/frontend
docker compose up -d --build

# Backend Deploy
cd /opt/apps/backend
docker compose up -d --build

# NGINX CONFIG

cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80;
    server_name tour.nitish-devops.me;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name go.nitish-devops.me;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

nginx -t
systemctl enable nginx
systemctl restart nginx

# CERTBOT SSL

certbot --nginx \
-d tour.nitish-devops.me \
-d go.nitish-devops.me \
--non-interactive \
--agree-tos \
-m jaswalkaku980@gmail.com

# VERIFY SERVICES

systemctl status nginx --no-pager
docker ps // change