# ===============Stage 1: Build the React app===============

FROM node:18-alpine AS build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Build the app
RUN npm run build

#=============================================================

#===================Stage 2: Serve with Nginx=================
FROM nginx:alpine

# Copy built files from stage 1
COPY --from=build /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Opens port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

#=============================================================