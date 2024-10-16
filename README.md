# Magento Commerce Cloud to Ubuntu Server/ AWS Linux 2 (Centos 7) / Azure Centos 8.2/ Oracle Linux 8Installation migration tool with ARM Graviton2/Ampere instances support  

Fast Run (AWS Linux 2, Centos 8, Oracle Linux 8):
```
wget https://github.com/Genaker/Magento-AWS-Linux-2-Installation/archive/refs/heads/master.zip && unzip master.zip && cd ./Magento-AWS-Linux-2-Installation-master/ && sudo bash ./install-all.sh

#Some Linuxes require wget and unzip 
sudo yum install wget unzip -y
# or 
sudo yum install wget unzip -y && wget https://github.com/Genaker/Magento-AWS-Linux-2-Installation/archive/refs/heads/master.zip && unzip master.zip && cd ./Magento-AWS-Linux-2-Installation-master/ && sudo bash ./install-all.sh

```
or short form using **install script**:
```
wget https://raw.githubusercontent.com/Genaker/Magento-AWS-Linux-2-Installation/master/install-script.sh
sudo bash ./install-script.sh
```
# Magento 2 Ubuntu Server 24 ARM installation 

Script: https://github.com/Genaker/Magento-Linux-Installation/blob/master/magento2-ubuntu24-arm-installation.sh

# To Change Domain 
Point DNS to IP or Load Blancer and:

```
mysql -h 127.0.0.0 -u {user} -p{password} magento -e'UPDATE core_config_data set value = "http://{{magento.url}}/" where path like "web/%/base_url"'
bin/magento c:c

# or 
bin/magento config:set web/unsecure/base_url "http(s)://18.222.***.***/"
bin/magento config:set web/secure/use_in_frontend  1(0)
bin/magento config:set web/secure/use_in_adminhtml  1(0)

```

If you have any questions or issues feel free to send me an email – yegorshytikov@gmail.com

Every merchant wants to have a faster website and pay less for hosting. Magento Commerce Cloud works only for small projects without traffic. If you are having 2+ requests per second you will safer with Magento cloud, because it was designed not for Magento. It is the Platform.SH hosting for Drupal. And really it is not a real cloud it just uses Amazon Web Services to buy instances. The best way to improve performance and price it is to buy services directly from AWS without any gasket. Also, Magento Cloud also supports only Commerce/Enterprise clients, not the Open Source free version. 
This Open Source project simplifies the creation, maintenance, validation, sharing, and deployment of the Magento 2 and LEMP stack installation.
LEMP (Linux, NGINX, MySQL (MariaDB), PHP) is a very common example of a web service stack, named as an acronym of the names of its original four open-source components: the Linux operating system, the NGINX HTTP Server, the MySQL relational database management system (RDBMS), and the PHP programming language. The LEMP components are largely interchangeable and not limited to the original selection. As a solution stack, LEMP is suitable for building dynamic web sites and web applications.

Since its creation, the LEMP model has been adapted to other componentry, though typically consisting of free and open-source software. 

 "LEMP" now refers to a generic software stack model. The modularity of a LEMP stack may vary, but this particular software combination has become popular because it is sufficient to host a wide variety of website frameworks, such as Magento 2, Shopware 6, Sylius,  WordPress, and Drupal. The components of the LAMP stack are present in the software repositories of most Linux distributions.
Curtain repository wors for EC2 AWS LINUX2 / Centos 7 / RedHat 7

The LAMP bundle can be combined with many other free and open-source software packages, Magento uses Redis 6.0 and Elastic Search additionally.

# Why not Magento Docker Compose?

**Update: docker support added!
To build Docker Run**
```
docker build . -t my-docker-image --no-cache
docker run --privileged --name magento2-container -dit  -v /sys/fs/cgroup:/sys/fs/cgroup:ro  -p 80:80 -p 443:443 -p 3306:3306  my-docker-image:latest 
docker exec -it magento2-container bash

#copy code to the container

docker cp ./README.md magento2-container:/var/www/html/magento/

#install magento - insert your values 

php -d memory_limit=5028M /var/www/html/magento/bin/magento setup:install --base-url=http://$IP --base-url-secure=http://$IP --use-secure=0 --use-rewrites=1 --use-secure-admin=1 --backend-frontname=admin --db-host=127.0.0.1 --db-name=magento --db-user=root --db-password=root --use-secure=0 --base-url-secure=0 --use-secure-admin=0 --admin-firstname=Admin --admin-lastname=Adminovich --admin-email=admin@admin.ua --admin-user=admin --backend-frontname=admin --use-rewrites=1 --admin-password=admin123

# crete database and dump 

mysql -h 127.0.0.1 -u root magento2 < ./magento-dump.sql.gz

# or adjust env.php file
```

