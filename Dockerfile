
# Pull our nginx image to harvest the required assets

FROM dynamedia/docker-nginx:v1.20.0 as nginx

# Use our php image as the base for this combined image as it's the more complex of the two

FROM dynamedia/docker-php-fpm:v7.4.x

LABEL maintainer="Rob Ballantyne <rob@dynamedia.uk>"

### Install packages required by Nginx, its module deps and our process manager ###

COPY --from=nginx /usr/local/modsecurity/ /usr/local/modsecurity/

COPY --from=nginx /usr/local/nginx/ /usr/local/nginx/

COPY --from=nginx /etc/nginx/ /etc/nginx/

COPY --from=nginx /usr/local/bin/entrypoint.sh /usr/local/bin/nginx-entrypoint.sh

COPY ./php.conf /etc/nginx/sites-enabled/conf.d/php.conf

RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
        ca-certificates     \
        vim                 \
        curl                \
        liblua5.2-0         \
        zlib1g              \
        libssl1.1           \
        libpcre3            \
        libxml2             \
        libyajl2            \
        libgeoip1           \
        libmaxminddb0       \
        mmdb-bin            \
	sendmail-bin        \
        cron                \
        supervisor && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    ldconfig && \
    mkdir -p /var/log/nginx && \
    mkdir -p /var/www/app && \
    mkdir -p /var/cache/nginx/standard_cache && \
    mkdir -p /var/cache/nginx/micro_cache && \
    mkdir -p /var/cache/nginx/ngx_pagespeed && \
    mkdir -p /var/log/nginx && \
    mkdir -p /var/log/supervisor && \
    ln -s /usr/local/nginx/nginx /usr/local/bin && \
    mv /usr/local/bin/entrypoint.sh /usr/local/bin/fpm-entrypoint.sh

COPY ./config/php/default/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./config/php/default/php.ini /usr/local/etc/php/php.ini

COPY ./config/nginx/default/nginx.conf /etc/nginx/nginx.conf
COPY ./config/nginx/default/sites-enabled /etc/nginx/sites-enabled

COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

CMD ["/usr/bin/supervisord"]
