FROM FROM php:7.4-fpm-alpine
MAINTAINER TimKubus <timkubus@gmail.com>

# Install system dependencies and PHP extensions
RUN apk add --no-cache \
    git \
    libzip-dev \
    libmemcached-dev \
    zlib-dev \
    libxml2-dev \
    oniguruma-dev \
    autoconf \
    gcc \
    g++ \
    make \
    icu-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libmcrypt-dev \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        zip \
        json \
        mbstring \
        gd \
        xml \
    && pecl install memcached \
    && pecl install memcache \
    && pecl install mcrypt \
    && pecl install apcu \
    && docker-php-ext-enable memcached memcache mcrypt apcu

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M
ENV PHP_VERSION 7.4.28
ENV APPDIR /app
ENV PROJECT mpdn

# # Install packages
# ENV DEBIAN_FRONTEND noninteractive
# RUN add-apt-repository -y ppa:ondrej/php && \
#   apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
#   apt-get update && \
#   apt-get -y upgrade && \
#   apt-get -y install postfix python3-setuptools wget git apache2 php7.4 php-apcu php7.4-gd php7.4-xml php7.4-mbstring php-gettext php7.4-zip php7.4-curl php-xdebug libapache2-mod-php pwgen zip unzip curl && \
#   apt-get -y install mysql-server php7.4-mysql && \
#   apt-get -y install postgresql-10 postgresql-client-10 postgresql-contrib-10 php7.4-pgsql libpq5 phppgadmin && \
#   apt-get install -y --no-install-recommends locales && \
#   apt-get -y install memcached php7.4-memcached && \
#   apt-get -y autoremove && \
#   update-alternatives --set php /usr/bin/php7.4 && \
#   localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
#   echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Prepare for webcore configuration
COPY supporting_files/domains /etc/$PROJECT/domains
ADD supporting_files/modules.list /etc/$PROJECT/modules.list
ADD supporting_files/setup-webcore.sh /usr/local/bin/webcorecli
RUN chmod 755 /usr/local/bin/webcorecli

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Siapkan WORKDIR
RUN mkdir -p $APPDIR/$PROJECT
WORKDIR $APPDIR/$PROJECT

COPY supporting_files/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"] 
