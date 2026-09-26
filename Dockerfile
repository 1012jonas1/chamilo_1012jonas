FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV COMPOSER_ALLOW_SUPERUSER=1

# ============================================================
# 1. Apache + PHP + benodigde extensies
# ============================================================

RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-php \
    php \
    php-cli \
    php-apcu \
    php-bcmath \
    php-curl \
    php-gd \
    php-intl \
    php-ldap \
    php-mbstring \
    php-mysql \
    php-soap \
    php-xml \
    php-zip \
    git \
    unzip \
    curl \
    composer \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*


# ============================================================
# 2. Chamilo downloaden
# ============================================================

WORKDIR /var/www

RUN git clone --depth 1 https://github.com/chamilo/chamilo-lms.git chamilo

WORKDIR /var/www/chamilo


# ============================================================
# 3. PHP Composer dependencies
# ============================================================

RUN composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader


# ============================================================
# 4. Frontend dependencies
# ============================================================

RUN npm install -g yarn

RUN yarn install


# ============================================================
# 5. Frontend assets bouwen
# ============================================================

RUN yarn dev


# ============================================================
# 6. Chamilo configuratie
# ============================================================

RUN touch .env

RUN mkdir -p var config

RUN chown -R www-data:www-data \
    /var/www/chamilo/var \
    /var/www/chamilo/config \
    /var/www/chamilo/.env


# ============================================================
# 7. Apache modules
# ============================================================

RUN a2enmod rewrite

RUN a2enmod headers

RUN a2enmod expires


# ============================================================
# 8. Chamilo Apache configuratie
# ============================================================

RUN cp \
    /var/www/chamilo/public/main/install/apache.dist.conf \
    /etc/apache2/sites-available/chamilo.conf

RUN a2dissite 000-default.conf

RUN a2ensite chamilo.conf


# ============================================================
# 9. Apache ServerName
# ============================================================

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf


# ============================================================
# 10. PHP foutmeldingen AAN
# ============================================================
# Tijdelijk ingeschakeld om de witte pagina te debuggen.

RUN PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;') && \
    printf '%s\n' \
    'display_errors=On' \
    'display_startup_errors=On' \
    'error_reporting=E_ALL' \
    'log_errors=On' \
    'error_log=/proc/self/fd/2' \
    'memory_limit=512M' \
    'upload_max_filesize=256M' \
    'post_max_size=256M' \
    'max_execution_time=300' \
    > /etc/php/${PHP_VERSION}/apache2/conf.d/99-chamilo.ini


# ============================================================
# 11. Railway start script
# ============================================================

COPY start.sh /start.sh

RUN chmod +x /start.sh


# ============================================================
# 12. Railway
# ============================================================

EXPOSE 80


# ============================================================
# 13. Apache starten
# ============================================================

CMD ["/start.sh"]
