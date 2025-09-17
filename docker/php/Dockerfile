FROM php:8.4-fpm

# Installation des dépendances système
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libicu-dev \
    libpq-dev

# Nettoyage du cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Installation des extensions PHP
RUN docker-php-ext-install \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip \
    intl \
    opcache

# Installation de Xdebug pour le développement
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configuration du working directory
WORKDIR /var/www/html

# Installation de Symfony CLI
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash
RUN apt-get update && apt-get install -y symfony-cli

# Copie des fichiers de configuration PHP
COPY docker/php/conf.d/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY docker/php/conf.d/error_reporting.ini /usr/local/etc/php/conf.d/error_reporting.ini

# Création de l'utilisateur www
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Permissions
RUN chown -R www:www /var/www/html

# Switch to user
USER www

# Exposition du port
EXPOSE 9000

CMD ["php-fpm"]
