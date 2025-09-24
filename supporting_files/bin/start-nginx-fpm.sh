#!/bin/sh
set -e

# Start nginx in the background
nginx

# Start PHP-FPM in the foreground
php-fpm -F