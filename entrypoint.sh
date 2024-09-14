#!/bin/bash

# Wait for the database to be ready
echo "Waiting for MariaDB to start..."
until mysqladmin ping -h "$DB_HOST" --silent; do
  >&2 echo "MariaDB is unavailable - sleeping"
  sleep 1
done
echo "MariaDB started successfully."

# Configure Apache for XDMoD
echo "Configuring Apache for XDMoD..."
sed -i 's/#ServerName www.example.com/ServerName localhost/' /etc/httpd/conf/httpd.conf
echo "Include conf.d/xdmod.conf" >> /etc/httpd/conf/httpd.conf

# Start Apache
echo "Starting Apache..."
httpd -D FOREGROUND
