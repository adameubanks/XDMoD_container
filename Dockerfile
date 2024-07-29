# Use Rocky Linux 8.9 as the base image
FROM rockylinux:8.9

# Install necessary tools and libraries
RUN dnf -y update && \
    dnf -y install epel-release && \
    dnf -y install --allowerasing \
        sudo \
        wget \
        gmp-devel \
        cronie \
        logrotate \
        coreutils \
        shadow-utils \
        tar \
        xz \
        bzip2 \
        gzip \
        zip \
        jq \
        libreoffice \
        chromium-headless \
        librsvg2-tools \
        make \
        php-devel \
        php-mysqli \
        php-pear

# Install MDB2 and its MySQLi driver using PEAR
RUN pear upgrade-all && \
    pear channel-update pear.php.net && \
    pear install MDB2 && \
    pear install MDB2_Driver_mysqli

# Install MariaDB
RUN dnf -y install --allowerasing mariadb-server mariadb

# Remove or rename GSSAPI plugin files if necessary
RUN rm -f /usr/lib64/mysql/plugin/gssapi.so && \
    rm -f /usr/lib64/mysql/plugin/auth_gssapi.so && \
    # Remove any configuration files that may load GSSAPI plugin
    sed -i '/plugin-load.*gssapi/d' /etc/my.cnf /etc/my.cnf.d/*

# Enable the appropriate Node.js module stream
RUN dnf module -y enable nodejs:16

# Download and install XDMoD from RPM
ARG XDMOD_VERSION=10.5.0-1.0
ARG XDMOD_RPM_URL=https://github.com/ubccr/xdmod/releases/download/v${XDMOD_VERSION}/xdmod-${XDMOD_VERSION}.el8.noarch.rpm
RUN wget ${XDMOD_RPM_URL} -O /tmp/xdmod.rpm && \
    dnf -y install /tmp/xdmod.rpm --skip-broken && \
    rm -f /tmp/xdmod.rpm

# Copy the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Copy the SQL setup file to the Docker image
COPY /config/xdmod-db-setup.sql xdmod-db-setup.sql

# XDMoD uses an Apache virtual host on port 8080
EXPOSE 8080/tcp

# Ensure mount points/directories exist for the data ingest pipeline
RUN mkdir --parents --mode=0755 /var/lib/XDMoD-ingest-queue/in && \
    mkdir --parents --mode=0755 /var/lib/XDMoD-ingest-queue/out && \
    mkdir --parents --mode=0755 /var/lib/XDMoD-ingest-queue/error && \
    mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql && chmod -R 755 /var/lib/mysql

# Set the entrypoint to the entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
