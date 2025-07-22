#!/bin/bash

echo "DEBUG: Environment Variables"
printenv

set -e

echo "Original /usr/local/etc/php-fpm.d/"
# ls -la /usr/local/etc/php-fpm.d/
echo "Bersihkan /usr/local/etc/php-fpm.d/ dan timpa dengan fresh copy"
rm -vf /usr/local/etc/php-fpm.d/*
cp /etc/$PROJECT/www.conf /usr/local/etc/php-fpm.d/

if [ -n "$FPM_SESSION_SAVE_PATH" ]; then
    echo -e "php_value[session.save_handler] = memcached\nphp_value[session.save_path] = $FPM_SESSION_SAVE_PATH" >> /usr/local/etc/php-fpm.d/www.conf
fi

cat /usr/local/etc/php-fpm.d/www.conf

webcorecli project $PROJECT
webcorecli config $PROJECT
webcorecli theme $PROJECT dore

# tambahkan `|| [[ -n $name ]]` agar membaca baris terakhir dari modules.list, tanpa itu baris terkahir tidak akan terbaca jika file tidak diahiri dengan baris kosong
while read -r name url || [[ -n $name ]]; do
  # Lewati baris kosong atau baris yang diawali dengan #
  [[ -z "$name" || "$url" =~ ^# ]] && continue
  echo "webcorecli module $PROJECT $name $url"
  webcorecli module "$PROJECT" "$name" "$url"
done < <(grep -v '^[[:space:]]*$' "/etc/$PROJECT/modules.list")

exec "$@"