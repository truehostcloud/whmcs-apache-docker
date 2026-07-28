FROM php:8.1-fpm AS fpm

FROM php:8.1-apache

RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    curl \
    wget \
    nano \
    vim \
    cron \
    zip \
    libzip-dev \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libjpeg-dev \
    libpng-dev \
    libwebp-dev \
    libfreetype6-dev \
    libmcrypt-dev \
    libxml2-dev \
    libicu-dev \
    g++; \
  rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql mysqli calendar zip

RUN docker-php-ext-configure gd \
  --with-jpeg \
  --with-webp \
  --with-freetype \
  && docker-php-ext-install gd

RUN docker-php-ext-configure intl && docker-php-ext-install intl
RUN docker-php-ext-install opcache soap

RUN pecl install memcached redis \
  && echo extension=memcached.so > /usr/local/etc/php/conf.d/memcached.ini \
  && echo extension=redis.so > /usr/local/etc/php/conf.d/redis.ini

COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

COPY ioncube_loader_lin_8.1.so /usr/local/lib/php/extensions/no-debug-non-zts-20210902/
RUN echo zend_extension=ioncube_loader_lin_8.1.so > /usr/local/etc/php/conf.d/docker-php-ext-ioncube_loader.ini

COPY --from=fpm /usr/local/sbin/php-fpm /usr/local/sbin/php-fpm
COPY php-fpm.conf /usr/local/etc/php-fpm.conf
COPY php-fpm-pool.conf /usr/local/etc/php-fpm.d/www.conf
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN a2dismod mpm_prefork 2>/dev/null || true \
  && a2dismod php 2>/dev/null || true \
  && rm -f /etc/apache2/mods-enabled/php.load /etc/apache2/mods-enabled/php.conf \
  && a2enmod mpm_event proxy_fcgi setenvif rewrite ssl

RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && rm -f /var/log/lastlog /var/log/faillog

ENTRYPOINT ["entrypoint.sh"]
CMD ["apache2-foreground"]
