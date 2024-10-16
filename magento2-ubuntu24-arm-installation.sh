#!bin/bash

MAGE_URL="ec2.compute-1.amazonaws.com"
PHP_VERSION="8.1"
OPENSEARCH_VERSION="2.11.1"

magento2conf="upstream fastcgi_backend {
  server  unix:/run/php/php$PHP_VERSION-fpm.sock;
}

server {
  listen 80;
  server_name $MAGE_URL;
  set \$MAGE_ROOT /var/www/html/magento;
  include /var/www/html/magento/nginx.conf.sample;
}"

sudo apt-get update

# Setup NGINX
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
sudo apt install unzip -y

# Setup PHP
sudo apt install -y software-properties-common 
yes | sudo add-apt-repository ppa:ondrej/php
sudo apt-get install php$PHP_VERSION php$PHP_VERSION-dev php$PHP_VERSION-fpm php$PHP_VERSION-bcmath php$PHP_VERSION-intl php$PHP_VERSION-soap php$PHP_VERSION-zip php$PHP_VERSION-curl php$PHP_VERSION-mbstring php$PHP_VERSION-mysql php$PHP_VERSION-gd php$PHP_VERSION-xml --no-install-recommends  -y
php -v

# Configure PHP
sudo sed -i 's/^\(max_execution_time = \)[0-9]*/\17200/' /etc/php/$PHP_VERSION/fpm/php.ini 
sudo sed -i 's/^\(max_input_time = \)[0-9]*/\17200/' /etc/php/$PHP_VERSION/fpm/php.ini 
sudo sed -i 's/^\(memory_limit = \)[0-9]*M/\12048M/' /etc/php/$PHP_VERSION/fpm/php.ini 
sudo sed -i 's/^\(post_max_size = \)[0-9]*M/\164M/' /etc/php/$PHP_VERSION/fpm/php.ini 
sudo sed -i 's/^\(upload_max_filesize = \)[0-9]*M/\164M/' /etc/php/$PHP_VERSION/fpm/php.ini 
sudo sed -i 's/expose_php = On/expose_php = Off/' /etc/php/$PHP_VERSION/fpm/php.ini 
sudo sed -i 's/;realpath_cache_size = 16k/realpath_cache_size = 512k/' /etc/php/$PHP_VERSION/fpm/php.ini 
sudo sed -i 's/;realpath_cache_ttl = 120/realpath_cache_ttl = 86400/' /etc/php/$PHP_VERSION/fpm/php.ini 
sudo sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php/$PHP_VERSION/fpm/php.ini 
sudo sed -i 's/;max_input_vars = 1000/max_input_vars = 50000/' /etc/php/$PHP_VERSION/fpm/php.ini 
sudo sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 28800/' /etc/php/$PHP_VERSION/fpm/php.ini 
sudo sed -i 's/mysql.allow_persistent = On/mysql.allow_persistent = Off/' /etc/php/$PHP_VERSION/fpm/php.ini 
sudo sed -i 's/mysqli.allow_persistent = On/mysqli.allow_persistent = Off/' /etc/php/$PHP_VERSION/fpm/php.ini

# Configure Opcache
sudo bash -c "cat > /etc/php/$PHP_VERSION/fpm/conf.d/10-opcache.ini <<END
zend_extension=opcache.so
opcache.enable = 1
opcache.enable_cli = 0
opcache.memory_consumption = 356
opcache.interned_strings_buffer = 4
opcache.max_accelerated_files = 100000
opcache.max_wasted_percentage = 15
opcache.use_cwd = 1
opcache.validate_timestamps = 0
;opcache.revalidate_freq = 2
;opcache.validate_permission= 1
;opcache.validate_root= 1
opcache.file_update_protection = 2
opcache.revalidate_path = 0
opcache.save_comments = 1
opcache.load_comments = 1
opcache.fast_shutdown = 1
opcache.enable_file_override = 0
opcache.optimization_level = 0xffffffff
opcache.inherited_hack = 1
opcache.max_file_size = 0
opcache.consistency_checks = 0
opcache.force_restart_timeout = 60
opcache.log_verbosity_level = 1
opcache.protect_memory = 0
END"

