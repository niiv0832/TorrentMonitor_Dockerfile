#------------------------------------------------------------------------------
# Set the base image for subsequent instructions:
#------------------------------------------------------------------------------
FROM node:buster-slim
MAINTAINER nniiv0832 <dockerhubme-tormon@yahoo.com>
#------------------------------------------------------------------------------
# Environment variables:
#------------------------------------------------------------------------------
ENV VERSION="1.8.6" \
    RELEASE_DATE="08.07.2021" \
    CRON_TIMEOUT="*/10 * * * *" \
    PHP_TIMEZONE="UTC" \
    PHP_MEMORY_LIMIT="512M" 
    #\
    #LC_ALL="en_US.UTF-8" \
    #LANG="en_US.UTF-8" \
    #LANGUAGE="en_US.UTF-8"
#------------------------------------------------------------------------------
# Install:
#------------------------------------------------------------------------------
RUN apt-get update -y && \
#------------------------------------------------------------------------------
# Install: nginx and php
#-----------------------------------------------------------------------------    
    apt-get install -y --no-install-recommends \
                    bash \
                    cron \
                    nginx \
                    wget \
                    unzip \
                    sqlite3 \
                    locales \
                    ca-certificates \
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
                    php-zip \ 
#                                      
                    php-bcmath \
                    php-gd \
                    php-imap \
                    php-soap \
                    php-tidy \
                    php-xmlrpc && \
#------------------------------------------------------------------------------
# Install: TorMon v1.8.6
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
# Install: http-knocking v0.8.4
#------------------------------------------------------------------------------  
    /usr/local/bin/npm install -g http-knocking && \
#------------------------------------------------------------------------------
# Install: rclone v1.55.1
#------------------------------------------------------------------------------     
    mkdir -p /tmp/rclone  && \
    cd /tmp/rclone && \
    wget -q --no-check-certificate https://downloads.rclone.org/rclone-current-linux-amd64.zip  && \
    unzip rclone-current-linux-amd64.zip && \
    cd /tmp/rclone/rclone-*-linux-amd64 && \
    cp rclone /bin/ && \
    chown root:root /bin/rclone && \
    chmod 755 /bin/rclone && \
    rm -rf /tmp/rclone && \
#------------------------------------------------------------------------------
# Configuration Locale
#------------------------------------------------------------------------------
    sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen && \
    locale-gen && \
    echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc && \
    echo "export LANG=en_US.UTF-8" >> ~/.bashrc && \
    echo "export LANGUAGE=en_US.UTF-8" >> ~/.bashrc && \
#    source ~/.bashrc && \
    . ~/.bashrc && \
#------------------------------------------------------------------------------
# clean
#------------------------------------------------------------------------------
    apt-get remove -y sqlite3 wget unzip && \
    apt-get purge -y && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/*
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
# port 2000 for access through http-knocking:
#------------------------------------------------------------------------------
EXPOSE 2000
ENTRYPOINT ["/init"]
