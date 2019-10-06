FROM php:7.2-apache

RUN apt-get update -yqq
RUN apt-get install -yqq sudo git zip unzip libzip-dev libpq-dev libjpeg-dev libpng-dev mariadb-client curl libcurl4-gnutls-dev libfreetype6-dev libicu-dev libxml2-dev
RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install mbstring pdo pdo_mysql pdo_pgsql curl json intl gd xml zip opcache bcmath
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'a5c698ffe4b8e849a443b120cd5ba38043260d5c4023dbf93e1558871f1f07f58274fc6f4c93bcfd858c6bd0775cd8d1') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer
RUN apt-get update -yqq
RUN apt-get -y install vim openssh-server mariadb-server-10.3
RUN ["/bin/bash", "-c", "debconf-set-selections <<< 'mariadb-server-10.3 mariadb-server/root_password password mariadb'"]
RUN ["/bin/bash", "-c", "debconf-set-selections <<< 'mariadb-server-10.3 mariadb-server/root_password_again password mariadb'"]
RUN sed -i 's:DocumentRoot /var/www/html:DocumentRoot /webserver/webroot/web:g' /etc/apache2/sites-enabled/000-default.conf
RUN { \
		echo '<Directory /webserver/webroot/>'; \
		echo '	Options Indexes FollowSymLinks'; \
		echo '	AllowOverride All'; \
		echo '	Require all granted'; \
		echo '</Directory>'; \
	} >> /etc/apache2/apache2.conf
RUN a2enmod rewrite
RUN echo pdo_mysql.default_socket=/var/run/mysqld/mysqld.sock >> /usr/local/etc/php/conf.d/docker-php-ext-pdo_mysql.ini
COPY d8d /usr/local/bin/
RUN mkdir -p /webserver/webroot
RUN echo "AllowGroups drupal" >> /etc/ssh/sshd_config
WORKDIR /webserver/webroot
CMD ["d8d"]
