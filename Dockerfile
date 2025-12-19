FROM nginx:1.29.4-alpine@sha256:fd9f8ce722ab13edb2e47ebdd16b843939280457bf1567a6cd155203f9ce98d8

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
