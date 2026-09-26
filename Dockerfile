FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV COMPOSER_ALLOW_SUPERUSER=1

# ============================================================
# PHP + Apache + dependencies
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
# Chamilo downloaden
# ============================================================

WORKDIR /var/www

RUN git clone --depth 1 https://github.com/chamilo/chamilo-lms.git chamilo

WORKDIR /var/www/chamilo


# ============================================================
# Composer
# ============================================================

RUN composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader


# ============================================================
# Chamilo configuratiebestanden
# ============================================================

RUN touch .env

RUN chown -R www-data:www-data \
    .env \
    config \
    var


# ============================================================
# Apache modules
# ============================================================

RUN a2enmod rewrite
RUN a2enmod headers
RUN a2enmod expires


# ============================================================
# Chamilo Apache configuratie gebruiken
# ============================================================

RUN cp public/main/install/apache.dist.conf \
    /etc/apache2/sites-available/chamilo.conf

RUN a2dissite 000-default.conf

RUN a2ensite chamilo.conf


# ============================================================
# ServerName
# ============================================================

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf


# ============================================================
# Railway start script
# ============================================================

COPY start.sh /start.sh

RUN chmod +x /start.sh


# ============================================================
# Railway
# ============================================================

EXPOSE 80

CMD ["/start.sh"]
