FROM ubuntu:18.04
ENV LANGUAGE=en_US.utf8
ENV LANG=en_US.utf8
ENV LC_ALL=en_US.utf8
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
ARG DEBIAN_FRONTEND=noninteractive
ARG uid
RUN apt-get update && apt-get install -y locales && locale-gen en_US.utf8 && \
apt-get install apt-utils  -y && \
apt-get install -y software-properties-common  &&\
add-apt-repository ppa:ondrej/php && \
apt-get update && \
echo '\n************************ INSTALL IMPORTANT LIB ************\n' && \
apt-get -y install --fix-missing apt-utils curl libcurl4 zip &&\
##install php
echo '\n************************ INSTALL PHP/APACHE ************\n' && \
apt-get install -y unzip php7.1 php7.1-ldap php7.1-common php7.1-cli php7.1-gd php7.1-mysql php7.1-gd \
php7.1-mbstring php7.1-bcmath php7.1-imap php7.1-xml php7.1-zip &&\
# composer 
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer &&\
#install sqlite
apt-get install sqlite3 -y && \ 
apt-get purge software-properties-common apt-utils -y && apt-get autoremove -y &&\
#config apache
sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf &&\
sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf &&\
a2enmod rewrite headers  &&\
mkdir /var/www/html/base &&\
composer create-project --prefer-dist laravel/lumen /var/www/html/base
COPY ./composer.json /var/www/html/base/
COPY ./php.ini /etc/php/7.1/cli/
RUN  service apache2 restart && cd /var/www/html/base && composer update  && rm -rf /var/www/html/base
#config php
#mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
#### uncomment line below if use to test localy
# RUN useradd -G www-data,root -u $uid -d /home/devuser devuser
# RUN mkdir -p /home/devuser/.composer && \
#     chown -R devuser:devuser /home/devuser
WORKDIR /var/www/html
EXPOSE 80
CMD apachectl -D FOREGROUND