sudo systemctl start php$PHP_VERSION-fpm.service
sudo systemctl enable php$PHP_VERSION-fpm.service
sudo systemctl status php$PHP_VERSION-fpm.service --no-pager
sudo systemctl restart php$PHP_VERSION-fpm.service

#Setup MySQL
sudo apt install mysql-server -y 
sudo systemctl start mysql
sudo systemctl enable mysql
sudo mysql -e "CREATE DATABASE magento; CREATE USER 'magento'@'localhost' IDENTIFIED BY 'magento'; GRANT ALL ON magento.* TO 'magento'@'localhost'; FLUSH PRIVILEGES;"
sudo mysql -e "show databases"
sudo mysql -e "SET GLOBAL log_bin_trust_function_creators = 1;"
sudo mysql -e "select version()"

#Setup OpenSearch
curl -o- https://artifacts.opensearch.org/publickeys/opensearch.pgp | sudo gpg --dearmor --batch --yes -o /usr/share/keyrings/opensearch-keyring
echo "deb [signed-by=/usr/share/keyrings/opensearch-keyring] https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/apt stable main" | sudo tee /etc/apt/sources.list.d/opensearch-2.x.list
sudo apt update
sudo apt list -a opensearch
sudo apt install opensearch=$OPENSEARCH_VERSION
# apt purge opensearch -y 
sudo bash -c "echo \"plugins.security.disabled: true\" >> /etc/opensearch/opensearch.yml"
sudo cat /etc/opensearch/opensearch.yml
sudo systemctl enable --now opensearch
sudo systemctl restart opensearch
sudo systemctl status opensearch
# logs : cat  /etc/opensearch/opensearch.yml
curl -X GET localhost:9200

#Setup Redis
sudo apt install redis -y
sudo systemctl restart redis.service
sudo systemctl status redis

#Setup Composer
curl -sS https://getcomposer.org/installer -o composer-setup.php
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
composer -V

sudo mkdir /var/www/html/magento
sudo chmod -R 755 /var/www/html/magento/

composer config --global http-basic.repo.magento.com 5310458a34d580de1700dfe826ff19a1 255059b03eb9d30604d5ef52fca7465d
composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition /var/www/html/magento

cd /var/www/html/magento/

bin/magento setup:install --base-url=http://$MAGE_URL --db-host=localhost --db-name=magento --db-user=magento --db-password=magento --admin-firstname=Magento --admin-lastname=Admin --admin-email=admin@yourdomain.com --admin-user=admin --admin-password=admin123 --language=en_US --currency=USD --timezone=America/Chicago --use-rewrites=1 --search-engine=opensearch

yes | /var/www/html/magento/bin/magento setup:config:set --cache-backend=redis --cache-backend-redis-server=127.0.0.1 --cache-backend-redis-db=0
yes | /var/www/html/magento/bin/magento setup:config:set --page-cache=redis --page-cache-redis-server=127.0.0.1 --page-cache-redis-db=1
yes | /var/www/html/magento/bin/magento setup:config:set --session-save=redis --session-save-redis-host=127.0.0.1 --session-save-redis-log-level=4 --session-save-redis-db=2

php bin/magento module:disable Magento_AdminAdobeImsTwoFactorAuth
php bin/magento module:disable Magento_TwoFactorAuth

sudo bash -c "echo '$magento2conf' > /etc/nginx/conf.d/magento.conf"
sudo nginx -t
sudo service nginx restart

sudo chmod -R 777 /var/www/html/magento/*

sudo chown -R www-data:www-data /var/www/html/magento
sudo find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +

curl http://$MAGE_URL

tail -n 20 /var/log/nginx/error.log 

