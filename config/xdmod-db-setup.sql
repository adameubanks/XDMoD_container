-- Create XDMoD database
CREATE DATABASE IF NOT EXISTS xdmod;

-- Create XDMoD user
CREATE USER IF NOT EXISTS 'xdmod'@'localhost' IDENTIFIED BY 'xdmod_password';

-- Grant all privileges to XDMoD user
GRANT ALL PRIVILEGES ON xdmod.* TO 'xdmod'@'localhost';

-- Flush privileges
FLUSH PRIVILEGES;
