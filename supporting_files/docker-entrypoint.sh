#!/bin/bash

echo "DEBUG: Environment Variables"
printenv

set -e

echo "Original /usr/local/etc/php-fpm.d/www.conf"

if [ -n "$FPM_SESSION_SAVE_PATH" ]; then
    echo -e ";php_value[session.save_handler] = memcached\n;php_value[session.save_path] = $FPM_SESSION_SAVE_PATH" >> /usr/local/etc/php-fpm.d/www.conf
fi

cat /usr/local/etc/php-fpm.d/www.conf

webcorecli project $PROJECT
webcorecli config $PROJECT
webcorecli theme $PROJECT dore
while read -r name url; do
  # Lewati baris kosong atau baris yang diawali dengan #
  [[ -z "$name" || "$url" =~ ^# ]] && continue
  echo "webcorecli module $PROJECT $name $url"
  webcorecli module "$PROJECT" "$name" "$url"
done < "/etc/$PROJECT/modules.list"

# Perbaiki config sesuai DOMAIN
confdir=$APPDIR/$PROJECT/application/config/domains
cp -rf /etc/$PROJECT/domains/$DOMAIN $confdir

exec "$@"