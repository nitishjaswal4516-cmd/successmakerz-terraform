#!/bin/bash
set -e
exec > /var/log/userdata.log 2>&1

apt update -y
apt upgrade -y
apt install -y git curl wget unzip nginx certbot python3-certbot-nginx

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Install Docker
curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

mkdir -p /opt/apps
cd /opt/apps

git clone ${frontend_repo} frontend
git clone ${backend_repo} backend

# ── Frontend Build ──────────────────────────────────────
cd /opt/apps/frontend
echo "VITE_API_URL=https://go.nitish-devops.me" > .env
chown -R ubuntu:ubuntu /opt/apps/frontend
npm install
chmod +x node_modules/.bin/tsc
chmod +x node_modules/.bin/vite
npm run build

# ── Backend Deploy ──────────────────────────────────────
cd /opt/apps/backend
docker compose up -d --build

# ── NGINX CONFIG ────────────────────────────────────────
cat > /etc/nginx/sites-available/default << 'NGINXEOF'
server {
    listen 80;
    server_name tour.nitish-devops.me;

    root /opt/apps/frontend/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
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
NGINXEOF

nginx -t
systemctl enable nginx
systemctl restart nginx

# ── CERTBOT SSL ─────────────────────────────────────────
certbot --nginx \
  -d tour.nitish-devops.me \
  -d go.nitish-devops.me \
  --non-interactive \
  --agree-tos \
  -m jaswalkaku980@gmail.com

# ── VERIFY ──────────────────────────────────────────────
systemctl status nginx --no-pager
docker ps