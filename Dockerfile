# The FROM instruction sets the Base Image for subsequent instructions.
# As such, a valid Dockerfile must have FROM as its first instruction.
FROM richarvey/nginx-php-fpm:1.10.3

# The MAINTAINER instruction allows you to set the Author field of the generated images.
LABEL maintainer="nguyentruongthanh.dn@gmail.com"

# Install composer parallel
RUN composer global require hirak/prestissimo

RUN docker-php-ext-configure pcntl \
    && docker-php-ext-install pcntl bcmath sockets tokenizer \
    && docker-php-ext-enable xdebug

RUN apk add supervisor

COPY conf/supervisord.conf /etc/supervisor/supervisord.conf

RUN mkdir /etc/supervisor/conf.d

# setting working dir when user login
WORKDIR /var/www/app

ENV WEBROOT /var/www/app

RUN apk --update add python3 curl

COPY conf/nginx.conf /etc/nginx/sites-enabled/default.conf