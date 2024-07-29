#!/bin/bash

/usr/bin/mysqld_safe --datadir='/var/lib/mysql' &

# Wait for MariaDB to start
echo "Waiting for MariaDB to start..."
until mysqladmin ping -h "$DB_HOST" --silent; do
  >&2 echo "MariaDB is unavailable - sleeping"
  sleep 1
done
echo "MariaDB started successfully."

# Initialize the XDMoD database if it doesn't exist
if [ ! -d "/var/lib/mysql/xdmod" ]; then
    echo "Initializing XDMoD database..."
    mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" < xdmod-db-setup.sql
    # /usr/bin/xdmod-setup
fi

mkdir -p /etc/pki/tls/certs
mkdir -p /etc/pki/tls/private

openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -keyout /etc/pki/tls/private/localhost.key \
    -out /etc/pki/tls/certs/localhost.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=localhost"

# Configure Apache to serve XDMoD
echo "Configuring Apache for XDMoD..."
sed -i 's/#ServerName www.example.com/ServerName localhost/' /etc/httpd/conf/httpd.conf
echo "Include conf.d/xdmod.conf" >> /etc/httpd/conf/httpd.conf

# Start Apache
echo "Starting Apache..."
httpd -D FOREGROUND