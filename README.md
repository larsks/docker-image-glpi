# GLPI Docker image

```
# Create a pod
podman create -p 8080:80 --name glpipod

# Start MariaDB
podman run -d --pod glpipod --name mysql \
  -e MYSQL_ROOT_PASSWORD=secret \
  -e MYSQL_DATABASE=glpi \
  -e MYSQL_USER=glpi \
  -e MYSQL_PASSWORD=secret \
  mariadb

# Start GLPI
podman run -d --pod glpipod --name glpi \
  -v glpi:/var/www/html \
  -e DB_PASS=secret \
  larsks/glpi

# Start Nginx
podman run -d --pod glpipod --name nginx \
  -v glpi:/var/www/html:ro \
  -v $PWD/nginx.conf:/etc/nginx/conf.d/default.conf \
  nginx
```
