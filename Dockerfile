FROM alpine:3.17 as base
FROM php:8.1.13-alpine3.17 as php
FROM blacktop/elasticsearch:7.5 as elastic

LABEL maintainer="Osiozekhai Aliu"


FROM base as redis
RUN apk add --no-cache redis


FROM php as composer
ENV WORKDIR /var/www/html
ENV MAGENTO_VERSION 2.4.5-p1
WORKDIR $WORKDIR
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer \
    && chmod +x -R /usr/local/bin/ \
    && composer create-project --no-dev --remove-vcs --ignore-platform-reqs \
    --repository-url=https://mirror.mage-os.org/ magento/project-community-edition:"${MAGENTO_VERSION}" . \
    && composer req --ignore-platform-reqs magepal/magento2-gmailsmtpapp yireo/magento2-webp2 dominicwatts/cachewarmer \
    magento/module-bundle-sample-data magento/module-catalog-rule-sample-data magento/module-catalog-sample-data \
    magento/module-cms-sample-data magento/module-configurable-sample-data magento/module-customer-sample-data \
    magento/module-downloadable-sample-data magento/module-grouped-product-sample-data magento/module-msrp-sample-data \
    magento/module-offline-shipping-sample-data magento/module-product-links-sample-data magento/module-review-sample-data \
    magento/module-sales-rule-sample-data magento/module-sales-sample-data magento/module-swatches-sample-data \
    magento/module-tax-sample-data magento/module-theme-sample-data magento/module-widget-sample-data \
    magento/module-wishlist-sample-data magento/sample-data-media


FROM php as php-extended

ENV WORKDIR /var/www/html

RUN apk update  \
    && apk upgrade \
    && apk add --virtual build-dependencies libc-dev libxslt-dev freetype-dev libjpeg-turbo-dev  \
    libpng-dev libzip-dev libwebp-dev \
    && apk add --virtual .php-deps make \
    && apk add --virtual .build-deps $PHPIZE_DEPS zlib-dev icu-dev gettext gettext-dev \
    g++ curl-dev wget ca-certificates gnupg openssl \
    && apk add nano tzdata icu procps supervisor pwgen openjdk11 bash su-exec \
    && echo 'https://dl-cdn.alpinelinux.org/alpine/v3.12/main' >> /etc/apk/repositories \
    && apk add --no-cache mariadb=10.4.25-r0 mariadb-client=10.4.25-r0 mariadb-server-utils=10.4.25-r0 \
    && docker-php-ext-configure hash --with-mhash \
    && docker-php-ext-configure gd --with-webp --with-jpeg --with-freetype \
    && docker-php-ext-install gd bcmath intl gettext pdo_mysql opcache soap sockets xsl zip \
    && pecl channel-update pecl.php.net \
    && pecl install -o -f redis apcu-5.1.21 \
    && docker-php-ext-enable redis apcu \
    && docker-php-source delete \
    && apk del --purge .php-deps .build-deps \
    && apk del --purge openjdk11-demos \
    && apk del --purge openjdk11-doc \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/* \
    && addgroup -S elasticsearch \
    && adduser -S elasticsearch -G elasticsearch \
    && echo "JAVA_HOME=/usr/lib/jvm/java-11-openjdk/bin/java" | tee -a /etc/profile  \
    && source /etc/profile \
    && addgroup -S redis \
    && adduser -S redis -G redis

COPY --from=composer $WORKDIR $WORKDIR
COPY --from=elastic --chown=elasticsearch:elasticsearch /usr/share/elasticsearch /usr/share/elasticsearch
COPY --from=elastic --chown=elasticsearch:elasticsearch /etc/logrotate.d/elasticsearch /etc/logrotate.d/elasticsearch
COPY --from=redis --chown=redis:redis /etc/logrotate.d/redis /etc/logrotate.d/redis
COPY --from=redis --chown=redis:redis /etc/sentinel.conf /etc/sentinel.conf
COPY --from=redis --chown=redis:redis /var/log/redis /var/log/redis
COPY --from=redis --chown=redis:redis /var/lib/redis /var/lib/redis
COPY --from=redis --chown=redis:redis /run/redis /run/redis
COPY --from=redis --chown=redis:redis /usr/bin/redis-server /usr/bin/redis-server

COPY .docker/config/php/php-ini-overrides.ini /usr/local/etc/php/conf.d/php-ini-overrides.ini
COPY .docker/config/mysql/z.cnf /etc/mysql/z.cnf
COPY .docker/config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY .docker/scripts/* /usr/local/bin/
COPY .docker/config/mysql/z.cnf /etc/mysql/z.cnf
COPY .docker/config/redis/my-redis.conf /etc/my-redis.conf
COPY .env /usr/local/bin/

RUN chmod +x /usr/share/elasticsearch/bin/elasticsearch \
    && mkdir -p /usr/share/elasticsearch/jdk/bin/ \
    && ln -s /usr/bin/java /usr/share/elasticsearch/jdk/bin/java \
    && chmod +x -R /usr/local/bin/

WORKDIR $WORKDIR
EXPOSE 80
CMD [ "supervisord-wrap" ]