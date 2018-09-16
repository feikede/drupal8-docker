#
# Drupal 8 with composer and drush, drupal console, and in development mode without caching
#
FROM php:7-apache

# Drupal php setup from https://hub.docker.com/_/drupal/
# install the PHP extensions we need
RUN set -ex; \
	\
	if command -v a2enmod; then \
		a2enmod rewrite; \
	fi; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libjpeg-dev \
		libpng-dev \
		libpq-dev \
	; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install -j "$(nproc)" \
		gd \
		opcache \
		pdo_mysql \
		pdo_pgsql \
		zip \
	; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=3'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# install ssmtp and vi
ENV SSMTP_MAILHUB ${SSMTP_MAILHUB:-"mail"} 
RUN apt-get update && apt-get install -y ssmtp vim
RUN { \
		echo 'root=postmaster'; \
		echo "mailhub=$SSMTP_MAILHUB"; \
		echo 'FromLineOverride=YES'; \
	} > /etc/ssmtp/ssmtp.conf

# install composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
ENV COMPOSER_VERSION 1.7.2
ENV PHP_XDEBUG_DEFAULT_ENABLE ${PHP_XDEBUG_DEFAULT_ENABLE:-1} 
ENV PHP_XDEBUG_REMOTE_ENABLE ${PHP_XDEBUG_REMOTE_ENABLE:-1} 
ENV PHP_XDEBUG_REMOTE_HOST ${PHP_XDEBUG_REMOTE_HOST:-"127.0.0.1"} 
ENV PHP_XDEBUG_REMOTE_PORT ${PHP_XDEBUG_REMOTE_PORT:-9000} 
ENV PHP_XDEBUG_REMOTE_AUTO_START ${PHP_XDEBUG_REMOTE_AUTO_START:-1} 
ENV PHP_XDEBUG_REMOTE_CONNECT_BACK ${PHP_XDEBUG_REMOTE_CONNECT_BACK:-1} 
ENV PHP_XDEBUG_IDEKEY ${PHP_XDEBUG_IDEKEY:-docker} 
ENV PHP_XDEBUG_PROFILER_ENABLE ${PHP_XDEBUG_PROFILER_ENABLE:-0} 
ENV PHP_XDEBUG_PROFILER_OUTPUT_DIR ${PHP_XDEBUG_PROFILER_OUTPUT_DIR:-"/tmp"}

RUN curl --silent --fail --location --retry 3 --output /tmp/installer.php --url https://raw.githubusercontent.com/composer/getcomposer.org/b107d959a5924af895807021fcef4ffec5a76aa9/web/installer \
 && php -r " \
    \$signature = '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061'; \
    \$hash = hash('SHA384', file_get_contents('/tmp/installer.php')); \
    if (!hash_equals(\$signature, \$hash)) { \
        unlink('/tmp/installer.php'); \
        echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
        exit(1); \
    }" \
 && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
 && composer --ansi --version --no-interaction \
 && rm -rf /tmp/* /tmp/.htaccess

# install xdebug
RUN pecl install xdebug

# increase php memory and caching, add ssmtp and xdebug
RUN { \
    echo 'memory_limit = 768M'; \
		echo 'realpath_cache_size = 4M'; \
		echo 'realpath_cache_ttl = 480'; \
		echo 'sendmail_path = /usr/sbin/ssmtp -t'; \
        echo 'zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20170718/xdebug.so'; \
	} > /usr/local/etc/php/conf.d/d8-settings.ini

# install unzip, git, mysql-client (drush needs that sometimes for preflight)
RUN apt-get install -y git zip unzip mysql-client

# install drupal core
RUN cd /var/www && php /usr/bin/composer create-project drupal-composer/drupal-project:8.x-dev html --stability dev --no-interaction

# change location of public files to make nfs integration more easy
RUN mkdir /var/www/html/web/publicfs && chown 33 /var/www/html/web/publicfs

RUN { \
		echo '$settings["file_public_path"] = "publicfs";'; \
    echo 'if (file_exists($app_root . "/" . $site_path . "/settings.local.php")) {'; \
    echo '  include $app_root . "/" . $site_path . "/settings.local.php";'; \
    echo "}"; \
	} >> /var/www/html/web/sites/default/settings.php

# install dev settings
RUN cp /var/www/html/web/sites/example.settings.local.php /var/www/html/web/sites/default/settings.local.php && chown www-data /var/www/html/web/sites/default/settings.php /var/www/html/web/sites/default/settings.local.php

# disable caching
RUN { \
		echo '$settings["cache"]["bins"]["render"] = "cache.backend.null";'; \
    echo '$settings["cache"]["bins"]["page"] = "cache.backend.null";'; \
    echo '$settings["cache"]["bins"]["dynamic_page_cache"] = "cache.backend.null";'; \
	} >> /var/www/html/web/sites/default/settings.local.php

# install modules everbody needs :-)
RUN cd /var/www/html && php /usr/bin/composer require drupal/devel drupal/token drupal/pathauto drupal/metatag drupal/field_group drupal/paragraphs drupal/webform drupal/flag drupal/bootstrap

# stuff drupal needs to install
RUN mkdir -p /var/www/html/web/sites/default/files/translations && chown -R 33 /var/www/html/web/sites/default/files && chown 33 /var/www/html/web/sites/default/settings.php

# clean up a little bit
RUN apt-get clean && rm -r /var/lib/apt/lists/*

# override default-site
RUN { \
		echo '<VirtualHost *:80>'; \
		echo '        ServerAdmin webmaster@localhost'; \
		echo '        DocumentRoot /var/www/html/web'; \
		echo '        ErrorLog ${APACHE_LOG_DIR}/error.log'; \
		echo '        CustomLog ${APACHE_LOG_DIR}/access.log combined'; \
		echo '</VirtualHost>'; \
	} > /etc/apache2/sites-available/000-default.conf

# now expose files
VOLUME /var/www/html/web/themes/custom
VOLUME /var/www/html/web/modules/custom
VOLUME /var/www/html/web/publicfs
EXPOSE 80 443

# By default start up apache in the foreground, override with /bin/bash for interative.
CMD /usr/sbin/apache2ctl -D FOREGROUND


