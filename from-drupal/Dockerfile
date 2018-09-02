
FROM drupal:8.4.3-apache

RUN apt-get update && apt-get install -y ssmtp && apt-get clean && rm -r /var/lib/apt/lists/*

VOLUME /var/www/html/modules
VOLUME /var/www/html/themes
VOLUME /var/www/html/sites/default/files


COPY ssmtp.conf /etc/ssmtp/ssmtp.conf

COPY zzz_d8_php.ini /usr/local/etc/php/conf.d/
