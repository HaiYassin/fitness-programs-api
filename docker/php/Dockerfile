FROM php:8.4-fpm

# --- 📦 Installation des dépendances système ---
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
    libpq-dev \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- 🧩 Extensions PHP ---
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

# --- 🐞 Xdebug (développement uniquement) ---
RUN pecl install xdebug && docker-php-ext-enable xdebug

# --- 🎼 Composer ---
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# --- 🏗️ Symfony CLI ---
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash \
 && apt-get update && apt-get install -y symfony-cli

# --- 🛠️ Config PHP ---
COPY docker/php/conf.d/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY docker/php/conf.d/error_reporting.ini /usr/local/etc/php/conf.d/error_reporting.ini

# --- 📂 Dossier de travail ---
WORKDIR /var/www/html

# --- 🧹 Permissions ---
RUN chown -R www-data:www-data /var/www/html

# --- 👤 On passe à www-data après toutes les opérations root ---
USER www-data

CMD ["php-fpm"]
