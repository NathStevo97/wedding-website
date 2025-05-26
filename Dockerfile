FROM nginx:1.28.0-alpine@sha256:37075895d8461222f53afa7804aec2c57d69f9842995705cc54a0c4a70d68fc9

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