There are also times when Docker isn’t the best solution:

1. Your Magento app is complicated and you are not/do not have a sysadmin. For large or complicated Magento applications, using a pre-made Dockerfile or pulling an existing image will not be sufficient. The building, editing, and managing communication between multiple containers on multiple servers is a time-consuming task.

2. Performance is critical to eCommerce applications. Docker shines compared to virtual machines when it comes to performance because containers share the host kernel and do not emulate a full operating system. However, Docker does impose performance costs. Processes running within a container will not be quite as fast as those run on the native OS. If you need to get the best possible performance of Magento out of your server, you may want to avoid Docker.

3. You don’t want to upgrade hassles. Docker is a new technology that is still under development. To get new features you will likely have to update versions frequently, and backward compatibility with previous versions is not guaranteed.

4. Docker’s containerization approach raises its own security challenges, especially for more complicated applications. These issues are solvable, but require attention from an experienced security engineer. (See the More Info section for links to discussions of these issues).

5. Clusters. This repo is for high load Magento cluster and you will use native cloud services instead of docker containers 

You can also use this script/recipe to build Docker using amazonlinux:latest as a base image.


# Structure of the project:

## Components

The whale installation process is separated into Components

A component script defines the sequence of steps required to install the instance with the application. Components are executed on the instance via ssh or during EC2 creation using User Data. 
start recipe has all components in the right order.

## Image recipe

An image recipe is the main document that defines the source image and the components to be applied to the instance to produce the desired configuration.

# How to RUN: 

## Run the main Recipe
```
sudo bash install-all.sh
```
You probably need some customization. Also, you can create your own configuration. For example, You wanna use AWS services MYSQL RDS, ElastiCahe Redis, Elastic Search you can remove those components. If you have any issues create the ticket and I help you. 

# Support and Questions 

Send email to: yegorshytikov@gmail.com or create ticke/issue. 

# General Configuation:

## Nginx 

/etc/nginx

/etc/nginx/conf.d/magento.conf  - magento related config 

## Redis 

nano /etc/redis/redis.conf

## PHP 

/etc/php-fpm.d/www.conf
/etc/php.ini

## Magento 

/var/www/html/magento - root dirrectory

## Configure Nginx with Magento 

Finally, configure Nginx site configuration file for Magento. This file will control how users access Magento content. Run the commands below to create a new configuration file called example.com.

sudo nano /etc/nginx/sites-available/example.com

Then copy and paste the content below into the file and save it. Replace the highlighted line with your own domain name and directory root location…

Also make sure to reference the certificate files created above during Cloudflare setup..
```
upstream fastcgi_backend {
  server   fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
}

server {
    listen 80;
    listen [::]:80;
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    server_name  example.com www.example.com;
    index  index.php;

    ssl_certificate /etc/ssl/certs/cloudflare_example.com.pem;
    ssl_certificate_key /etc/ssl/private/cloudflare_example.com.pem;
    ssl_client_certificate /etc/ssl/certs/origin-pull-ca.pem;
    ssl_verify_client on;

    set $MAGE_ROOT /var/www/html/example.com;
    set $MAGE_MODE production;

    access_log /var/log/nginx/example.com-access.log;
    error_log /var/log/nginx/example.com-error.log;

    include /var/www/html/example.com/nginx.conf.sample;
}
```
Save the file and exit.

## Set Magento file permissions
You must set read-write permissions for the web server group before you install the Magento software. This is necessary so that the command line can write files to the Magento file system.

```
cd /var/www/html/<magento install directory>
find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
chown -R :www-data . # Ubuntu
chmod u+x bin/magento
```

# Install Magento
You must use the command line to install Magento.

This example assumes that the Magento install directory is named magento2ee, the db-host is on the same machine (localhost), and that the db-name, db-user, and db-password are all magento:

```
bin/magento setup:install \
--base-url=http://localhost/magento2ee \
--db-host=localhost \
--db-name=magento \
--db-user=magento \
--db-password=magento \
--admin-firstname=admin \
--admin-lastname=admin \
--admin-email=admin@admin.com \
--admin-user=admin \
--admin-password=admin123 \
--language=en_US \
--currency=USD \
--timezone=America/Chicago \
--use-rewrites=1
```

# Logs

 **PHP-FPM:** tail -f /var/log/php-fpm/www-error.log
 **NGINX:** tail -f /var/log/nginx/error.log || tail -f /var/log/nginx/access.log
 **Magento** tail -f /var/www/html/magento/var/log
 
