#!/bin/sh

: ${MYSQL_HOST:=127.0.0.1}
: ${MYSQL_DATABASE:=glpi}
: ${MYSQL_USER:=glpi}

hash_password() {
	echo "<?php echo password_hash('$1', PASSWORD_BCRYPT) ?>" | php
}

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

if ! [ -z "$GLPI_PASSWORD" ]; then
	echo "Replacing password for glpi user..."
	hashed_password=$(hash_password "$GLPI_PASSWORD")
	awk -v PASSWORD="$hashed_password" -f /patch-glpi-password.awk \
		install/empty_data.php > install/empty_data.php.new
	mv install/empty_data.php.new install/empty_data.php
fi

if ! php bin/console glpi:system:status; then
	echo "Setting up database (this may take a while)"
	if ! php bin/console db:install -n \
		--db-host=${MYSQL_HOST} \
		--db-name=${MYSQL_DATABASE} \
		--db-user=${MYSQL_USER} \
		--db-password=${MYSQL_PASSWORD}; then

		# the db:install command will fail if the database is
		# already populated. in that cast, just re-run 
		# glpi:system:status now that we have set database
		# credentials to check if things are working.
		if php bin/console glpi:system:status; then
			echo "Using existing database"
		else
			echo "ERROR: failed to initialize database" >&2
			exit 1
		fi
	fi
fi

php bin/console db:update -n

echo "Running late entrypoint scripts..."
find /docker-entrypoint-late.d -name '*.sh' -type f -print0 |
	sort -zn |
	xargs -0 -n1 sh

exec "$@"
