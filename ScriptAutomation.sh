#!/bin/bash

#Variable
REPO="bootcamp-devops-2023"
BRCH="clase2-linux-bash"
USERID=$(id -u)

#validacion usuario ROOT
if [ "${USERID}" -ne 0 ];
then
    echo -e "\nSe necesita ejecutar con usuario ROOT"
    exit
fi 

#Actualizando sistema
echo "-----Se actualiza sistema operativo-----"
apt-get update
echo "----Actualizado-----"

sleep 1
echo "Instalacion GIT"
if dpkg -l | grep -q git ;
then
	echo "Se encuentra instalado"
else
	echo "Se esta instalando GIT"
	sudo apt install git -y
fi
sleep 1
echo "Instalacion MARIA-DB"
if dpkg -l | grep -q mariadb-server ;
then
	echo "Se encuentra instalado"
else
	echo "Se esta instalando mariadb-server"
	sudo apt install -y mariadb-server
fi
sleep 1
echo "Instalacion APACHE2"
if dpkg -l | grep -q apache2 ;
then
	echo "Se encuentra instalado"
else
	echo "Se esta instalando apache2"
	sudo apt install apache2 -y
fi
sleep 1
echo "Instalacion PHP"
if dpkg -l | grep -q php,php-mysql ;
then
	echo "Se encuentra instalado"
else
	echo "Se esta instalando php"
	sudo apt install -y php libapache2-mod-php php-mysql php-mbstring php-zip php-gd php-json php-curl
fi	

echo "------Aplicaciones instaladas en su entorno------"

sleep 1

echo "-----------Habilitando aplicaciones------"

sudo systemctl start mariadb
sudo systemctl enable mariadb

sleep 1

sudo systemctl start apache2 
sudo systemctl enable apache2

echo "---Revisando version PHP----"
php -v

sleep 1

echo "------Configurando el entorno------"

echo "<IfModule mod_dir.c>
        DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>">/etc/apache2/mods-enabled/dir.conf

sleep 1

echo "Creacion DB en entorno"
mysql -e "
CREATE DATABASE devopstravel;
CREATE USER 'codeuser'@'localhost' IDENTIFIED BY 'codepass';
GRANT ALL PRIVILEGES ON *.* TO 'codeuser'@'localhost';
FLUSH PRIVILEGES;"

sleep 1
echo "---Clonar repositorio u actualizar repositorio---"

if [ -d "$REPO" ] ;
then	git pull -b $BRCH https://github.com/roxsross/$REPO.git
else 	git clone -b $BRCH https://github.com/roxsross/$REPO.git
fi

if [ -f "/var/www/html/index.html" ] ;
then 
	mv /var/www/html/index.html /var/www/html/index.html.bkp
fi

cp -r $REPO/app-295devops-travel/* /var/www/html/

sleep 1

sed -i 's/$dbPassword = ""/$dbPassword = "codepass"/g' /var/www/html/config.php

sleep 1

echo "Copiando DB desde proyecto"

mysql < $REPO/app-295devops-travel/database/devopstravel.sql

echo "Recargando Apache2"
sudo systemctl reload apache2
