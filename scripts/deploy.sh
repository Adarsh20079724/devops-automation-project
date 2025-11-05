#!/bin/bash

# Deployment script for Hello World DevOps project
# This script deploys the application to AWS EC2 using git pull

set -e  # Exit on any error

echo "🚀 Starting deployment process..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="devops-automation-project"
EC2_IP="${EC2_IP:-}"
SSH_KEY="${SSH_KEY:-your-key.pem}"
REPO_URL="${REPO_URL:-https://github.com/YOUR_USERNAME/hello-world-devops.git}"
BRANCH="${BRANCH:-main}"

# Check if EC2_IP is provided
if [ -z "$EC2_IP" ]; then
    echo -e "${RED}❌ Error: EC2_IP environment variable not set${NC}"
    echo "Usage: EC2_IP=1.2.3.4 SSH_KEY=your-key.pem ./scripts/deploy.sh"
    exit 1
fi

echo -e "${BLUE}📋 Deployment Configuration:${NC}"
echo "  EC2 IP: ${EC2_IP}"
echo "  SSH Key: ${SSH_KEY}"
echo "  Repository: ${REPO_URL}"
echo "  Branch: ${BRANCH}"

# Test SSH connection
echo -e "\n${BLUE}🔐 Testing SSH connection...${NC}"
ssh -i ${SSH_KEY} -o ConnectTimeout=10 -o StrictHostKeyChecking=no ec2-user@${EC2_IP} "echo 'SSH connection successful'" || {
    echo -e "${RED}❌ SSH connection failed${NC}"
    exit 1
}

echo -e "${GREEN}✅ SSH connection successful${NC}"

# Deploy to EC2
echo -e "\n${BLUE}📦 Deploying to EC2 using git pull approach...${NC}"

ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ec2-user@${EC2_IP} << EOF
    set -e
    
    echo "📂 Setting up application directory..."
    cd /home/ec2-user
    
    # Clone or pull repository
    if [ -d "app" ]; then
        echo "🔄 Updating existing repository..."
        cd app
        git fetch origin
        git reset --hard origin/${BRANCH}
        git pull origin ${BRANCH}
    else
        echo "📥 Cloning repository..."
        git clone ${REPO_URL} app
        cd app
        git checkout ${BRANCH}
    fi
    
    echo "🔄 Stopping existing containers..."
    docker stop ${APP_NAME} 2>/dev/null || true
    docker rm ${APP_NAME} 2>/dev/null || true
    
    echo "🐳 Building Docker image..."
    docker build -f docker/Dockerfile -t hello-world-devops:latest .
    
    echo "🚀 Starting new container..."
    docker run -d \
        --name ${APP_NAME} \
        --restart unless-stopped \
        -p 3000:3000 \
        -e NODE_ENV=production \
        hello-world-devops:latest
    
    echo "⏳ Waiting for application to start..."
    sleep 10
    
    echo "🏥 Checking application health..."
    curl -f http://localhost:3000/api/health || {
        echo "❌ Health check failed"
        docker logs ${APP_NAME}
        exit 1
    }
    
    echo "🧹 Cleaning up old Docker images..."
    docker image prune -f
    
    echo "✅ Application deployed successfully!"
EOF

echo -e "\n${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "\n${BLUE}📱 Application is now running at:${NC}"
echo "   http://${EC2_IP}:3000"
echo -e "\n${YELLOW}💡 Useful commands:${NC}"
echo "   View logs: ssh -i ${SSH_KEY} ec2-user@${EC2_IP} 'docker logs -f ${APP_NAME}'"
echo "   Restart app: ssh -i ${SSH_KEY} ec2-user@${EC2_IP} 'docker restart ${APP_NAME}'"
echo "   Stop app: ssh -i ${SSH_KEY} ec2-user@${EC2_IP} 'docker stop ${APP_NAME}'"
echo "   SSH to EC2: ssh -i ${SSH_KEY} ec2-user@${EC2_IP}"