ARG BUN_VERSION=1
ARG COMPOSER_VERSION=2.7
ARG PHP_VERSION=8.1
ARG RUN_MIGRATION=false
###########################################
# Build frontend assets with Bun for faster build
###########################################
FROM oven/bun:${BUN_VERSION} AS node

ARG PROJECT_DIR=/var/www/html
ENV NODE_ENV=production

# Set the working directory inside the container
WORKDIR $PROJECT_DIR

# Copy the package.json and bun.lockb files
COPY package.json bun.lockb ./

# Install dependencies using npm and Bun, chain them together to minimize layers
RUN bun install --no-save --frozen-lockfile


# Copy the entire application code
COPY . .

# Build the frontend assets and clean up in a single layer
RUN bun run build


###########################################
# Prepare vendor images
###########################################
FROM composer:${COMPOSER_VERSION} AS vendor


###########################################
# Build Backend and running web server
###########################################
# Use PHP 8.1 FPM Alpine as the base image
FROM php:${PHP_VERSION}-fpm-alpine AS server

ARG PROJECT_DIR=/var/www/html

# Set the working directory inside the container
WORKDIR $PROJECT_DIR

# Install system dependencies and PHP extensions
RUN apk add --no-cache nginx libpng libzip icu \
    && apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    libpng-dev \
    libzip-dev \
    icu-dev \
    && docker-php-ext-install opcache pdo pdo_mysql zip gd intl exif \
    && docker-php-ext-configure opcache --enable-opcache \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

# Copy Composer from its image
COPY --chown=www-data:www-data --from=vendor /usr/bin/composer /usr/bin/composer
COPY --chown=www-data:www-data composer.json composer.lock ./

RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copy application files
COPY --chown=www-data:www-data . $PROJECT_DIR
COPY --chown=www-data:www-data --from=node /var/www/html/public public

RUN mkdir -p storage/framework/sessions \
    storage/framework/views \
    storage/framework/cache \
    storage/framework/testing \
    storage/logs \
    bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Copy Nginx configuration file
COPY docker/nginx.conf /etc/nginx/nginx.conf

# Copy entrypoint script
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh


# Expose port 80
EXPOSE 80

# Set entrypoint script to start both PHP-FPM and Nginx
CMD ["/usr/local/bin/entrypoint.sh"]
