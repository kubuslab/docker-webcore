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
    nginx \
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
ENV PHP_VERSION=7.4.28
ENV APPDIR=/app
ENV PROJECT=mpdn

# Prepare for webcore configuration
COPY supporting_files/app /etc/$PROJECT
COPY supporting_files/bin/* /usr/local/bin/
COPY supporting_files/conf/www.conf /usr/local/etc/php-fpm.d/docker.conf
COPY supporting_files/conf/nginx_default.conf /etc/nginx/http.d/default.conf

# Siapkan WORKDIR
# Install Composer
# Hapus file /usr/local/etc/php-fpm.d/zz-docker.conf
RUN mkdir -p $APPDIR/$PROJECT; \
    rm -f /usr/local/etc/php-fpm.d/zz-docker.conf; \
    chmod 755 /usr/local/bin/webcorecli; \
    chmod +x /usr/local/bin/docker-entrypoint.sh /usr/local/bin/start-nginx-fpm.sh; \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR $APPDIR/$PROJECT

EXPOSE 80
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["start-nginx-fpm.sh"] 
