##################################################################
# Dockerfile to build environment for php developer (LEP stack)  #
# Based on Ubuntu 18.04                                          #
##################################################################

# Set the base image to Ubuntu
FROM ubuntu:18.04

# Labels
LABEL org.labelschema.description="This is the image with several PHP versions (from official Ubuntu PPA), python libraries and other developers tools. It can be used as lightweight virtual machine for developers." \
      org.labelschema.docker.cmd="docker run --detach --name phpdevenv --restart always --hostname phpdevenv --net YOUR_CUSTOM_BRIDGE_NETWORK_NAME -p 40080:80 -p 40022:22 andyceo/phpdevenv:latest" \
      org.labelschema.name="phpdevenv" \
      org.labelschema.schema-version="1.0" \
      org.labelschema.vcs-url="https://github.com/andyceo/docker-phpdevenv" \
      org.labelschema.vendor="Ruware" \
      maintainer="Andrey Andreev <andyceo@yandex.ru> (@andyceo)" \
      run="/usr/bin/docker run -d --name phpdevenv --restart always --hostname phpdevenv --net docknet -p 80:80 -p 22:22 ${IMAGE}"

# Set neccessary environment variables and declare variables for installing popular Python and PHP extensions
ENV DEBIAN_FRONTEND="noninteractive"
ENV TERM="xterm"
ENV PHP_MODULES="amqp bcmath cli common curl dev fpm gd intl json ldap mbstring mcrypt mongodb mysql opcache pdo-sqlite readline soap sybase xml zip memcached redis imagick xdebug"
ENV GO_ARCHIVE_FILENAME="go1.13.1.linux-amd64.tar.gz"
ENV PYTHONIOENCODING="utf-8"

RUN echo "Prepare package manager for installing packages and add support for https protocol in apt manager" && \
    apt-get update && apt-get upgrade -yqq && \
    apt-get install -yqq aptitude apt-utils apt-transport-https ca-certificates curl gnupg2 openssl

RUN echo "Add all needed repositories (PPAs and others)" && \

    # Add PPA repository for ansible
    echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu bionic main" >> /etc/apt/sources.list.d/ansible.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7BB9C367 && \

    # Add repository and repository key for nginx official repository
    echo "deb http://nginx.org/packages/ubuntu/ bionic nginx" >> /etc/apt/sources.list.d/nginx.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 && \

    # Add repository and repository key for php PPA repository
    echo 'deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main' > /etc/apt/sources.list.d/php.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E5267A6C && \

    # Add repository and repository key for tor official repository
    # @see https://www.torproject.org/docs/debian.html.en
    # we install it later with apt-get install tor deb.torproject.org-keyring
    echo 'deb https://deb.torproject.org/torproject.org bionic main' > /etc/apt/sources.list.d/tor.list && \
    curl -s https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | tac | tac | apt-key add - && \

    # Add key and repository for MongoDB
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 && \
    echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" > /etc/apt/sources.list.d/mongodb.list && \

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
        apache2 \
        apache2-utils \
        bc \
        build-essential \
        cmake \
        cron \
        debconf-utils \
        deb.torproject.org-keyring \
        default-jre \
        denyhosts \
        dnsutils \
        freebsd-manpages \
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
        netcat \
        nginx \
        nmap \
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
        stress \
        sudo \
        supervisor \
        telnet \
        tmux \
        tor \
        ubuntu-standard \
        wget

RUN echo "Install Apache 2 on non-standard port" && \
    sed -i -e 's/80/81/g' /etc/apache2/ports.conf

RUN echo "Install all LaTeX utilities and packages" && \
    apt-get install -yqq \
        cm-super \
        texlive \
        texlive-base \
        texlive-binaries \
        texlive-fonts-recommended \
        texlive-science \
        texlive-latex-base \
        texlive-latex-extra \
        texlive-latex-recommended \
        texlive-full

# Add cryptocurrencies

