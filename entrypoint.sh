#!/bin/bash

set -e

mkdir -p /var/run/php /var/run/sshd

exec /usr/bin/supervisord
