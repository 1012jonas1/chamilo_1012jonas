FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV COMPOSER_ALLOW_SUPERUSER=1

# ============================================================
# 1. Apache + PHP + benodigde PHP-extensies
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
    && rm -rf /var/lib/apt/lists/*


# ============================================================
# 2. Chamilo downloaden
# ============================================================

WORKDIR /var/www

RUN git clone --depth 1 https://github.com/chamilo/chamilo-lms.git chamilo

WORKDIR /var/www/chamilo


# ============================================================
# 3. Composer dependencies
# ============================================================

RUN composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader


# ============================================================
# 4. Chamilo directories schrijfbaar maken
# ============================================================

RUN mkdir -p \
    /var/www/chamilo/var \
    /var/www/chamilo/config \
    /var/www/chamilo/public \
    && touch /var/www/chamilo/.env \
    && chown -R www-data:www-data \
        /var/www/chamilo/var \
        /var/www/chamilo/config \
        /var/www/chamilo/.env


# ============================================================
# 5. Apache modules
# ============================================================

RUN a2enmod rewrite
RUN a2enmod headers
RUN a2enmod expires


# ============================================================
# 6. Apache configureren voor Chamilo 2
# ============================================================

RUN sed -i \
    's#DocumentRoot /var/www/html#DocumentRoot /var/www/chamilo/public#' \
    /etc/apache2/sites-available/000-default.conf

RUN printf '%s\n' \
    '<Directory /var/www/chamilo/public>' \
    '    AllowOverride All' \
    '    Require all granted' \
    '</Directory>' \
    '' \
    '<Directory /var/www/chamilo>' \
    '    Options FollowSymLinks' \
    '    AllowOverride All' \
    '    Require all granted' \
    '</Directory>' \
    >> /etc/apache2/sites-available/000-default.conf


# ============================================================
# 7. PHP configuratie
# ============================================================

RUN PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;') && \
    printf '%s\n' \
    'display_errors=Off' \
    'display_startup_errors=Off' \
    'log_errors=On' \
    'error_log=/proc/self/fd/2' \
    'upload_max_filesize=256M' \
    'post_max_size=256M' \
    'memory_limit=512M' \
    'max_execution_time=300' \
    > /etc/php/${PHP_VERSION}/apache2/conf.d/99-chamilo.ini


# ============================================================
# 8. Railway start script
# ============================================================

COPY start.sh /start.sh

RUN chmod +x /start.sh


# ============================================================
# 9. Railway poort
# ============================================================

EXPOSE 80


# ============================================================
# 10. Apache starten
# ============================================================

CMD ["/start.sh"]
