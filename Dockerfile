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
    CRON_TIMEOUT="*/10 * * * *" \
    PHP_TIMEZONE="UTC" \
    PHP_MEMORY_LIMIT="512M" \
    LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8"
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
                    php-bcmath \
                    php-gd \
                    php-imap \
                    php-soap \
                    php-tidy \
                    php-xmlrpc && \
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
# /data/htdocs/torrents - for download .torrent files
#------------------------------------------------------------------------------
VOLUME ["/data/htdocs/db", "/data/htdocs/torrents" ]
WORKDIR /
#------------------------------------------------------------------------------
# port 80 for direct TorMon; port 2000 for access through http-knocking:
#------------------------------------------------------------------------------
EXPOSE 80
ENTRYPOINT ["/init"]
