##################################################################
# Dockerfile to build environment for php developer (LEP stack)  #
# Based on Ubuntu 14.04                                          #
##################################################################

# Set the base image to Ubuntu
FROM ubuntu:14.04

# File Author / Maintainer
MAINTAINER Andreev Andrey

# Set neccessary environment variables
ENV DOCKER_IMAGE_NAME phpdevenv
ENV DOCKER_IMAGE_VERSION 1.0
ENV TERM xterm

# Install all needed utilities
RUN apt-get update && \
    apt-get install -y \
        aptitude \
        asr-manpages \
        curl \
        default-jre \
        drush \
        funny-manpages \
        git \
        gmt-manpages \
        htop \
        imagemagick \
        libssh2-php \
        man2html \
        manpages \
        manpages-dev \
        mc \
        nano \
        net-tools \
        nginx \
        openssh-server \
        php5-cli \
        php5-curl \
        php5-fpm \
        php5-imagick \
        php5-mcrypt \
        php5-memcache \
        php5-mysql \
        php5-xdebug \
        php-pear \
        rsync \
        screen \
        supervisor \
        telnet \
        tmux \
        wget && \
    apt-get clean && rm -rf /tmp/* /var/tmp/* && \
    curl -s https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    locale-gen ru_RU && \
    locale-gen ru_RU.UTF-8 && \
    update-locale

# Setup root user password
RUN echo 'root:123qwe' | chpasswd

# Create directory for privelege separation for sshd
RUN mkdir /var/run/sshd

# Copy application configs
COPY config/supervisord/supervisord.conf /etc/supervisord.conf
COPY config/ssh/sshd_config /etc/ssh/sshd_config
COPY config/php/www.conf /etc/php5/fpm/pool.d/www.conf
COPY config/xdebug/xdebug.ini /etc/php5/mods-available/xdebug.ini

# Copy entrypoint to container
ADD start.sh /start.sh

# Expose ports
EXPOSE 22 80

# Set the volume work dir
VOLUME ["/var/www"]

# Set the volume for logs
VOLUME ["/var/log"]

ENTRYPOINT ["/start.sh"]
