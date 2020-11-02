FROM php:7-fpm-alpine AS builder

RUN apk add --update \
	bzip2-dev \
	zlib-dev \
	libpng-dev \
	libjpeg-turbo-dev \
	libxpm-dev \
	libwebp-dev \
	libzip-dev \
	icu-dev

RUN docker-php-ext-install \
	mysqli \
	gd \
	bz2 \
	zip \
	intl

FROM php:7-fpm-alpine

ARG GLPI_VERSION=9.5.2
ARG EXTENSION_VERSION_SLUG=no-debug-non-zts-20190902

RUN apk add --update libpng libjpeg-turbo libxpm libwebp libzip libbz2 icu-libs
COPY --from=builder /usr/local/lib/php/extensions/${EXTENSION_VERSION_SLUG}/* \
	/usr/local/lib/php/extensions/${EXTENSION_VERSION_SLUG}/
COPY --from=builder /usr/local/etc/php/conf.d/* /usr/local/etc/php/conf.d

RUN wget -O /tmp/glpi-${GLPI_VERSION}.tgz https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz && \
	tar -C /usr/src -xf /tmp/glpi-${GLPI_VERSION}.tgz && \
	rm -f /tmp/glpi-${GLPI_VERSION}.tgz && \
	ln -s glpi-${GLPI_VERSION} /usr/src/glpi

#RUN php bin/console glpi:system:check_requirements

COPY docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /var/www/html
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["php-fpm"]

