# syntax = docker/dockerfile:experimental
FROM docker.io/alpine:3 AS build-env
LABEL Maintainer="Pichate Ins <pichate.ins[at]outlook.com>"
LABEL Name="Pichate Ins"
LABEL Version="v0.2.0"
ARG SWOOLE_VERSION=v4.5.2
ENV SWOOLE_VERSION=${SWOOLE_VERSION}
WORKDIR /tmp
RUN apk --update add --no-cache \
    freetype \
    libjpeg-turbo \
    libpng \
    nghttp2 \
    ca-certificates \
    supervisor \
    tzdata \
    libstdc++ \
    libbz2 \
    bzip2 \
    libzip \
    libxml2 \
    gmp \
    zlib \
    yaml \
    git

RUN apk --update add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community \
   php7 \
   php7-bcmath \
   php7-bz2 \
   php7-calendar \
   php7-ctype \
   php7-curl \
   php7-dbg \
   php7-dev \
   php7-dom \
   php7-exif \
   php7-fileinfo \
   php7-gd \
   php7-gettext \
   php7-iconv \
   php7-imap \
   php7-intl \
   php7-json \
   php7-mbstring \
   php7-mysqli \
   php7-mysqlnd \
   php7-opcache \
   php7-openssl \
   php7-pcntl \
   php7-pdo \
   php7-pdo_mysql \
   php7-pdo_pgsql \
   php7-pear \
   php7-pgsql \
   php7-phar \
   php7-phpdbg \
   php7-posix \
   php7-session \
   php7-soap \
   php7-sockets \
   php7-sodium \
   php7-sqlite3 \
   php7-static \
   php7-tidy \
   php7-tokenizer \
   php7-xml \
   php7-xmlrpc \
   php7-xsl \
   php7-zip \ 
   php7-pecl-redis \
   libbsd

RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    linux-headers \
    make \
    automake \
    autoconf \
    gcc \
    g++ \ 
    musl-dev \
    zlib-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    bzip2-dev \
    libzip-dev \
    libxml2-dev \
    gmp-dev \
    openssl-dev \
    nghttp2-dev \
    yaml-dev \
    postgresql-dev \
    libmcrypt-dev \
    libxml2-dev \
    libbsd-dev \
    file \
    curl 

RUN git clone -b ${SWOOLE_VERSION} --depth 1 https://github.com/swoole/swoole-src.git \
    && cd swoole-src \
    && phpize \
    && ./configure --with-php-config=/usr/bin/php-config7 --enable-openssl --enable-http2 --enable-sockets --enable-mysqlnd  \
    && make && make install

RUN touch /etc/php7/conf.d/03_swoole.ini \
    && echo "extension=swoole.so" > /etc/php7/conf.d/03_swoole.ini && cd && rm -rf /tmp/swoole-src

RUN set -x ; \
  addgroup -g 82 -S www-data ; \
  adduser -u 82 -D -S -G www-data www-data && exit 0 ; exit 1

RUN mkdir -p /var/log/cron \
    && touch /var/log/cron/cron.log \
    && mkdir -pm 0644 /etc/cron.d \
    && mkdir -pm 0755 /var/www \
    && chown -R www-data:www-data /var/www

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
RUN composer global require hirak/prestissimo
RUN cp /usr/share/zoneinfo/Asia/Bangkok /etc/localtime && echo "Asia/Bangkok" > /etc/timezone
RUN apk del .build-deps
EXPOSE 1215