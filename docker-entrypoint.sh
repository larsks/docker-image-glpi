#!/bin/sh

: ${MYSQL_HOST:=127.0.0.1}
: ${MYSQL_DATABASE:=glpi}
: ${MYSQL_USER:=glpi}

set -e

if [ -z "$MYSQL_PASSWORD" ]; then
	echo "ERROR: missing MYSQL_PASSWORD" >&2
	exit 1
fi

if [ ! -f /var/www/html/index.php ]; then
	echo "Extracting GLPI"
	tar -xf /usr/src/glpi-${GLPI_VERSION}.tgz --strip-components=1
fi

echo "Running early entrypoint scripts..."
find /docker-entrypoint-early.d -name '*.sh' -type f -print0 |
	sort -zn |
	xargs -0 -n1 sh

php bin/console glpi:system:check_requirements

if ! php bin/console glpi:system:status; then
	echo "Setting up database (this may take a while)"
	php bin/console db:install -n \
		--db-host=${MYSQL_HOST} \
		--db-name=${MYSQL_DATABASE} \
		--db-user=${MYSQL_USER} \
		--db-password=${MYSQL_PASSWORD}
fi


echo "Running late entrypoint scripts..."
find /docker-entrypoint-late.d -name '*.sh' -type f -print0 |
	sort -zn |
	xargs -0 -n1 sh

exec "$@"
