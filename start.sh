#!/bin/bash

set -e

echo "======================================"
echo "Starting Chamilo"
echo "PORT=${PORT}"
echo "======================================"

# Apache laten luisteren op Railway PORT
sed -i "s/^Listen .*/Listen ${PORT}/" /etc/apache2/ports.conf

# VirtualHost aanpassen aan Railway PORT
sed -i \
    "s#<VirtualHost \*:[^>]*>#<VirtualHost *:${PORT}>#" \
    /etc/apache2/sites-available/chamilo.conf

echo "Apache configuration:"
apachectl -S

echo "Starting Apache..."

exec apachectl -D FOREGROUND
