#!/bin/bash

# Production Deployment Script
# Run this script in your project directory on the server

set -e

echo "🚀 Deploying Successmakerz to Production..."

# Check if .env file exists
if [ ! -f "backend/.env" ]; then
    echo "❌ backend/.env file not found!"
    echo "📝 Please create backend/.env with your MongoDB connection string"
    echo "💡 You can copy from backend/.env.production and update the values"
    exit 1
fi

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose down || true

# Remove old images (optional, for clean deployment)
echo "🧹 Cleaning up old images..."
docker image prune -f || true

# Build and start services
echo "🏗️ Building and starting services..."
docker-compose up -d --build

# Wait for services to be healthy
echo "⏳ Waiting for services to start..."
sleep 30

# Check service status
echo "📊 Checking service status..."
docker-compose ps

# Show logs
echo "📋 Showing recent logs..."
docker-compose logs --tail=50

echo "✅ Deployment complete!"
echo "🌐 Your application should be available at:"
echo "   Frontend: http://your-server-ip"
echo "   Backend API: http://your-server-ip:5000"
echo "   API Health: http://your-server-ip/api/health"

echo ""
echo "🔧 Useful commands:"
echo "   View logs: docker-compose logs -f"
echo "   Restart services: docker-compose restart"
echo "   Stop services: docker-compose down"
echo "   Update deployment: docker-compose up -d --build"