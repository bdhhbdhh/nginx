FROM nginx:alpine

ENV HEADERS_MORE_VERSION 0.33
ENV NAXSI_VERSION 0.56

RUN apk add --no-cache --virtual .build-deps curl gcc gcc6 libc-dev make openssl-dev pcre-dev zlib-dev linux-headers gnupg libxslt-dev gd-dev geoip-dev && \
    cd / && \
    curl -O https://codeload.github.com/openresty/headers-more-nginx-module/tar.gz/v$HEADERS_MORE_VERSION && \
    tar -zxvf v$HEADERS_MORE_VERSION && \
    rm -f /v$HEADERS_MORE_VERSION && \
    curl -O https://codeload.github.com/nbs-system/naxsi/tar.gz/$NAXSI_VERSION && \
    tar -zxvf $NAXSI_VERSION && \
    rm -f /$NAXSI_VERSION && \
    curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz && \
    mkdir -p /usr/src && \
    tar -zxC /usr/src -f nginx.tar.gz && \
    rm /nginx.tar.gz && \
    cd /usr/src/nginx-$NGINX_VERSION && \
    nginx -V 2> /config && \
    CONFIG=$(grep "configure arguments:" /config|cut -f 2 -d ":") && \
    CONFIG="$CONFIG --add-module=/headers-more-nginx-module-$HEADERS_MORE_VERSION" && \
    CONFIG="$CONFIG --add-module=/naxsi-$NAXSI_VERSION/naxsi_src" && \
    rm -f /config && \
    ./configure $CONFIG --with-debug && \
    make CC=gcc-6 -j$(getconf _NPROCESSORS_ONLN) && \
    mv objs/nginx /usr/sbin/nginx-debug && \
    ./configure $CONFIG && \
    make CC=gcc-6 -j$(getconf _NPROCESSORS_ONLN) && \
    mv objs/nginx /usr/sbin/nginx && \
    rm -rf /headers-more-nginx-module-$HEADERS_MORE_VERSION && \
    rm -rf /naxsi-$NAXSI_VERSION && \
    rm -rf /usr/src/nginx-$NGINX_VERSION && \
    apk del .build-deps

EXPOSE 80
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]
