ARG BASE_IMAGE="graycore/magento-php:8.1-cli-alpine-v6.0.0-alpha.4"
FROM ${BASE_IMAGE}

ARG MAGEOS_VERSION=v2.4.5

COPY ./patches/patches.json /home/patches.json

RUN composer create-project --no-interaction --no-install  --repository-url=https://mirror.mage-os.org/ magento/project-community-edition:${MAGEOS_VERSION} /var/www/html && \
    composer require --no-interaction --no-install cweagans/composer-patches && \
    composer config --no-interaction extra.patches-file /home/patches.json && \
    composer config --no-interaction extra.composer-exit-on-patch-failure true && \
    composer config --no-interaction allow-plugins.cweagans/composer-patches true && \
    composer config --no-interaction allow-plugins.dealerdirect/phpcodesniffer-composer-installer true && \
    composer config --no-interaction allow-plugins.laminas/laminas-dependency-plugin true && \
    composer config --no-interaction allow-plugins.magento/* true && \
    composer install --no-interaction && \
    rm -rf /var/www/html/vendor/magento/magento2-base && \
    rm -rf /var/www/html/vendor/magento/**/**/Test && \ 
    rm -rf /var/www/html/dev/

COPY ./conf/config.php /var/www/html/app/etc/config.php

RUN php bin/magento setup:di:compile && \
    composer dump-autoload -o --classmap-authoritative && \
    php bin/magento setup:static-content:deploy -f  \
    --theme Magento/backend \
    --theme Magento/luma \
    && find var pub/media -type f -exec chmod g+w {} + \
    && find var pub/media -type d -exec chmod g+ws {} + \
    && chown -R :www-data var pub/media \ 
    && chmod u+x bin/magento
