#!/bin/bash

cat > /var/www/cloud/configuration.php <<PHP
  <?php
    \$license = '$WHMCS_LICENCE';
    \$db_host = '$DB_HOST';
    \$db_port = '';
    \$db_username = '$DB_USER';
    \$db_password = '$DB_PASSWORD';
    \$db_name = '$DB_NAME';
    \$cc_encryption_hash = '$WHMCS_CC_ENC_HASH';
    \$templates_compiledir = 'templates_c';
    \$mysql_charset = 'utf8';
    \$display_errors = true;
    \$api_access_key = '$API_ACCESS_KEY';
    \$autoauthkey = '$AUTO_AUTH_KEY';
    \$smarty_security_policy = array(
     'mail' => array(
         'php_modifiers' => array(
             'md5',
             'time',
              'sha1',
             'urlencode',
             'header',
         ),
     ),
  );
PHP

cron -f &
docker-php-entrypoint apache2-foreground