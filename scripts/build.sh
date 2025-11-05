#!/bin/bash

# Build script for Hello World DevOps project
# This script builds the Docker image locally

set -e  # Exit on any error

echo "🔨 Starting build process..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="hello-world-devops"
IMAGE_TAG="latest"
DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-your-username}"

echo -e "${BLUE}📦 Building Docker image...${NC}"

# Build Docker image from project root
docker build -f docker/Dockerfile -t ${IMAGE_NAME}:${IMAGE_TAG} .

echo -e "${GREEN}✅ Docker image built successfully!${NC}"
echo -e "Image: ${IMAGE_NAME}:${IMAGE_TAG}"

# Optional: Test the image locally
echo -e "\n${BLUE}🧪 To test locally, run:${NC}"
echo "docker run -p 3000:3000 ${IMAGE_NAME}:${IMAGE_TAG}"
echo "Then visit: http://localhost:3000"

# Optional: Push to Docker Hub
read -p "Do you want to tag and push to Docker Hub? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo -e "${BLUE}🚀 Tagging image for Docker Hub...${NC}"
    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
    
    echo -e "${BLUE}📤 Pushing to Docker Hub...${NC}"
    docker push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
    
    echo -e "${GREEN}✅ Image pushed to Docker Hub!${NC}"
    echo "Image: ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"
fi

echo -e "\n${GREEN}🎉 Build process completed!${NC}"