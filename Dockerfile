
FROM drupal:8.3.7-apache

RUN apt-get update && apt-get install -y ssmtp && apt-get clean && rm -r /var/lib/apt/lists/*

VOLUME /var/www/html

RUN { \
echo 'opcache.memory_consumption=128'; \
echo 'opcache.interned_strings_buffer=8'; \
echo 'opcache.max_accelerated_files=4000'; \
echo 'opcache.revalidate_freq=60'; \
echo 'opcache.fast_shutdown=1'; \
echo 'opcache.enable_cli=1'; \
} >> /usr/local/etc/php/conf.d/d8-recommended.ini

COPY ssmtp.conf /etc/ssmtp/ssmtp.conf

COPY zzz_d8_php.ini /usr/local/etc/php/conf.d/
