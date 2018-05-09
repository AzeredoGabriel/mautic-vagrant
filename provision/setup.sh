#!/bin/bash

echo "===================================="
echo "Importando arquivo de configurações "
echo "===================================="
. /vagrant/provision/provision.config

echo "===================================="
echo "Instalando apache2 e git"
echo "===================================="
sudo apt-get update
sudo apt-get install apache2 git -y

echo "================================================"
echo "Liberando permissão 755 para pasta /var/www/"
echo "================================================"
sudo chmod -R 755 /var/www

echo "==========================================================="
echo "Copiando arquivos para a pasta de configuração do apache "
echo "==========================================================="
cp /vagrant/provision/mautic.conf.template /etc/apache2/sites-available/mautic.conf

echo "=============================================================="
echo "Configurando GIT com o usuário $git_user e e-mail $git_mail "
echo "=============================================================="
git config --global user.name $git_user
git config --global user.email $git_mail

echo "================================"
echo "Instalando PHP7.0 e extensões"
echo "================================"

sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get install -y language-pack-en-base
sudo LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install php7.0 php7.0-mysql -y
sudo apt-get install libapache2-mod-php7.0 php7.0-mcrypt php7.0-bcmath php7.0-mbstring php7.0-curl php7.0-xml php7.0-zip -y

echo "===================="
echo "Instalando composer"
echo "===================="
sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer -y

echo "==================================================================================================="
echo "Instalando mysql server e criando senha padrão para o usuário root definida no arquivo de senha"
echo "==================================================================================================="

sudo apt remove mysql-client mysql-server libmysqlclient-dev mysql-common
sudo dpkg -l | grep mysql


export DEBIAN_FRONTEND="noninteractive"
sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password password admin'
sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password_again password admin'
sudo apt-get -y install mysql-server


echo "========================================"
echo "Criando usuário, senha e banco de dados "
echo "========================================"
mysql --user=root --password=$mysql_root_password --execute="CREATE DATABASE $mysql_mautic_database; GRANT ALL PRIVILEGES ON $mysql_mautic_database.* TO '$mysql_mautic_user'@'%' IDENTIFIED BY '$mysql_mautic_password';"

echo "============================================"
echo "Copiando arquivo de configuração do mysql"
echo "============================================"
cp /vagrant/provision/my.conf.template /etc/mysql/conf.d/mysql.cnf
sudo /etc/init.d/mysql restart

echo "=================="
echo "Baixando mautic"
echo "=================="
git clone $url_mautic_github /var/www/mautic

echo "============================"
echo "Ativando mautic no apache"
echo "============================"
sudo a2dissite 000-default.conf
sudo a2ensite mautic.conf



