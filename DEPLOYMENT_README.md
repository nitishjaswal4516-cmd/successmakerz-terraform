# Successmakerz - Docker Deployment Guide

This guide will help you deploy the Successmakerz visa consultancy application to AWS EC2 Ubuntu using Docker.

## 🏗️ Architecture

- **Frontend**: React + Vite + TypeScript + Tailwind CSS
- **Backend**: Node.js + Express + MongoDB
- **Database**: MongoDB
- **Reverse Proxy**: Nginx
- **Container Orchestration**: Docker Compose

## 📋 Prerequisites

- AWS EC2 Ubuntu instance (t2.micro or higher recommended)
- SSH access to your EC2 instance
- Domain name (optional, but recommended for production)

## 🚀 Quick Deployment

### Step 1: Prepare Your EC2 Instance

```bash
# SSH into your EC2 instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# Run the deployment setup script
curl -fsSL https://raw.githubusercontent.com/your-repo/deploy.sh | bash
```

Or manually:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER
```

**Important**: Log out and log back in for Docker group changes to take effect.

### Step 2: Upload Your Project

```bash
# On your local machine, create a zip of your project
zip -r successmakerz.zip .

# Upload to your server (using scp or your preferred method)
scp -i your-key.pem successmakerz.zip ubuntu@your-ec2-ip:~/

# On the server, extract the files
unzip successmakerz.zip
cd successmakerz-v2
```

### Step 3: Configure Environment Variables

```bash
# Copy environment template
cp backend/.env.production backend/.env

# Edit the .env file with your actual values
nano backend/.env
```

Update the following variables:
```env
MONGODB_URI=mongodb://mongodb:27017/successmakerz
PORT=5000
FRONTEND_URL=http://your-domain-or-ip
NODE_ENV=production
```

### Step 4: Deploy the Application

```bash
# Make deployment script executable
chmod +x deploy-production.sh

# Run deployment
./deploy-production.sh
```

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MONGODB_URI` | MongoDB connection string | `mongodb://mongodb:27017/successmakerz` |
| `PORT` | Backend server port | `5000` |
| `FRONTEND_URL` | Frontend URL for CORS | `http://localhost` |
| `NODE_ENV` | Node environment | `production` |

### MongoDB Setup

The application uses MongoDB running in a Docker container. For production, consider:

1. **MongoDB Atlas** (recommended for production):
   - Create account at https://cloud.mongodb.com
   - Create cluster and database
   - Update `MONGODB_URI` with your Atlas connection string

2. **Local MongoDB** (current setup):
   - Data persists in Docker volume `mongodb_data`
   - Accessible at `mongodb://localhost:27017`

## 🌐 Domain Setup (Optional)

### Using Nginx as Reverse Proxy

If you have a domain, you can set up Nginx to proxy requests:

```bash
# Install Nginx
sudo apt install -y nginx

# Create site configuration
sudo nano /etc/nginx/sites-available/successmakerz
```

Add this configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    location / {
        proxy_pass http://localhost;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/successmakerz /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

### SSL with Let's Encrypt (Recommended)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

## 📊 Monitoring & Maintenance

### View Logs

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mongodb
```

### Restart Services

```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart backend
```

### Update Deployment

```bash
# Pull latest changes and rebuild
git pull origin main
docker-compose up -d --build
```

### Backup Database

```bash
# Create backup
docker exec successmakerz-mongodb mongodump --db successmakerz --out /backup

# Copy backup to host
docker cp successmakerz-mongodb:/backup ./mongodb_backup

# Compress backup
tar -czf mongodb_backup_$(date +%Y%m%d_%H%M%S).tar.gz mongodb_backup
```

## 🔍 Troubleshooting

### Common Issues

1. **Port already in use**:
   ```bash
   sudo lsof -i :80
   sudo lsof -i :5000
   # Kill process or change ports in docker-compose.yml
   ```

2. **Permission denied**:
   ```bash
   sudo chown -R $USER:$USER /opt/successmakerz
   ```

3. **MongoDB connection failed**:
   - Check `MONGODB_URI` in `backend/.env`
   - Verify MongoDB container is running: `docker-compose ps`

4. **Frontend not loading**:
   - Check Nginx configuration
   - Verify frontend container is healthy: `docker-compose ps`

### Health Checks

```bash
# Check container health
docker-compose ps

# Check application health
curl http://localhost/api/health
curl http://localhost
```

## 📞 Support

If you encounter issues:

1. Check logs: `docker-compose logs -f`
2. Verify environment variables
3. Ensure all required ports are open in AWS security groups
4. Check AWS instance resources (CPU, memory)

## 🔒 Security Considerations

- Change default MongoDB credentials
- Use environment variables for sensitive data
- Keep Docker and system packages updated
- Configure firewall rules
- Use HTTPS in production
- Regularly backup your database

---

**Happy Deploying! 🚀**