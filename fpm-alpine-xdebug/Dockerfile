ARG BASE_BUILDER_IMAGE="graycore/magento-php:8.1-fpm-alpine-v6.0.0-alpha.4"
ARG BASE_IMAGE="graycore/magento-php:8.1-fpm-alpine-develop-xdebug-v6.0.0-alpha.4"

FROM ${BASE_BUILDER_IMAGE} as builder

FROM ${BASE_IMAGE}

USER root:root

COPY --from=builder /var/www/html /var/www/html