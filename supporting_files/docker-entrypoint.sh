#!/bin/bash

echo "DEBUG: Environment Variables"
printenv

set -e

# Generate www.conf from environment variables
cat > /usr/local/etc/php-fpm.d/www.conf <<EOF
[www]
user = www-data
group = www-data
listen = 9000
pm = ${FPM_PM:-dynamic}
pm.max_children = ${FPM_PM_MAX_CHILDREN:-5}
pm.start_servers = ${FPM_PM_START_SERVERS:-2}
pm.min_spare_servers = ${FPM_PM_MIN_SPARE_SERVERS:-1}
pm.max_spare_servers = ${FPM_PM_MAX_SPARE_SERVERS:-3}
php_value[session.save_handler] = memcache
php_value[session.save_path] = ${FPM_SESSION_SAVE_PATH:-"tcp://memcache:11211"}
EOF

webcorecli project $PROJECT
webcorecli config $PROJECT
webcorecli theme $PROJECT dore
while read -r name url; do
  # Lewati baris kosong atau baris yang diawali dengan #
  [[ -z "$name" || "$url" =~ ^# ]] && continue
  echo "webcorecli module $PROJECT $name $url"
  webcorecli module "$PROJECT" "$name" "$url"
done < "/etc/$PROJECT/modules.list"

# webcorecli module mpdn mpdn https://gitlab.com/webcore2/app-mpdn.git
# webcorecli module mpdn admin https://gitlab.com/webcore2/module-mpdn-admin.git
# webcorecli module mpdn api https://gitlab.com/webcore2/module-mpdn-api.git
# webcorecli module mpdn mpdrp https://gitlab.com/webcore2/app-mpdrp.git
# webcorecli module mpdn mpda https://gitlab.com/webcore2/app-mpda.git
# webcorecli module mpdn smsd https://gitlab.com/webcore2/module-smsd.git
# webcorecli module mpdn indikator https://gitlab.com/webcore2/module-mpdn-indikator.git
# webcorecli module mpdn mpdne https://gitlab.com/webcore2/module-mpdn-eksternal.git
# webcorecli module mpdn komdat https://gitlab.com/webcore2/module-mpdn-komdat.git
# webcorecli module mpdn dhis https://gitlab.com/webcore2/module-mpdn-dhis2.git
# webcorecli module mpdn fhir https://gitlab.com/webcore2/module-mpdn-fhir.git

# Perbaiki config sesuai DOMAIN
confdir=$APPDIR/$PROJECT/application/config/domains
cp -rf /etc/$PROJECT/domains/$DOMAIN $confdir

exec "$@"