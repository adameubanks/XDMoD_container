-- Create XDMoD database
CREATE DATABASE IF NOT EXISTS xdmod;

-- Create XDMoD user
CREATE USER IF NOT EXISTS 'xdmod'@'%' IDENTIFIED BY 'your_root_password';

-- Grant all privileges to XDMoD user
GRANT ALL PRIVILEGES ON xdmod.* TO 'xdmod'@'%';

-- Flush privileges
FLUSH PRIVILEGES;