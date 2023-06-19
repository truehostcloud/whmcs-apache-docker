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
  libfreetype6-dev \
  libmcrypt-dev; \
  rm -rf /var/lib/apt/lists/*

# Install additional PHP Packages and WHMCS Requirements
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mysqli

# For Domain Reseller
RUN docker-php-ext-install calendar \
  && docker-php-ext-install zip

RUN docker-php-ext-configure gd \
  --prefix=/usr \
  --with-jpeg \
  --with-webp \
  --with-freetype; \
  docker-php-ext-install gd; \
  php -r 'var_dump(gd_info());'

RUN apt-get update -yqq && \
  apt-get install -y zlib1g-dev libicu-dev g++ && \
  docker-php-ext-configure intl && \
  docker-php-ext-install intl

RUN docker-php-ext-install opcache
COPY ./opcache.ini /usr/local/etc/php/conf.d/opcache.ini

RUN pecl install memcached
RUN echo extension=memcached.so >> /usr/local/etc/php/conf.d/memcached.ini

RUN rm /etc/apt/preferences.d/no-debian-php && \
  apt-get -y install libxml2-dev php-soap && \
  docker-php-ext-install soap;

# Install the php ioncube loader
# Essential part to run WHMCS
RUN cd /tmp \
  && curl -o ioncube.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
  && tar zxpf ioncube.tar.gz \
  && mv ioncube/ioncube_loader_lin_7.4.so /usr/local/lib/php/extensions/* \
  && rm -Rf ioncube.tar.gz ioncube \
  && echo "zend_extension=ioncube_loader_lin_7.4.so" > /usr/local/etc/php/conf.d/docker-php-ext-ioncube_loader.ini \
  && rm -rf /tmp/ioncube*

# Clean up
RUN apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  rm /var/log/lastlog /var/log/faillog
