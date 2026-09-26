FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN apt-get update && apt-get install -y \
    apache2 \
    php \
    php-cli \
    php-mysql \
    php-xml \
    php-mbstring \
    php-curl \
    php-zip \
    php-gd \
    php-intl \
    php-apcu \
    php-bcmath \
    php-ldap \
    php-soap \
    git \
    unzip \
    curl \
    composer \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www

RUN git clone --depth 1 https://github.com/chamilo/chamilo-lms.git chamilo

WORKDIR /var/www/chamilo

RUN composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader

RUN a2enmod rewrite

RUN rm -f /var/www/html/index.html

RUN ln -s /var/www/chamilo/public /var/www/html/chamilo

EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]
