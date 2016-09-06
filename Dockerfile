##################################################################
# Dockerfile to build environment for php developer (LEP stack)  #
# Based on Ubuntu 16.04                                          #
##################################################################

# Set the base image to Ubuntu
FROM ubuntu:16.04

# File Author / Maintainer
MAINTAINER Andreev Andrey

# Set neccessary environment variables
ENV TERM xterm

# Install all needed utilities
RUN echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 && \
    echo 'deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main' > /etc/apt/sources.list.d/php.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C && \
    apt-get update && \
    apt-get upgrade -y && \
    export PHP_MODULES="bcmath cli common curl fpm intl json ldap mbstring mcrypt mysql opcache readline soap sybase xml zip memcache redis imagick xdebug" && \
    export PHP_MODULES71="bcmath cli common curl fpm intl json ldap mbstring mcrypt mysql opcache readline soap sybase xml zip" && \
    apt-get install -y \
        apt-utils \
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

        php5.5 `echo " $PHP_MODULES" | sed "s/ / php5.5-/g"` \
        php5.6 `echo " $PHP_MODULES" | sed "s/ / php5.6-/g"` \
        php7.0 `echo " $PHP_MODULES" | sed "s/ / php7.0-/g"` \
        php7.1 `echo " $PHP_MODULES71" | sed "s/ / php7.1-/g"` \

        phpunit \
        php-pear \

        redis-tools \
        rsync \
        screen \
        supervisor \
        telnet \
        tmux \
        wget && \

    apt-get purge apache2 -y && \

    apt-get clean && rm -rf /tmp/* /var/tmp/* && \
    rm /etc/alternatives/php && ln -s /usr/bin/php5.5 /etc/alternatives/php && \

    # Composer
    curl -s https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \

    # PHPUnit
    curl https://phar.phpunit.de/phpunit.phar -LSso /usr/local/bin/phpunit && \
    chmod +x /usr/local/bin/phpunit && \

    #PHP-CS-Fixer
    curl http://get.sensiolabs.org/php-cs-fixer.phar -LSso /usr/local/bin/php-cs-fixer && \
    chmod +x /usr/local/bin/php-cs-fixer && \

    # Codeception
    curl -LsS http://codeception.com/codecept.phar -o /usr/local/bin/codecept && \
    chmod a+x /usr/local/bin/codecept && \

    # NodeJS 6.x
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g gulp && \
    npm install -g bower && \

    # Elastic Beats
    curl https://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
    echo "deb https://packages.elastic.co/beats/apt stable main" |  tee -a /etc/apt/sources.list.d/beats.list && \
    apt-get update && apt-get install filebeat && \

    locale-gen ru_RU && \
    locale-gen ru_RU.UTF-8 && \
    update-locale && \

    # Setup root user password
    echo 'root:123qwe' | chpasswd

# We also must create directories for privelege separation for sshd: /var/run/sshd, and /var/run/php for php.
# We do so in entrypoint.sh, because /var/run can be mounted at temporary filesystem.

# Copy application configs
COPY etc /etc

# Copy entrypoint to container
COPY entrypoint.sh /entrypoint.sh

# Expose ports
EXPOSE 22 80

ENTRYPOINT ["/entrypoint.sh"]
