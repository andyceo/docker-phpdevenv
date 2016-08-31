##################################################################
# Dockerfile to build environment for php developer (LEP stack)  #
# Based on Ubuntu 16.04                                          #
##################################################################

# Set the base image to Ubuntu
FROM ubuntu:16.04

# File Author / Maintainer
MAINTAINER Andreev Andrey

# Set neccessary environment variables
ENV DOCKER_IMAGE_NAME phpdevenv
ENV DOCKER_IMAGE_VERSION 1.3
ENV TERM xterm

# Install all needed utilities
RUN echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 && \
    echo 'deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main' > /etc/apt/sources.list.d/php.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        aptitude \
        asr-manpages \
        curl \
        default-jre \
        freebsd-manpages \
        drush \
        funny-manpages \
        git \
        gmt-common \
        htop \
        imagemagick \
        man2html \
        manpages \
        manpages-dev \
        mc \
        nano \
        net-tools \
        nginx \
        openssh-server \

        php5.5 \
        php5.5-curl \
        php5.5-fpm \
        php5.5-intl \
        php5.5-json \
        php5.5-ldap \
        php5.5-mbstring \
        php5.5-mcrypt \
        php5.5-mysql \
        php5.5-opcache \
        php5.5-soap \
        php5.5-sybase \
        php5.5-xml \
        php5.5-zip \
        php5.5-memcache \
        php5.5-redis \
        php5.5-imagick \
        php5.5-xdebug \

        php7.0 \
        php7.0-bcmath \
        php7.0-cli \
        php7.0-common \
        php7.0-curl \
        php7.0-fpm \
        php7.0-intl \
        php7.0-json \
        php7.0-ldap \
        php7.0-mbstring \
        php7.0-mcrypt \
        php7.0-mysql \
        php7.0-opcache \
        php7.0-readline \
        php7.0-soap \
        php7.0-sybase \
        php7.0-xml \
        php7.0-zip \
        php7.0-memcache \
        php7.0-redis \
        php7.0-imagick \
        php7.0-xdebug \

        phpunit \
        php-pear \

        redis-tools \
        rsync \
        screen \
        supervisor \
        telnet \
        tmux \
        wget && \

    apt-get purge apache2 && \

    apt-get clean && rm -rf /tmp/* /var/tmp/* && \
    rm /etc/alternatives/php && ln -s /usr/bin/php5.5 /etc/alternatives/php && \

    curl -s https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \

    curl https://phar.phpunit.de/phpunit.phar -LSso /usr/local/bin/phpunit && \
    chmod +x /usr/local/bin/phpunit && \

    curl http://get.sensiolabs.org/php-cs-fixer.phar -LSso /usr/local/bin/php-cs-fixer && \
    chmod +x /usr/local/bin/php-cs-fixer && \

    curl -LsS http://codeception.com/codecept.phar -o /usr/local/bin/codecept && \
    chmod a+x /usr/local/bin/codecept && \

    locale-gen ru_RU && \
    locale-gen ru_RU.UTF-8 && \
    update-locale

# Setup root user password
RUN echo 'root:123qwe' | chpasswd

# Create directory for privelege separation for sshd
RUN mkdir /var/run/sshd

# Copy application configs
COPY etc /etc

# Copy entrypoint to container
COPY entrypoint.sh /entrypoint.sh

# Expose ports
EXPOSE 22 80

ENTRYPOINT ["/entrypoint.sh"]
