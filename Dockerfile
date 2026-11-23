FROM nginx:1.31.10-alpine@sha256:eb37f58646a901dc7727cf448cae36daaefaba79de33b5058dab79aa4c04aefb

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
