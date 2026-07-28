#!/bin/bash
set -e

mkdir -p /run/php /var/run/apache2 /var/lock/apache2 /var/log/apache2
chown www-data:www-data /run/php

php-fpm &

exec apache2-foreground
