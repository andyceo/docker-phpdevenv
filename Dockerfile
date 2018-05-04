##################################################################
# Dockerfile to build environment for php developer (LEP stack)  #
# Based on Ubuntu 16.04                                          #
##################################################################

# Set the base image to Ubuntu
FROM ubuntu:16.04

# File Author / Maintainer
MAINTAINER Andreev Andrey

# Labels
LABEL org.labelschema.description="This is the image with several PHP versions (from official Ubuntu PPA), python libraries and other developers tools. It can be used as lightweight virtual machine for developers." \
      org.labelschema.docker.cmd="docker run --detach --name phpdevenv --restart always --hostname phpdevenv --net YOUR_CUSTOM_BRIDGE_NETWORK_NAME -p 40080:80 -p 40022:22 andyceo/phpdevenv:latest" \
      org.labelschema.name="phpdevenv" \
      org.labelschema.schema-version="1.0" \
      org.labelschema.vcs-url="https://github.com/andyceo/docker-phpdevenv" \
      org.labelschema.vendor="Ruware"

LABEL RUN /usr/bin/docker run -d --name phpdevenv --restart always --hostname phpdevenv --net docknet -p "80:80" -p "22:22" \${IMAGE}

# Set neccessary environment variables and declare variables for installing popular PHP extensions
ENV TERM xterm
ENV PHP_MODULES "amqp bcmath cli common curl dev fpm gd intl json ldap mbstring mcrypt mongodb mysql opcache pdo-sqlite readline soap sybase xml zip memcached redis imagick xdebug"
ENV GO_ARCHIVE_FILENAME go1.10.linux-amd64.tar.gz
ENV PIP_PACKAGES "ansible-lint autopager click fake-useragent flask jsonpatch influxdb ipython[notebook] matplotlib mongoengine nose numpy pandas peewee pika pymorphy2 pymysql pysocks python-telegram-bot requests scikit-learn scipy scrapely scrapy scrapy_fake_useragent scrapy_proxies stem sympy tabulate telethon user-agents"
ENV PYTHONIOENCODING "utf-8"

RUN echo "Prepare package manager for installing packages and add support for https protocol in apt manager" && \
    apt-get update && apt-get upgrade -yqq && \
    apt-get install -yqq aptitude apt-utils apt-transport-https ca-certificates openssl

RUN echo "Add all needed repositories (PPAs and others)" && \

    # Add PPA repository for ansible
    echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu xenial main" >> /etc/apt/sources.list.d/ansible.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7BB9C367 && \

    # Add repository and repository key for nginx official repository
    echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list.d/nginx.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 && \

    # Add repository and repository key for php PPA repository
    echo 'deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main' > /etc/apt/sources.list.d/php.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C && \

    # Add repository and repository key for tor official repository
    # we install it later with apt-get install tor deb.torproject.org-keyring
    echo 'deb http://deb.torproject.org/torproject.org xenial main' > /etc/apt/sources.list.d/tor.list && \
    apt-key adv --keyserver keys.gnupg.net --recv-keys A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 && \

    # Add key and repository for MongoDB
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 && \
    echo "deb [ arch=amd64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" > /etc/apt/sources.list.d/mongodb.list && \

    # Install sbt repository (For Scala)
    echo "deb https://dl.bintray.com/sbt/debian /" > /etc/apt/sources.list.d/sbt.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 && \

    # Prepare package manager for installing packages
    apt-get update && \
    apt-get upgrade -y

RUN echo "Install all needed basic utilities and packages" && \
    apt-get install -yqq \
        acl \
        ansible \
        asr-manpages \
        bc \
        build-essential \
        cmake \
        cron \
        curl \
        debconf-utils \
        deb.torproject.org-keyring \
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
        locales \
        man2html \
        manpages \
        manpages-dev \
        mc \
        memcached \
        mongodb-org \
        mysql-client \
        nano \
        net-tools \
        nginx \
        openjdk-8-source \
        openssh-server \
        pkg-config \
        privoxy \
        pwgen \
        redis-server \
        redis-sentinel \
        redis-tools \
        rsync \
        sbt \
        screen \
        shellcheck \
        software-properties-common \
        sqlite \
        sqlite-doc \
        sudo \
        supervisor \
        telnet \
        tmux \
        tor \
        # Package ubuntu-standard recommends plymouth package, that seems to be broken at the moment. So temporary disable it. And add @todo to further remove it or enable it back when it will be resolved.
