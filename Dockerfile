FROM php:7.3.22-apache

RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mysqli
RUN apt-get update -y  \
        && apt-get install -y libpng-dev
RUN apt-get install -y zlib1g-dev
RUN apt-get install -y libzip-dev
RUN apt-get install -y libxml2-dev
RUN apt-get install -y nano
RUN apt-get install -y git
RUN apt-get install -y libjpeg-dev
RUN apt-get install -y libwebp-dev libjpeg62-turbo-dev libpng-dev libxpm-dev libfreetype6-dev
RUN apt-get install -y cron
RUN apt-get install -y libldap2-dev
RUN docker-php-ext-configure gd \
        --with-freetype-dir=/usr/lib/ \
        --with-png-dir=/usr/lib/ \
        --with-jpeg-dir=/usr/lib/ \
        --with-gd
RUN docker-php-ext-install gd
RUN docker-php-ext-install zip
RUN docker-php-ext-install soap
RUN docker-php-ext-install xml
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install intl
RUN docker-php-ext-install opcache
RUN apt-get update  \
        && apt-get install -y libc-client-dev libkrb5-dev  \
        && rm -r /var/lib/apt/lists/*
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl  \
        && docker-php-ext-install imap
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN docker-php-ext-install ldap

COPY ioncube_loader_lin_7.3.so /usr/local/lib/php/extensions/no-debug-non-zts-20180731/ioncube_loader_lin_7.3.so

#RUN rm -f /opt/docker/etc/httpd/ssl/server.crt && rm -f /opt/docker/etc/httpd/ssl/server.key

#COPY server.crt server.key /opt/docker/etc/httpd/ssl/

RUN a2enmod rewrite
RUN a2enmod ssl
COPY ./entrypoint.sh /

# RUN chmod -R 777 /var/www/cloud

RUN chmod +x ./entrypoint.sh
ENTRYPOINT ["sh", "entrypoint.sh"]
EXPOSE 443
EXPOSE 80