FROM mateusd/mageos-cli:2.4.4-8.1-2 as builder

FROM graycore/magento-php:8.1-fpm-alpine-v6.0.0-alpha.4

COPY --from=builder /var/www/html /var/www/html
