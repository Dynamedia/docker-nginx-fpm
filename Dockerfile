# Pull our nginx image to harvest the required assets

FROM dynamedia/docker-nginx as nginx

# Use our php image as the base for this combined image as it's the more complex of the two

FROM dynamedia/docker-php-fpm

LABEL maintainer="Rob Ballantyne <rob@dynamedia.uk>"

### Install packages required by Nginx, its module deps and our process manager ###

RUN apt update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
        ca-certificates \
        libcurl4-openssl-dev  \
        libyajl-dev \
        lua5.2-dev \
        libgeoip-dev \
        vim \
        libxml2 \
        libmaxminddb0 \
        libmaxminddb-dev \
        mmdb-bin \
        supervisor && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    ldconfig

COPY --from=nginx /usr/local/modsecurity/ /usr/local/modsecurity/

COPY --from=nginx /usr/local/nginx/ /usr/local/nginx/

COPY --from=nginx /etc/nginx/ /etc/nginx/

COPY --from=nginx /usr/local/bin/entrypoint.sh /usr/local/bin/nginx-entrypoint.sh

# Create required files and directories

RUN mkdir -p /var/log/nginx && \
    mkdir -p /var/www/app && \
    cp /usr/local/nginx/html/* /var/www/app && \
    mkdir -p /etc/nginx/modsecurity.d && \
    mkdir -p /etc/nginx/conf.d && \
    mkdir -p /var/cache/nginx/standard_cache && \
    mkdir -p /var/cache/nginx/micro_cache && \
    mkdir -p /var/cache/nginx/ngx_pagespeed && \
    mkdir -p /var/log/nginx && \
    mkdir -p /var/log/supervisor && \
    ln -s /usr/local/nginx/nginx /usr/local/bin && \
    mv /usr/local/bin/entrypoint.sh /usr/local/bin/fpm-entrypoint.sh

COPY ./php.conf /etc/nginx/sites-enabled/conf.d/php.conf

COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

CMD ["/usr/bin/supervisord"]
