FROM mageos/magento-cli:2.4.4-8.1 as builder

FROM graycore/magento-php:8.1-fpm-alpine-v6.0.0-alpha.3

COPY --from=builder /var/www/html /var/www/html
