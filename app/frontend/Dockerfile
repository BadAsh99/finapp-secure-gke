FROM nginx:alpine

# Use the pre-existing non-root user in this image
USER root

# Copy site and vhost
COPY html/ /usr/share/nginx/html/
COPY html/default.conf /etc/nginx/conf.d/default.conf

# Drop to non-root for PodSecurity "restricted"
USER nginx

# Nginx in this image runs as non-root fine when listening on high port
EXPOSE 8080
