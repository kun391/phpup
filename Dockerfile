FROM php:8.0.5-fpm-alpine

LABEL maintainer="Kun <nguyentruongthanh.dn@gmail.com>"
# The MAINTAINER instruction allows you to set the Author field of the generated images.
USER root
# https://github.com/wp-cli/wp-cli/issues/3840
ENV PAGER="more"

# Install packages and remove default server definition
RUN apk --no-cache add nginx supervisor curl tzdata htop mysql-client dcron libxml2-dev g++ make

# Symlink php8 => php
RUN ln -s /usr/bin/php8 /usr/bin/php

# Install PHP tools
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Configure supervisord
COPY conf/supervisord.conf /etc/supervisor/supervisord.conf

RUN mkdir /etc/supervisor/conf.d

RUN mkdir /.composer
# Install composer parallel
RUN composer global require hirak/prestissimo --ignore-platform-reqs

RUN docker-php-ext-install ctype bcmath sockets

# Install GD extension

RUN apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev && \
  docker-php-ext-configure gd --with-freetype --with-jpeg && \
  docker-php-ext-install -j$(nproc) gd && \
  apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

RUN apk add --no-cache icu-dev oniguruma-dev

RUN docker-php-ext-install dom exif fileinfo iconv intl mbstring mysqli 

RUN apk add php8-dev libzip libzip-dev postgresql-dev

RUN docker-php-ext-install zip xml simplexml pdo xmlwriter tokenizer pdo_mysql pdo_pgsql

RUN apk add --no-cache php8-fpm php8-opcache php8-session php8-openssl php8-pdo

# Install packages and remove default server definition
RUN apk --no-cache add \
    php8-ctype \
    php8-curl \
    php8-dom \
    php8-exif \
    php8-fileinfo \
    php8-fpm \
    php8-gd \
    php8-iconv \
    php8-intl \
    php8-mbstring \
    php8-mysqli \
    php8-opcache \
    php8-openssl \
    php8-pecl-imagick \
    php8-pecl-redis \
    php8-phar \
    php8-session \
    php8-simplexml \
    php8-soap \
    php8-xml \
    php8-xmlreader \
    php8-zip \
    php8-zlib \
    php8-pdo \
    php8-pdo_pgsql \
    php8-xmlwriter \
    php8-tokenizer \
    php8-pdo_mysql \
    nginx supervisor curl tzdata htop mysql-client dcron

#setting working dir when user login
WORKDIR /var/www/app

ENV WEBROOT /var/www/app

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/sites-enabled/default.conf

# Expose the port nginx is reachable on

EXPOSE 8080 80

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
