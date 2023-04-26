# Use the official Node.js runtime as a parent image
FROM node:16 as build

# Set the working directory to /app
WORKDIR /app

# Copy the package.json and package-lock.json files to the container
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code to the container
COPY . .

ARG ENV=.env

COPY ./$ENV ./.env

# Build the SvelteKit application
RUN npm run build

# Use the official Nginx runtime as a parent image
FROM nginx:1.21.3-alpine

# Copy the nginx.conf file to the container
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the built SvelteKit application to the Nginx default document root directory
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80 for Nginx to listen on
EXPOSE 80

# Start Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]