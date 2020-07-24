# syntax = docker/dockerfile:experimental
FROM docker.io/phpdockerio/php74-cli:latest AS build-env
LABEL Maintainer="Pichate Ins <cogent[a]cogentwbebworks.com>"
LABEL Name="Pichate Ins"
LABEL Version="v0.1.6.1"
ARG SWOOLE_VERSION=v4.5.2
ENV SWOOLE_VERSION=${SWOOLE_VERSION}
RUN apt-get update \
    && apt-get -y --no-install-recommends install \
    build-essential \
    git \
    inotify-tools \
    libssl-dev \
    supervisor \
    unzip \
    zlib1g-dev \
    php7.4-curl \ 
    php7.4-json \
    php7.4-gd \
    php7.4-mbstring \
    php7.4-intl \
    php7.4-bcmath \
    php7.4-bz2 \
    php7.4-redis \
    php7.4-readline \
    php7.4-zip \
    php7.4-mysql \
    php7.4-pgsql \
    php7.4-pdo \
    php7.4-dev \
    && cd /tmp \
    && git clone https://github.com/swoole/swoole-src.git \
    && cd swoole-src \
    && git checkout ${SWOOLE_VERSION}\
    && phpize \
    && ./configure --enable-openssl --enable-http2 --enable-sockets --enable-mysqlnd --enable-coroutine-postgresql --enable-thread  --enable-coroutine  \
    && make \
    && make install-modules \
    && echo "extension=swoole.so" >> /etc/php/7.4/cli/php.ini \
    && apt-get autoremove --purge -y  php7.4-dev build-essential \
    && cd / \
    && rm -rf /tmp/swole-src \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN mkdir -p /var/log/cron \
    && touch /var/log/cron/cron.log \
    && mkdir -m 0644 -p /etc/cron.d 

EXPOSE 1215