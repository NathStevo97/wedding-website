FROM nginx:1.31.1-alpine@sha256:8b1e78743a03dbb2c95171cc58639fef29abc8816598e27fb910ed2e621e589a

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
