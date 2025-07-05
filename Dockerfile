# Use the official Node.js runtime as the base image
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if available)
# This is done before copying the rest of the code to leverage Docker's cache layering
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev

USER node

# Copy the rest of the application code
COPY . .

# Expose the port that your Express app runs on
EXPOSE 3000

# Define the command to run your application
CMD ["npm", "start"]