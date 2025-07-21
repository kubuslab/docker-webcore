#!/bin/sh
set -e

# Start PHP-FPM in the background
php-fpm &
ls -la /usr/local/etc/php-fpm.d/

# Start nginx in the foreground
nginx -g 'daemon off;' 