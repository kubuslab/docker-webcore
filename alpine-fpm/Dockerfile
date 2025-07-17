FROM php:7.4.28-fpm-alpine

# Install system dependencies and PHP extensions
RUN apk add --no-cache \
    bash \
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
        mysqli \
        zip \
        json \
        mbstring \
        gd \
        xml \
    && pecl install memcached \
    && pecl install mcrypt \
    && pecl install apcu \
    && docker-php-ext-enable memcached mcrypt apcu

#Environment variables to configure php
# ENV PHP_UPLOAD_MAX_FILESIZE 10M
# ENV PHP_POST_MAX_SIZE 10M
ENV PHP_VERSION=7.4.28
ENV APPDIR=/app
ENV PROJECT=mpdn

# Prepare for webcore configuration
COPY supporting_files/domains /etc/$PROJECT/domains/
ADD supporting_files/modules.list /etc/$PROJECT/modules.list
ADD supporting_files/setup-webcore.sh /usr/local/bin/webcorecli
ADD supporting_files/www.conf /usr/local/etc/php-fpm.d/www.conf
RUN chmod 755 /usr/local/bin/webcorecli

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Siapkan WORKDIR
RUN mkdir -p $APPDIR/$PROJECT
WORKDIR $APPDIR/$PROJECT
COPY app/info.php /etc/$PROJECT/info.php

COPY supporting_files/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 9000
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"] 
