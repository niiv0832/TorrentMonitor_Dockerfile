#------------------------------------------------------------------------------
# Set the base image for subsequent instructions:
#------------------------------------------------------------------------------
FROM alpine:latest
MAINTAINER nniiv0832 <dockerhubme-tormon@yahoo.com>
#------------------------------------------------------------------------------
# Environment variables:
#------------------------------------------------------------------------------
ENV VERSION="1.8.2" \
    RELEASE_DATE="03.01.2020" \
    CRON_TIMEOUT="0/10 * * * *" \
    PHP_TIMEZONE="UTC" \
    PHP_MEMORY_LIMIT="512M" \
    LD_PRELOAD="/usr/lib/preloadable_libiconv.so php"
#------------------------------------------------------------------------------
# Populate root file system:
#------------------------------------------------------------------------------
COPY rootfs /
#------------------------------------------------------------------------------
# Install:
#------------------------------------------------------------------------------
RUN apk update && \
    apk upgrade && \
#    delete from original: tar re2c file curl
    apk --no-cache add --update -t deps wget unzip sqlite && \
    apk --no-cache add \
    bash \
    curl \
    nginx \
    php7-common \
    php7-fpm \
    php7-sqlite3 \
    php7-pdo_sqlite \    
    php7-ctype \
    php7-curl \
    php7-iconv \
    php7-mbstring \
    php7-pdo \
    php7-simplexml \
    php7-xml \
    php7-zip \   
    php7-cli \
    php7-cgi \    
    php7-json \
    php7-session \
    gnu-libiconv \
    musl-utils && \
    wget -q http://korphome.ru/torrent_monitor/tm-latest.zip -O /tmp/tm-latest.zip && \
    unzip /tmp/tm-latest.zip -d /tmp/ && \
    mv /tmp/TorrentMonitor-master/* /data/htdocs && \
    cat /data/htdocs/db_schema/sqlite.sql | sqlite3 /data/htdocs/db_schema/tm.sqlite && \
    mkdir -p /var/log/nginx/ && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    ln -sf /dev/stdout /var/log/php-fpm.log && \
    apk del --purge deps; rm -rf /tmp/* /var/cache/apk/* && \ 
    chmod u+x /init
#------------------------------------------------------------------------------
# Set labels:
#------------------------------------------------------------------------------
LABEL ru.korphome.version="${VERSION}" \
      ru.korphome.release-date="${RELEASE_DATE}"
#------------------------------------------------------------------------------
# Set volumes, workdir, expose ports and entrypoint:
# /scripts - for http-knocking starting script and rclone config file
# /data/htdocs/torrents - for download .torrent files
#------------------------------------------------------------------------------
VOLUME ["/data/htdocs/db", "/data/htdocs/torrents", "/scripts"]
WORKDIR /
#------------------------------------------------------------------------------
# port 80 for direct TorMon; port 2000 for access through http-knocking:
#------------------------------------------------------------------------------
EXPOSE 80 2000
ENTRYPOINT ["/init"]
