# Stage 1: Build the Angular application
FROM node:alpine AS build

# Declare the arguments
ARG API_URL
ARG APP_VERSION

# Set them as ENV so the application can use them during the build (e.g., Angular build)
ENV API_URL=$API_URL
ENV APP_VERSION=$APP_VERSION

WORKDIR /app

# Copy package files and install dependencies
COPY package.json package-lock.json ./
RUN npm ci

# Copy the rest of the application code
COPY . .

# Build the application for production
RUN npm run build

# Stage 2: Serve the application with Nginx
FROM docker.io/library/nginx:alpine

# Copy the build output to Nginx's html directory
# Note: The output path usually includes '/browser' with the new application builder.
# If your build differs, check the dist/ folder structure.
COPY --from=build /app/dist/phoenix-v1-angular/browser /usr/share/nginx/html

# Copy custom Nginx configuration
# Note: the file in the repo is named with a double .conf suffix
COPY nginx.custom.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