RUN echo "Add cryptocurrencies repositories and nodes" && \
    # Add PPA repository for bitcoin
    echo "deb http://ppa.launchpad.net/bitcoin/bitcoin/ubuntu bionic main" >> /etc/apt/sources.list.d/bitcoin.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C70EF1F0305A1ADB9986DBD8D46F45428842CE5E && \

    # Add PPA repository for ethereum
    echo "deb http://ppa.launchpad.net/ethereum/ethereum/ubuntu bionic main" >> /etc/apt/sources.list.d/ethereum.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 923F6CA9 && \

    # Add repository for zcash
    wget -qO - https://apt.z.cash/zcash.asc | apt-key add - && \
    echo "deb https://apt.z.cash/ jessie main" | tee /etc/apt/sources.list.d/zcash.list && \

    # Install cryptocurrencies nodes
    apt-get update && \
    apt-get install -yqq \
      bitcoind \
      ethereum \
      zcash

#RUN echo "Install mysql server with root user creation" && \
#    echo 'mysql-server mysql-server-5.7/root_password password 123qwe' | debconf-set-selections && \
#    echo 'mysql-server mysql-server-5.7/root_password_again password 123qwe' | debconf-set-selections && \
#    apt-get install -yqq mysql-server-5.7

RUN echo "Install python packages" && \
    apt-get install -yqq \
        pylint \
        python3-dev \
        python3-pip && \
    pip3 install -q --upgrade pip

# Installing packages for python3 with pip3
COPY python-requirements.txt /tmp
RUN apt-get install -yqq libgmp3-dev && \
    pip3 install -r /tmp/python-requirements.txt && \
    rm /tmp/python-requirements.txt

RUN echo "Install all needed PHP utilities and packages" && \
    apt-get install -yqq \
        php5.6 `echo " $PHP_MODULES" | sed "s/ / php5.6-/g"` \
        php7.0 `echo " $PHP_MODULES" | sed "s/ / php7.0-/g"` \
        php7.1 `echo " $PHP_MODULES" | sed "s/ / php7.1-/g"` \
        php-pear \
        phpunit && \

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
    chmod a+x /usr/local/bin/codecept

RUN echo "Finalize all other packages install" && \
    # NodeJS and some popular modules
    curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g gulp && \
    npm install -g bower && \

    # Elastic Beats
    curl https://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - && \
    echo "deb https://packages.elastic.co/beats/apt stable main" |  tee -a /etc/apt/sources.list.d/beats.list && \
    apt-get update && apt-get install filebeat && \

    # Installing Go binaries and add "/usr/local/go/bin" to the environment $PATH variable
    curl https://dl.google.com/go/$GO_ARCHIVE_FILENAME -LSso /usr/local/$GO_ARCHIVE_FILENAME && \
    tar -C /usr/local -xzf /usr/local/$GO_ARCHIVE_FILENAME && \
    rm /usr/local/$GO_ARCHIVE_FILENAME && \
    sed -i 's/^PATH="\(.*\)"$/PATH="\1:\/usr\/local\/go\/bin"/g' /etc/environment && \

    # Finalize mongodb installation (changing storage, see etc/mongod.conf)
    cp -al /var/lib/mongodb /root && \

    # Set locale for US and RU
    locale-gen en_US en_US.UTF-8 && \
    locale-gen ru_RU ru_RU.UTF-8 && \
    update-locale && \

    # Setup root user password to random password
    cat /dev/urandom | tr -dc _A-Z-a-z-0-9 | head -c20 | (echo -n "root:" && cat) | chpasswd

# We also must create directories for privelege separation for sshd: /var/run/sshd, and /var/run/php for php.
# We do so in entrypoint.sh, because /var/run can be mounted at temporary filesystem.

# Copy application configs
COPY etc /etc

# Create user directories for database storage and custom configuration
RUN mkdir /root/data /root/databases /root/rootdirectories

# Add symlinker.sh script
ADD https://raw.githubusercontent.com/andyceo/bash_scripts/master/symlinker.sh /usr/local/bin

# Add rsyncdir.sh script
ADD https://raw.githubusercontent.com/andyceo/bash_scripts/master/rsyncdir/rsyncdir.sh /usr/local/bin

# Copy entrypoint to container
COPY entrypoint.sh /entrypoint.sh

# Expose ports
EXPOSE 22 80

ENTRYPOINT ["/entrypoint.sh"]

# Set some variables to it's default values
ENV DEBIAN_FRONTEND=dialog

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=5 \
  CMD supervisorctl status || exit 1
