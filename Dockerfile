##################################################################
# Dockerfile to build environment for php developer (LEP stack)  #
# Based on Ubuntu 16.04                                          #
##################################################################

# Set the base image to Ubuntu
FROM ubuntu:16.04

# File Author / Maintainer
MAINTAINER Andreev Andrey

# Labels
LABEL org.labelschema.description="This is the image with 4 PHP versions and basic developers tools. It can be used as lightweight virtual machine for developers." \
      org.labelschema.docker.cmd="docker run --detach --name phpdevenv --restart always --hostname phpdevenv --net YOUR_CUSTOM_BRIDGE_NETWORK_NAME -p 40080:80 -p 40022:22 andyceo/phpdevenv:latest" \
      org.labelschema.name="phpdevenv" \
      org.labelschema.schema-version="1.0" \
      org.labelschema.vcs-url="https://github.com/andyceo/docker-phpdevenv" \
      org.labelschema.vendor="Ruware"

LABEL RUN /usr/bin/docker run -d --name phpdevenv --restart always --hostname phpdevenv --net docknet -p "80:80" -p "22:22" \${IMAGE}

# Set neccessary environment variables and declare variables for installing popular PHP extensions
ENV TERM xterm
ENV PHP_MODULES "amqp bcmath cli common curl fpm intl json ldap mbstring mcrypt mysql opcache readline soap sybase xml zip memcache redis imagick xdebug"
ENV PHP_MODULES71 "bcmath cli common curl fpm intl json ldap mbstring mcrypt mysql opcache readline soap sybase xml zip"
ENV GO_ARCHIVE_FILENAME go1.7.3.linux-amd64.tar.gz
ENV PIP_PACKAGES "ansible-lint pymysql python-telegram-bot peewee requests"
ENV PIP3_PACKAGES "pymysql python-telegram-bot peewee requests"

# Install all needed utilities
RUN echo "Starting main RUN section" && \

    # Add PPA repository for ansible
    echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu xenial main" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7BB9C367 && \

    # Add repository and repository key for nginx official repository
    echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 && \

    # Add repository and repository key for php PPA repository
    echo 'deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main' > /etc/apt/sources.list.d/php.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C && \

    # Prepare package manager for installing packages
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        ansible \
        aptitude \
        apt-utils \
        asr-manpages \
        build-essential \
        cmake \
        cron \
        curl \
        default-jre \
        denyhosts \
        dnsutils \
        drush \
        freebsd-manpages \
        funny-manpages \
        git \
        gmt-common \
        htop \
        imagemagick \
        iputils-arping \
        iputils-ping \
        libboost-all-dev \
        libffi-dev \
        libssl-dev \
        man2html \
        manpages \
        manpages-dev \
        mc \
        mysql-client \
        nano \
        net-tools \
        nginx \
        openssh-server \

        php5.6 `echo " $PHP_MODULES" | sed "s/ / php5.6-/g"` \
        php7.0 `echo " $PHP_MODULES" | sed "s/ / php7.0-/g"` \
        php7.1 `echo " $PHP_MODULES71" | sed "s/ / php7.1-/g"` \

        php-pear \
        phpunit \

        pwgen \
        python-dev \
        python-pika \
        python-pip \
        python3-pip \
        redis-tools \
        rsync \
        screen \
        software-properties-common \
        supervisor \
        telnet \
        tmux \
        ubuntu-standard \
        wget && \

    apt-get purge apache2 -y && \

    apt-get clean && rm -rf /tmp/* /var/tmp/* && \
    rm /etc/alternatives/php && ln -s /usr/bin/php7.1 /etc/alternatives/php && \

    # Composer
    curl -s https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \

    # Drush (drush from Ubuntu packages installed above)
    git clone https://github.com/drush-ops/drush.git /usr/local/share/drush && \
    composer install -d /usr/local/share/drush/ && \
    ln -s /usr/local/share/drush/drush /usr/local/bin/drush && \

    # PHPUnit
    curl https://phar.phpunit.de/phpunit.phar -LSso /usr/local/bin/phpunit && \
    chmod +x /usr/local/bin/phpunit && \

    # PHP-CS-Fixer
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

    # Installing some packages with pip (see environment variable PIP_PACKAGES)
    pip install `echo " $PIP_PACKAGES"` && \

    # Installing some packages with pip3 (see environment variable PIP3_PACKAGES)
    pip install `echo " $PIP3_PACKAGES"` && \

    # Installing Go binaries and add "/usr/local/go/bin" to the environment $PATH variable
    curl https://storage.googleapis.com/golang/$GO_ARCHIVE_FILENAME -LSso /usr/local/$GO_ARCHIVE_FILENAME && \
    tar -C /usr/local -xzf /usr/local/$GO_ARCHIVE_FILENAME && \
    rm /usr/local/$GO_ARCHIVE_FILENAME && \
    sed -i 's/^PATH="\(.*\)"$/PATH="\1:\/usr\/local\/go\/bin"/g' /etc/environment && \

    # Set locale for RU
    locale-gen ru_RU && \
    locale-gen ru_RU.UTF-8 && \
    update-locale && \

    # Remove unneeded packages
    apt-get purge apache2-bin apache2-data apache2-utils -y && \

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
