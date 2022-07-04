# H5

## 环境配置

### 修改Windows主机上的host文件

向 `C:\Windows\System32\drivers\etc\hosts` 中添加三条内容

```
    192.168.56.103 wp.sec.cuc.edu.cn
    192.168.56.103 dvwa.sec.cuc.edu.cn
    192.168.56.103 verynginx.sec.cuc.edu.cn
```


### 安装 Nginx

根据官网的[下载指南](http://nginx.org/en/linux_packages.html)下载nginx

```
# Install the prerequisites
$ sudo apt install curl gnupg2 ca-certificates lsb-release

# To set up the apt repository for stable nginx packages
$ echo "deb http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
| sudo tee /etc/apt/sources.list.d/nginx.list

# import an official nginx signing key so apt could verify the packages authenticity
$ curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -

# Verify that you now have the proper key
# The output should contain the full fingerprint 573B FD6B 3D8F BC64 1079 A6AB ABF5 BD82 7BD9 BF62 as follows
# pub   rsa2048 2011-08-19 [SC] [expires: 2024-06-14]
  573B FD6B 3D8F BC64 1079  A6AB ABF5 BD82 7BD9 BF62
# uid   [ unknown] nginx signing key <signing-key@nginx.com>
$ sudo apt-key fingerprint ABF5BD827BD9BF62

# To install nginx, run the following commands
$ sudo apt update
$ sudo apt install nginx
```

### 安装 VeryNginx

根据官方的 `GitHub` [仓库指南](https://github.com/alexazhou/VeryNginx/blob/master/readme_zh.md)进行安装

先克隆仓库到本地，根据指南执行指令

```
$ git clone https://github.com/alexazhou/VeryNginx.git
$ cd VeryNginx
$ python install.py install
```
根据报错，安装相关依赖。再重新尝试安装，安装成功

```
# 安装依赖
$ sudo apt-get update
$ sudo apt-get install python3
$ sudo apt-get install libpcre3 libpcre3-dev libssl-dev build-essential
$ sudo apt-get install libssl1.0-dev
$ sudo apt-get install zlib1g-dev

# 重新再尝试安装
$ sudo python3 install.py install
```
修改 `/opt/verynginx/openresty/nginx/conf/nginx.conf` 配置文件,设置 `server` 监听端口为 `8080` ， `user` 修改为 `www-data`

开启VeryNginx

```
$ sudo /opt/verynginx/openresty/nginx/sbin/nginx
```

现在我们可以去访问 `http://verynginx.sec.cuc.edu.cn:8080/verynginx/index.html` 到 VeryNginx 的界面，用户/密码为 `verynginx/verynginx`

### 安装 wordpress

下载mysql、php和相关扩展

```
# 安装数据库
$ sudo apt install mysql-server
# 检查是否正常运行，默认下无密码
$ sudo mysql -u root -p

#安装php和相关扩展
$ sudo apt install php-fpm php-mysql
$ sudo apt install php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip
$ sudo systemctl restart php7.2-fpm
```
创建 wordpress 需要数据库支持

```
# mysql新建数据库
$ sudo mysql -u root -p
> CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
> GRANT ALL ON wordpress.* TO 'wpuser'@'localhost' IDENTIFIED BY 'test';
> FLUSH PRIVILEGES;
> EXIT;
```
下载 wordpress

```
$ cd /tmp

# 下载实验指定版本安装包
$ sudo wget https://wordpress.org/wordpress-4.7.zip

# 解压
$ unzip wordpress-4.7.zip

# 移动文件夹到指定目录
$ cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
$ sudo cp -a /tmp/wordpress/. /var/www/wordpress

# 修改文件夹属主为 www-data
$ sudo chown -R www-data:www-data /var/www/wordpress
```
修改 wordpress 相关配置文件

```
$ curl -s https://api.wordpress.org/secret-key/1.1/salt/
$ sudo vim /var/www/html/wordpress/wp-config.php

        # 修改内容如下
        # 修改相关参数
        define('DB_NAME', 'wordpress');

        /** MySQL database username */
        define('DB_USER', 'wpuser');

        /** MySQL database password */
        define('DB_PASSWORD', 'test');

        # 新增相关内容
        define('FS_METHOD', 'direct');

$ sudo vim /etc/nginx/sites-available/default

        # 增加内容
        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
            }
        
        # 修改网站根站点
        root /var/www/html/wordpress;
        # 修改监听端口
        listen 8888;
        # 修改server_name
        wp.sec.cuc.edu.cn
```


​    
```
# 语法检查
$ sudo nginx -t

# 重启nginx
$ sudo systemctl restart nginx
```
### 安装 dvwa

下载安装包

```
$ cd /tmp
$ git clone https://github.com/ethicalhack3r/DVWA
$ sudo mv /tmp/DVWA /var/www/html
```
dvwa需要数据库支持，所以先新建数据库

```
$ sudo mysql -u root -p

> CREATE DATABASE dvwa DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
> GRANT ALL ON dvwa.* TO 'dvwauser'@'localhost' IDENTIFIED BY 'test';
> FLUSH PRIVILEGES;
> EXIT;

$ sudo systemctl restart mysql
```
修改dvwa数据库相关和其他设置

```
$ cd /var/www/html/DVWA
$ cp config/config.inc.php.dist config/config.inc.php
$ sudo vim /var/www/html/DVWA/config/config.inc.php 
        
        # 修改以下内容
        $_DVWA[ 'db_database' ] = 'dvwa';
        $_DVWA[ 'db_user' ]     = 'dvwauser';
        $_DVWA[ 'db_password' ] = 'test';

# 修改文件属主
$ sudo chown -R www-data:www-data /var/www/html/DVWA

# 修改 nginx 相关配置
$ sudo vim /etc/nginx/sites-available/default

        server {
                listen 5566;
                server_name  dvwa.sec.cuc.edu.cn;

                root /var/www/html/DVWA;
                index index.html index.htm index.php index.nginx-debian.html;

                location / {
                        try_files $uri $uri/ = 404;
                        }

                location ~ \.php$ {
                        include snippets/fastcgi-php.conf;
                        fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
                        }
                        }

# 修改php相关设置
$ sudo vim  /etc/php/7.2/fpm/php.ini

        # 修改以下内容
        allow_url_include = On
        display_errors = off

# 重启php，使配置生效
$ sudo systemctl restart php7.2-fpm

$ 重启nginx，使配置生效
$ sudo systemctl restart nginx
```
### 设置 VeryNginx 实现端口转发

修改Nginx配置文件，将原本wordpressd的 `8888` 端口修改为 `127.0.0.1:8888`，DVWA的 `5566` 端口修改为 `127.0.0.1:5566`

通过 `VeryNginx` 进行相关设置

为了能以https的方式访问 `wordpress`，在 `VeryNginx` 中设置443端口，并配证书

```
# 生成证书
$ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/wordpress-selfsigned.key -out /etc/ssl/certs/wordpress-selfsigned.crt

# 将证书地址写入文件，方便后面使用
$ sudo vim /etc/nginx/snippets/self-signed.conf
        ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
        ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

# 修改 VeryNginx 设置
$ sudo vim /opt/verynginx/openresty/nginx/conf/nginx.conf

        # 增加以下内容
        server {
                listen 443 ssl;
                server_name wp.sec.cuc.edu.cn;
                root /var/www/html;
                include /opt/verynginx/verynginx/nginx_conf/in_server_block.conf;
                include /etc/nginx/snippets/self-sign.conf;

                location = / {
                        root html;
                        index index.html index.html;
                }
        }

# 修改 nginx 设置
$ sudo vim /etc/nginx/sites-available/default

        # 在 wordpress 对应的 server 中增加如下

        include /etc/nginx/snippets/self-sign.conf;
```

## 参考资料

[nginx: Linux packages](http://nginx.org/en/linux_packages.html)

[alexazhou/VeryNginx](https://github.com/alexazhou/VeryNginx/blob/master/readme_zh.md)

