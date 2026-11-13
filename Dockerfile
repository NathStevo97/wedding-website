FROM nginx:1.31.8-alpine@sha256:fed7e14be83cbd2661a75cdc5b872d936cf155d46c327084d30b8df19ae88d72

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