#        ubuntu-standard \
        wget

# Add cryptocurrencies

RUN echo "Add cryptocurrencies repositories and nodes" && \
    # Add PPA repository for ethereum
    echo "deb http://ppa.launchpad.net/ethereum/ethereum/ubuntu xenial main" >> /etc/apt/sources.list.d/ethereum.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 923F6CA9 && \

    # Add repository for zcash
    wget -qO - https://apt.z.cash/zcash.asc | apt-key add - && \
    echo "deb https://apt.z.cash/ jessie main" | tee /etc/apt/sources.list.d/zcash.list && \

    # Install cryptocurrencies nodes
    apt-get update && \
    apt-get install -yqq \
      ethereum \
      zcash

#RUN echo "Install mysql server with root user creation" && \
#    echo 'mysql-server mysql-server-5.7/root_password password 123qwe' | debconf-set-selections && \
#    echo 'mysql-server mysql-server-5.7/root_password_again password 123qwe' | debconf-set-selections && \
#    apt-get install -yqq mysql-server-5.7

RUN echo "Install python packages" && \
    apt-get install -yqq \
        pylint \
        python-dev \
        python-pip \
        python3-pip && \

    # Upgrade pip with pip
    pip install -q --upgrade pip && \
    pip3 install -q --upgrade pip && \

    # Installing packages for python2 with pip (see environment variable PIP_PACKAGES)
    pip install -q `echo " $PIP_PACKAGES"` && \

    # Installing packages for python3 with pip3 (see environment variable PIP_PACKAGES)
    pip3 install -q `echo " $PIP_PACKAGES"`

RUN echo "Install all needed PHP utilities and packages" && \
    apt-get install -yqq \
        php5.6 `echo " $PHP_MODULES" | sed "s/ / php5.6-/g"` \
        php7.0 `echo " $PHP_MODULES" | sed "s/ / php7.0-/g"` \
        php7.1 `echo " $PHP_MODULES" | sed "s/ / php7.1-/g"` \
        php-pear \
        phpunit && \

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

    # NodeJS 8.x (will be LTS from October, 2017 approximately) and some popular modules
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g gulp && \
    npm install -g bower && \

    # Elastic Beats
    curl https://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
    echo "deb https://packages.elastic.co/beats/apt stable main" |  tee -a /etc/apt/sources.list.d/beats.list && \
    apt-get update && apt-get install filebeat && \

    # Installing Go binaries and add "/usr/local/go/bin" to the environment $PATH variable
    curl https://storage.googleapis.com/golang/$GO_ARCHIVE_FILENAME -LSso /usr/local/$GO_ARCHIVE_FILENAME && \
    tar -C /usr/local -xzf /usr/local/$GO_ARCHIVE_FILENAME && \
    rm /usr/local/$GO_ARCHIVE_FILENAME && \
    sed -i 's/^PATH="\(.*\)"$/PATH="\1:\/usr\/local\/go\/bin"/g' /etc/environment && \

    # Finalize mongodb installation (changing storage, see etc/mongod.conf)
    cp -al /var/lib/mongodb /root && \

    # Set locale for RU
    locale-gen ru_RU && \
    locale-gen ru_RU.UTF-8 && \
    update-locale && \

    # Remove unneeded packages
    apt-get purge apache2-bin apache2-data apache2-utils -y && \

    # Setup root user password to random password
    cat /dev/urandom | tr -dc _A-Z-a-z-0-9 | head -c20 | (echo -n "root:" && cat) | chpasswd

# We also must create directories for privelege separation for sshd: /var/run/sshd, and /var/run/php for php.
# We do so in entrypoint.sh, because /var/run can be mounted at temporary filesystem.

# Copy application configs
COPY etc /etc

# Create user directories for database storage and custom configuration
RUN mkdir /root/rootdirectories /root/databases

# Add symlinker.sh script
ADD https://raw.githubusercontent.com/andyceo/bash_scripts/master/symlinker.sh /

# Copy entrypoint to container
COPY entrypoint.sh /entrypoint.sh

# Expose ports
EXPOSE 22 80

ENTRYPOINT ["/entrypoint.sh"]
