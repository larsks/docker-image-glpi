#!/bin/sh

: ${DB_HOST:=127.0.0.1}
: ${DB_NAME:=glpi}
: ${DB_USER:=glpi}

set -e

if [ -z "$DB_PASS" ]; then
	echo "ERROR: missing DB_PASS" >&2
	exit 1
fi

if [ ! -f /var/www/html/index.php ]; then
	echo "Extracting GLPI"
	tar -xf /usr/src/glpi-${GLPI_VERSION}.tgz --strip-components=1
fi

if ! php bin/console glpi:system:status; then
	echo "Setting up database (this may take a while)"
	php bin/console db:install -n \
		--db-host=${DB_HOST} \
		--db-name=${DB_NAME} \
		--db-user=${DB_USER} \
		--db-password=${DB_PASS}
fi

exec "$@"
