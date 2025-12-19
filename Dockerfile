FROM nginx:1.29.3-alpine@sha256:b3c656d55d7ad751196f21b7fd2e8d4da9cb430e32f646adcf92441b72f82b14

# Set Working Directory to Nginx HTML directory
WORKDIR /usr/share/nginx/html
# Remove default content
RUN rm -rf ./*

# Copy the static site content into the container
COPY ./site .

# Expose port 80
EXPOSE 80

# Set entrypoint to run Nginx
ENTRYPOINT ["nginx", "-g", "daemon off;"]
