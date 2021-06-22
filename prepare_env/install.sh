FILE_SOURCES=/etc/apt/sources.list
FILE_RABIBIT_CONF=/etc/rabbitmq/rabbitmq.conf
FILE_ELSTIC_CONF=/etc/elasticsearch/elasticsearch.yml
FILE_LARAVEL_CONF=/var/www/WEBAPI/.env
FILE_APACHE2_CONF=/etc/apache2/sites-available/000-default.conf

truncate -s 0 $FILE_SOURCES
echo "deb http://archive.ubuntu.com/ubuntu focal main universe" >> $FILE_SOURCES
echo "deb http://archive.ubuntu.com/ubuntu focal-security main universe" >> $FILE_SOURCES
echo "deb http://archive.ubuntu.com/ubuntu focal-updates main universe" >> $FILE_SOURCES

sudo apt-get update && sudo apt-get upgrade -y


sudo apt install apache2 mysql-server git -y

sudo mysql -u root -e "SET GLOBAL local_infile=1;"
sudo mysql -e "SELECT user,authentication_string,plugin,host FROM mysql.user;"
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'test123.0';"
sudo mysql -u root -ptest123.0 -e "FLUSH PRIVILEGES;"
sudo mysql -u root -ptest123.0 -e "SELECT user,authentication_string,plugin,host FROM mysql.user;"


sudo apt install php openssl php-common php-curl php-json php-mysql php-xml libapache2-mod-php php-mbstring -y

sudo apt install osmctools -y

sudo apt-get install rabbitmq-server -y

sudo rabbitmq-plugins enable rabbitmq_management

sudo chmod 777 /etc/rabbitmq
sudo echo "loopback_users = none" >> $FILE_RABIBIT_CONF

sudo service rabbitmq-server restart

curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt update
sudo apt install elasticsearch -y

sudo chmod 777 /etc/elasticsearch/*
sudo echo "network.host: 0.0.0.0" >> $FILE_ELSTIC_CONF
sudo echo "http.port: 9200" >> $FILE_ELSTIC_CONF
sudo echo "transport.host: localhost" >> $FILE_ELSTIC_CONF
sudo echo "transport.tcp.port: 9300" >> $FILE_ELSTIC_CONF


sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch


sudo apt install npm -y
sudo npm install --save forever -g --silent
sudo npm install --save amqplib -g --silent

sudo apt install unzip composer -y

git clone https://github.com/AhmedSaiedOmran/s605-project.git project

sudo cp -r project/WEBAPI /var/www/WEBAPI

sudo composer install -d /var/www/WEBAPI

sudo chmod 777 /var/www/WEBAPI/
sudo chmod 777 /var/www/WEBAPI/*
sudo chmod 777 /var/www/WEBAPI
sudo chown -R $USER:www-data /var/www/WEBAPI
sudo find /var/www/WEBAPI  -type f -exec chmod 777 {} \;
sudo find /var/www/WEBAPI  d -exec chmod  777 {} \;
sudo chgrp -R www-data /var/www/WEBAPI/storage /var/www/WEBAPI/bootstrap/cache
sudo chmod -R ug+rwx /var/www/WEBAPI/storage /var/www/WEBAPI/bootstrap/cache

sudo cp /var/www/WEBAPI/.env.example /var/www/WEBAPI/.env
sudo chmod 777 /var/www/WEBAPI/.env


sudo echo "DB_USERNAME=root" >> $FILE_LARAVEL_CONF
sudo echo "DB_DATABASE=places" >> $FILE_LARAVEL_CONF
sudo echo "DB_PASSWORD=test123.0" >> $FILE_LARAVEL_CONF


sudo hostname -I | awk -F\, '{print "AMQP_HOST="""$1}' >> $FILE_LARAVEL_CONF
sudo php /var/www/WEBAPI/artisan key:generate

sudo truncate -s 0 $FILE_APACHE2_CONF

sudo cp apache.conf /etc/apache2/sites-available/000-default.conf
sudo a2enmod rewrite
sudo systemctl restart apache2
sudo forever start consumer.js
