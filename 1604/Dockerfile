FROM phusion/baseimage:0.10.2
MAINTAINER TimKubus <timkubus@gmail.com>
ENV REFRESHED_AT 2021-03-10

# based on dgraziotin/lamp
# MAINTAINER Daniel Graziotin <daniel@ineed.coffee>

ENV DOCKER_USER_ID 501 
ENV DOCKER_USER_GID 20

ENV BOOT2DOCKER_ID 1000
ENV BOOT2DOCKER_GID 50

ENV PHPMYADMIN_VERSION=5.0.2
ENV PHPPGADMIN_VERSION=5.1
ENV SUPERVISOR_VERSION=4.2.0

# Tweaks to give Apache/PHP write permissions to the app
RUN usermod -u ${BOOT2DOCKER_ID} www-data && \
    usermod -G staff www-data && \
    useradd -r mysql && \
    usermod -G staff mysql

RUN groupmod -g $(($BOOT2DOCKER_GID + 10000)) $(getent group $BOOT2DOCKER_GID | cut -d: -f1)
RUN groupmod -g ${BOOT2DOCKER_GID} staff

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository. It contains the most recent stable release
#  of PostgreSQL.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN add-apt-repository -y ppa:ondrej/php && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
  apt-get update && \
  apt-get -o Dpkg::Options::="--force-confnew" --force-yes -fuy upgrade && \
  apt-get -y install postfix python3-setuptools wget git apache2 php7.4 php-apcu php7.4-gd php7.4-xml php7.4-mbstring php-gettext php7.4-zip php7.4-curl php-xdebug libapache2-mod-php pwgen zip unzip curl && \
  apt-get -y install mysql-server php7.4-mysql && \
  apt-get -y install postgresql-10 postgresql-client-10 postgresql-contrib-10 php7.4-pgsql libpq5 phppgadmin && \
  apt-get install -y --no-install-recommends locales && \
  apt-get -y install memcached php7.4-memcached && \
  apt-get -y autoremove && \
  update-alternatives --set php /usr/bin/php7.4 && \
  localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Adjust PostgreSQL configuration so that remote connections to the database are possible.
# And add ``listen_addresses`` to ``/etc/postgresql/10/main/postgresql.conf``
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/10/main/pg_hba.conf && \
  echo "listen_addresses='*'" >> /etc/postgresql/10/main/postgresql.conf

# Install supervisor 4
RUN curl -L https://pypi.io/packages/source/s/supervisor/supervisor-${SUPERVISOR_VERSION}.tar.gz | tar xvz && \
  cd supervisor-${SUPERVISOR_VERSION}/ && \
  python3 setup.py install

# Add image configuration and scripts
ADD supporting_files/start-apache2.sh /start-apache2.sh
ADD supporting_files/start-mysqld.sh /start-mysqld.sh
ADD supporting_files/start-postgres.sh /start-postgres.sh
ADD supporting_files/start-memcached.sh /start-memcached.sh
ADD supporting_files/run.sh /run.sh
RUN chmod 755 /*.sh
ADD supporting_files/supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supporting_files/supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf
ADD supporting_files/supervisord-postgres.conf /etc/supervisor/conf.d/supervisord-postgres.conf
ADD supporting_files/supervisord-memcached.conf /etc/supervisor/conf.d/supervisord-memcached.conf
ADD supporting_files/supervisord.conf /etc/supervisor/supervisord.conf
ADD supporting_files/mysqld_innodb.cnf /etc/mysql/conf.d/mysqld_innodb.cnf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql

# Add MySQL utils
ADD supporting_files/create_mysql_users.sh /create_mysql_users.sh

# Prepare for webcore configuration
ADD supporting_files/setup-webcore.sh /setup-webcore.sh
RUN chmod 755 /setup-webcore.sh
RUN ln -s /setup-webcore.sh /usr/bin/webcorecli
ADD supporting_files/php-webcore.ini /etc/php/7.4/cli/conf.d/92-webcore.ini
ADD supporting_files/php-webcore.ini /etc/php/7.4/apache2/conf.d/92-webcore.ini

# Add phpmyadmin
RUN wget -O /tmp/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz
RUN tar xfvz /tmp/phpmyadmin.tar.gz -C /var/www
RUN ln -s /var/www/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages /var/www/phpmyadmin
RUN mv /var/www/phpmyadmin/config.sample.inc.php /var/www/phpmyadmin/config.inc.php

# Add composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

## ENV MYSQL_PASS:-$(pwgen -s 12 1)

# config to enable .htaccess
ADD supporting_files/apache_default /etc/apache2/sites-available/000-default.conf
ADD supporting_files/apache_phppgadmin /etc/apache2/conf-available/phppgadmin.conf
RUN a2enmod rewrite

# Configure /app folder with sample app
ADD app/ /app
ADD app/index.php /app/index.php
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M
ENV PHP_VERSION 7.4

# Add volumes for the app and MySql
VOLUME  ["/var/lib/mysql", "/app", "/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Expose Ports:
# 80: HTTP, 3306: MySQL, 5432: PostgreSQL, 11211: Memcached
EXPOSE 80 3306 5432 11211
CMD ["/run.sh"]
