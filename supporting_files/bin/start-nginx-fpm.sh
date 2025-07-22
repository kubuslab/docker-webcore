#!/bin/sh
set -e

# Start PHP-FPM in the background
php-fpm &
echo "Cek ulang isi /usr/local/etc/php-fpm.d/"
ls -la /usr/local/etc/php-fpm.d/

# Start nginx in the foreground
nginx -g 'daemon off;' 