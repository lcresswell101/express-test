# Use the official Node.js runtime as the base image
FROM public.ecr.aws/docker/library/node:18-alpine

# Install nginx and supervisor
RUN apk add --no-cache nginx supervisor

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if available)
# This is done before copying the rest of the code to leverage Docker's cache layering
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev

# Copy the rest of the application code
COPY . .

# Create nginx configuration
RUN mkdir -p /etc/nginx/conf.d
COPY nginx.conf /etc/nginx/nginx.conf

# Create directories for nginx with proper permissions
RUN mkdir -p /var/log/nginx /run/nginx /var/cache/nginx /var/lib/nginx/logs && \
    chown -R node:node /usr/src/app /var/log/nginx /run/nginx /etc/nginx /var/cache/nginx /var/lib/nginx

# Create supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create directories for nginx and supervisor
RUN mkdir -p /var/log/nginx /var/log/supervisor /run/nginx

# Change ownership of necessary directories
RUN chown -R node:node /usr/src/app /var/log/nginx /var/log/supervisor /run/nginx /etc/nginx

# Create a startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

USER node

# Expose the port that nginx will serve on
EXPOSE 8080

# Use the startup script
CMD ["/start.sh"]