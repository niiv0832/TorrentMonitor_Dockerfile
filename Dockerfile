#------------------------------------------------------------------------------
# Set the base image for subsequent instructions:
#------------------------------------------------------------------------------
FROM node:buster-slim
MAINTAINER nniiv0832 <dockerhubme-tormon@yahoo.com>
#------------------------------------------------------------------------------
# Environment variables:
#------------------------------------------------------------------------------
ENV VERSION="1.8.2" \
    RELEASE_DATE="03.01.2020" \
    CRON_TIMEOUT="0/10 * * * *" \
    PHP_TIMEZONE="UTC" \
    PHP_MEMORY_LIMIT="512M" 
    #\
#    LD_PRELOAD="/usr/lib/preloadable_libiconv.so"
#------------------------------------------------------------------------------
# Install:
#------------------------------------------------------------------------------
RUN apt update && \
    apt upgrade && \
#------------------------------------------------------------------------------
# Install: preloadable_libiconv.so
#------------------------------------------------------------------------------
#    apt install -y build-essential && \
#    curl -SL http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz | tar -xz -C /tmp && \
#    cd /tmp/libiconv-1.15 && \
#    ./configure --prefix=/usr/local && \
#    make && make install && \
#    apt remove -y build-essential && \
#    apt autoremove -y && \    
#------------------------------------------------------------------------------
# Install: nginx and php
#-----------------------------------------------------------------------------    
    apt -y install \
                    bash \
                    cron \
                    nginx \
                    wget \
                    curl \
                    unzip \
                    sqlite3 \
#------------------------------------------------------------------------------
# Install: php
#------------------------------------------------------------------------------                    
                    php \
                    php-common \
                    php-cli \
                    php-cgi \
                    php-curl \
                    php-json \
                    php-mbstring \
                    php-sqlite3 \
                    php-xml \
                    php-fpm \
                    php-zip && \
#------------------------------------------------------------------------------
# Install: TorMon
#------------------------------------------------------------------------------  
    wget -q http://korphome.ru/torrent_monitor/tm-latest.zip -O /tmp/tm-latest.zip && \
    unzip /tmp/tm-latest.zip -d /tmp/ && \
    mkdir -p /data/htdocs && \
    mv /tmp/TorrentMonitor-master/* /data/htdocs && \
    cat /data/htdocs/db_schema/sqlite.sql | sqlite3 /data/htdocs/db_schema/tm.sqlite && \
    mkdir -p /var/log/nginx/ && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    ln -sf /dev/stdout /var/log/php-fpm.log && \
    rm -rf /tmp/* && \ 
#------------------------------------------------------------------------------
# Install: http-knocking
#------------------------------------------------------------------------------  
    /usr/local/bin/npm install -g http-knocking && \
#------------------------------------------------------------------------------
# Install: rclone
#------------------------------------------------------------------------------     
    mkdir -p /tmp/rclone  && \
    cd /tmp/rclone && \
    curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip  && \
    apt install unzip  && \
    unzip rclone-current-linux-amd64.zip && \
    cd /tmp/rclone/rclone-*-linux-amd64 && \
    cp rclone /bin/ && \
    chown root:root /bin/rclone && \
    chmod 755 /bin/rclone && \
    rm -rf /tmp/rclone && \
#------------------------------------------------------------------------------
# clean
#------------------------------------------------------------------------------
    apt remove -y sqlite3 curl wget unzip
    # && \
#    apt purge -y && \
#    apt autoremove -y && \
#    apt autoclean -y && \    
#------------------------------------------------------------------------------
# Populate root file system:
#------------------------------------------------------------------------------
COPY rootfs /
#------------------------------------------------------------------------------
# Make ENTRYPOINT executable 
#------------------------------------------------------------------------------
RUN chmod u+x /init
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
