#!/bin/bash

set -e

mkdir -p /var/run/{php,sshd,fail2ban}

exec /usr/bin/supervisord
