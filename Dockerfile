# Stage 1: Build the Vue.js application
FROM node:lts-alpine as build-stage

WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker cache
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the application for production
RUN npm run build

# Stage 2: Serve the application with Nginx
FROM nginx:stable-alpine as production-stage

# Copy custom Nginx configuration (optional, but good practice for SPAs)
# If you have a custom nginx.conf for your SPA (e.g., for history mode routing),
# uncomment the line below and place your nginx.conf in the same directory as the Dockerfile.
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Remove default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Create a simple Nginx configuration for serving static files
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
