#------------------------------------------------------------------------------
# Set the base image for subsequent instructions:
#------------------------------------------------------------------------------
FROM alpine:3.8
MAINTAINER nniiv0832 <dockerhubme-tormon@yahoo.com>
#------------------------------------------------------------------------------
# Environment variables:
#------------------------------------------------------------------------------
ENV VERSION="1.8.2" \
    RELEASE_DATE="03.01.2020" \
    CRON_TIMEOUT="0/10 * * * *" \
    PHP_TIMEZONE="UTC" \
    PHP_MEMORY_LIMIT="512M" \
    LD_PRELOAD="/usr/local/lib/preloadable_libiconv.so"
#------------------------------------------------------------------------------
# Populate root file system:
#------------------------------------------------------------------------------
COPY rootfs /
#------------------------------------------------------------------------------
# Install:
#------------------------------------------------------------------------------
RUN apk update && \
    apk upgrade && \
#    delete from original: tar re2c file curl sqlite
###    apk --no-cache add --update -t deps wget unzip && \
#------------------------------------------------------------------------------
# Temporarily install build environment 
#------------------------------------------------------------------------------
    apk --no-cache add --update -t deps wget unzip sqlite build-base tar re2c make file curl && \
#------------------------------------------------------------------------------
# Install nginx and php7
#------------------------------------------------------------------------------
    apk --no-cache add \
    bash \
    nginx \ 
    php5-common \
    php5-cli \
    php5-fpm \
    php5-curl \
    php5-sqlite3 \
    php5-mysql \
    php5-pdo_sqlite \
    php5-iconv \
    php5-json \
    php5-ctype \
    php5-zip && \
#------------------------------------------------------------------------------
# Download and install TM 
#------------------------------------------------------------------------------
    wget -q http://korphome.ru/torrent_monitor/tm-latest.zip -O /tmp/tm-latest.zip && \
    unzip /tmp/tm-latest.zip -d /tmp/ && \
    mv /tmp/TorrentMonitor-master/* /data/htdocs && \
    cat /data/htdocs/db_schema/sqlite.sql | sqlite3 /data/htdocs/db_schema/tm.sqlite && \
    mkdir -p /var/log/nginx/ && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    ln -sf /dev/stdout /var/log/php-fpm.log && \
#------------------------------------------------------------------------------
# Build proper libiconv
#------------------------------------------------------------------------------     
    rm /usr/bin/iconv && \
    curl -SL http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz | tar -xz -C /tmp && \
    cd /tmp/libiconv-1.14 && patch -p1 < /tmp/iconv-patch.patch && \
    ./configure --prefix=/usr/local && \
    make && make install && \
#------------------------------------------------------------------------------
# Cleanup
#------------------------------------------------------------------------------    
    apk del --purge deps; rm -rf /tmp/* /var/cache/apk/* && \
###    rm -rf /tmp/* /var/cache/apk/* && \
#------------------------------------------------------------------------------
# Make /init executables 
#------------------------------------------------------------------------------ 
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
