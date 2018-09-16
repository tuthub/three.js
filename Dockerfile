FROM php:7-apache

MAINTAINER Thomas Krasowski <thomaskrasowski@hotmail.com>

ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
  && apt-get install -y net-tools nano vim git wget openssh-server rsyslog \
        libapache2-mod-rpaf \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libc-client-dev \
        libkrb5-dev
#        && rm -r /var/lib/apt/lists/*
RUN pecl install redis


RUN docker-php-ext-install -j$(nproc) iconv mysqli calendar  shmop sysvmsg sysvsem sysvshm \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) zip \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap \
    && docker-php-ext-enable redis

RUN a2enmod rewrite
RUN a2enmod ssl
#RUN usermod -aG users www-data
#RUN usermod -aG root www-data

#COPY ./config/apache2/000-default.conf /etc/apache2/sites-enabled/000-default.conf
#COPY ./config/apache2/default-ssl.conf /etc/apache2/sites-anabled/default-ssl.conf
#COPY ./config/apache2/apache2.conf /etc/apache2/apache2.conf
#COPY ./config/php.ini /usr/local/etc/php/

#copy the code
RUN git clone https://github.com/tuthub/tut-web.git .



#variable to change the document root folder
ENV APACHE_DOCUMENT_ROOT /var/www/html/examples
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
#RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
ENV APACHE_LOG_DIR /var/log/apache2/

#apache status config
RUN sed -i 's/Require\ local/Allow\ from\ all/' /etc/apache2/mods-enabled/status.conf


EXPOSE 80
EXPOSE 443

CMD apache2-foreground

