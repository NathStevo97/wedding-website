FROM nginx:1.31.6-alpine@sha256:df221db836e1754089190208cee7eeda94f233197056426eda74a43ab1abeac2

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
