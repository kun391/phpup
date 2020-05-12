# The FROM instruction sets the Base Image for subsequent instructions.
# As such, a valid Dockerfile must have FROM as its first instruction.
FROM richarvey/nginx-php-fpm:1.9.0

# The MAINTAINER instruction allows you to set the Author field of the generated images.
MAINTAINER Kun <nguyentruongthanh.dn@gmail.com>

# Install composer parallel
RUN composer global require hirak/prestissimo

# setting working dir when user login
WORKDIR /var/www/app

ENV CERT_SSL_DIR /etc/nginx/www-ssl

ENV WEBROOT /var/www/app

RUN mkdir $CERT_SSL_DIR

RUN openssl genrsa -out $CERT_SSL_DIR/privateKey.key 2048

RUN openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout $CERT_SSL_DIR/privateKey.key -out $CERT_SSL_DIR/certificate.crt -subj "/C=VN/ST=DaNang/L=Brooklyn/O=GG/CN=info@greenglobal.vn"

COPY conf/nginx.conf /etc/nginx/sites-enabled/default.conf

RUN apk --update add python

RUN apk add supervisor

COPY conf/supervisord.conf /etc/supervisor/supervisord.conf

RUN mkdir /etc/supervisor/conf.d

RUN docker-php-ext-configure pcntl \
    && docker-php-ext-install pcntl bcmath sockets \
    && docker-php-ext-enable pcntl xdebug bcmath