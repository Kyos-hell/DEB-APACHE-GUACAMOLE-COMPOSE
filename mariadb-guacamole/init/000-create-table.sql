CREATE DATABASE IF NOT EXISTS guacamole_db;
CREATE USER IF NOT EXISTS 'guacamole_user'@'%' IDENTIFIED BY 'some_password';
GRANT ALL PRIVILEGES ON guacamole_db.* TO 'guacamole_user'@'%';
FLUSH PRIVILEGES;