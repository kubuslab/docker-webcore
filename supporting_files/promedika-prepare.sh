#!/bin/bash

function promedika_init() {
    if [ ! -f "/app/lib/.init.promedika" ]; then
        apt-get -y install php5.6 php-apcu php5.6-gd php5.6-xml php5.6-mbstring php-gettext php5.6-zip php5.6-curl php5.6-gd php5.6-mysql php5.6-pgsql
        update-alternatives --set php /usr/bin/php5.6
        a2enmod php5.6
        a2dismod php7.4

        # Download IonCubre
        MESIN=$(uname -m)
        MESIN="${MESIN/_/-}"
        wget -O /tmp/ioncube.tar.gz "https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_$MESIN.tar.gz"
        tar xvzf /tmp/ioncube.tar.gz -C /tmp/

        # COPY LIBRARY IONCUBE ke Extension Dir
        PHP_EXT_DIR=$(php -i | grep extension_dir | awk '{print $3}')
        cp /tmp/ioncube/ioncube_loader_lin_5.6.so $PHP_EXT_DIR

        # TAMBAHKAN CONFIG IONCUBE CLI dan APACHE2
        CONTENT_CONF="zend_extension = $PHP_EXT_DIR/ioncube_loader_lin_5.6.so"
        echo $CONTENT_CONF > /etc/php/5.6/cli/conf.d/00-ioncube.ini
        echo $CONTENT_CONF > /etc/php/5.6/apache2/conf.d/00-ioncube.ini

        # Restart APACHE Server
        supervisorctl restart apache2

        # tandai sudah ini, supaya tidak init ulang
        touch "/app/lib/.init.promedika"
    fi
}

promedika_init
