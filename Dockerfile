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

# Copy custom Nginx configuration for SPA
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Remove default Nginx configuration (if exists)
RUN rm -f /etc/nginx/conf.d/default.conf.bak

# Copy built application files
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
