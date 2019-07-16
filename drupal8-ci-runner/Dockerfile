FROM php:7.2-apache

RUN apt-get update -yqq
RUN apt-get install -yqq sudo git zip unzip libzip-dev libpq-dev libjpeg-dev libpng-dev mariadb-client curl libcurl4-gnutls-dev libfreetype6-dev libicu-dev libxml2-dev
RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install mbstring pdo pdo_mysql pdo_pgsql curl json intl gd xml zip opcache
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

