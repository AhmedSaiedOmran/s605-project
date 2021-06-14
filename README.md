# Prepare General Enviroment for project
## General Enviromnet

### Step 1 (General)
open sources.list
```sh
sudo nano /etc/apt/sources.list
```

Delete All Lines and put only the following
```sh
deb http://archive.ubuntu.com/ubuntu focal main universe
deb http://archive.ubuntu.com/ubuntu focal-security main universe
deb http://archive.ubuntu.com/ubuntu focal-updates main universe
```
Then 
```sh
sudo apt-get update
sudo apt-get upgrade
```


---

### Step 2 (APACHE2 & MYSQL SERVER)
```sh
sudo apt install apache2
sudo apt install mysql-server
```

Run a security script that comes pre-installed with MySQL

```sh
sudo mysql_secure_installation
```
And do follow this steps
- **VALIDATE PASSWORD COMPONENT:**   N
- **Enter new password:**   test123.0
- **Re-enter new password:**   test123.0
- **Remove anonymous users:**   y
- **Disallow root login remotely:**   y
- **Remove test database and access to it:**   y
- **Reload privilege tables now:**   y

then
```sh
sudo mysql
```
```sh
SET GLOBAL local_infile=1;
SELECT user,authentication_string,plugin,host FROM mysql.user;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'test123.0';
FLUSH PRIVILEGES;
SELECT user,authentication_string,plugin,host FROM mysql.user;
exit
```

#### Then install PHP
```sh
sudo apt install php openssl php-common php-curl php-json php-mysql php-xml libapache2-mod-php php-mbstring
```

#### Then install WEB MYSQL Admin

```sh
sudo apt install phpmyadmin
```

And config as following:
- **Choose**   apache 2
- **mysql password**   test@123.0

### Step 3 (INSTALL OpenStreetMap Tools)
```sh
sudo apt install osmctools
```

### Step 4 (INSTALL RabbitMQ Server)
```sh
sudo apt-get install rabbitmq-server
```
```sh
sudo rabbitmq-plugins enable rabbitmq_management
```
Then Create File in /etc/rabbitmq/rabbitmq.conf 
```sh
sudo nano /etc/rabbitmq/rabbitmq.conf
```

And add line as following
```sh
loopback_users = none
```
Then 
```sh
sudo service rabbitmq-server restart
```

### Step 4 (INSTALL ElasticSearch Server)
```sh
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt update
sudo apt install elasticsearch
```
Then change configuration file as following under network section (add the following lines)
```sh
network.host: 0.0.0.0
http.port: 9200
transport.host: localhost
transport.tcp.port: 9300
```

Then Excute the following:
```sh
sudo systemctl start elasticsearch
sudo systemctl enable elasticsearch
```

### Step 4 (INSTALL Node JS for message broker consumer)
```sh
sudo apt install npm
sudo npm install forever -g
npm install --save amqplib

```

### Step 5 (Prepare web environment)
```sh
sudo apt install unzip
sudo apt install composer
```

#### Run Web Project
- Move web project folder in /var/www
- ```sudo composer install ```
- ```sudo cp .env.example .env ```
- ```sudo php artisan key:generate ```
- Then open the following .env file as following
```
sudo nano .env
```
And change the following line likes:
```
DB_DATABASE=places
DB_PASSWORD=test123.0
AMQP_HOST={SERVER IP}
```
##### Permissions for Web Project (Assume that the folder call WebAPI)

```sh
sudo chown -R $USER:www-data /var/www/webAPI
sudo find /var/www/webAPI -type f -exec chmod 644 {} \;
sudo find /var/www/webAPI -type d -exec chmod 755 {} \;
sudo chgrp -R www-data /var/www/webAPI/storage /var/www/webAPI/bootstrap/cache
sudo chmod -R ug+rwx /var/www/webAPI/storage /var/www/webAPI/bootstrap/cache
```
##### Edit Apache2 VHost (Assume that the folder call WebAPI)
```sh
sudo nano 000-default.conf
```

Delete all lines then copy these:
```
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot "/var/www/webAPI/public"
        
        <Directory "/var/www/webAPI/public">
            Options +Indexes +Includes +FollowSymLinks +MultiViews
            AllowOverride All
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```
Then run
```
sudo systemctl restart apache2
```


### Step 6 (Run Script to extract data and send it to DB)
- first download file in home directory as following: (download.sh)
- Run file ```download.sh ```

### Step 7 (Run Script as message broker consumer)
- first download file in home directory as following: (consumer.js)
- Run file ```forever start consumer.js ```



### Check List

- [ ] Change queue name
- [ ] Change ip in consumer script
- [ ] Change ip in postman collection


### TO-DO LIST

- [ ] TBD