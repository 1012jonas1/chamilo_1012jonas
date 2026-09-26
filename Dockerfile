FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    apache2 \
    php8.3 \
    libapache2-mod-php8.3 \
    php8.3-cli \
    php8.3-curl \
    php8.3-gd \
    php8.3-intl \
    php8.3-ldap \
    php8.3-mbstring \
    php8.3-mysql \
    php8.3-soap \
    php8.3-xml \
    php8.3-zip \
    php8.3-bcmath \
    php8.3-apcu \
    unzip \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /var/www

RUN git clone --depth 1 https://github.com/chamilo/chamilo-lms.git chamilo

WORKDIR /var/www/chamilo

RUN composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader

RUN a2enmod rewrite headers expires

RUN rm -f /etc/apache2/sites-enabled/000-default.conf

COPY apache.conf /etc/apache2/sites-available/chamilo.conf

RUN a2ensite chamilo.conf

RUN chown -R www-data:www-data /var/www/chamilo

EXPOSE 80

CMD ["apache2ctl", "-D", "FOREGROUND"]
