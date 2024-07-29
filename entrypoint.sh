#!/bin/bash
set -e

# Check and set permissions for MySQL data directory
echo "Checking permissions for /var/lib/mysql..."
chown -R mysql:mysql /var/lib/mysql
chmod -R 755 /var/lib/mysql

# Initialize MariaDB database directory if needed
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB
echo "Starting MariaDB..."
/usr/bin/mysqld_safe --datadir='/var/lib/mysql' &

# Wait for MariaDB to start
echo "Waiting for MariaDB to start..."
until mysqladmin ping -h "$DB_HOST" --silent; do
  >&2 echo "MariaDB is unavailable - sleeping"
  sleep 1
done
echo "MariaDB started successfully."

# Set the root password if not already set
echo "Setting root password..."
# mysql -h "$DB_HOST" -P "$DB_PORT" -u root -e "ALTER USER 'root'@'%' IDENTIFIED BY '$DB_PASSWORD'; FLUSH PRIVILEGES;"

# Initialize the XDMoD database if it doesn't exist
if [ ! -d "/var/lib/mysql/xdmod" ]; then
    echo "Initializing XDMoD database..."
    mysql -h "$DB_HOST" -P "$DB_PORT" -u root -p"$DB_PASSWORD" < xdmod-db-setup.sql
    # /usr/bin/xdmod-setup
fi

mkdir -p /etc/pki/tls/certs
mkdir -p /etc/pki/tls/private

openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -keyout /etc/pki/tls/private/localhost.key \
    -out /etc/pki/tls/certs/localhost.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=localhost"

# Start Apache
echo "Starting Apache..."
httpd -D FOREGROUND
