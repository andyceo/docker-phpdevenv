#!/usr/bin/env bash

ROOTDIRECTORIES=${ROOTDIRECTORIES:-/root/rootdirectories/}

rsync -ahvz --stats $ROOTDIRECTORIES /

set -e

mkdir -p /var/run/php /var/run/sshd

exec /usr/bin/supervisord
