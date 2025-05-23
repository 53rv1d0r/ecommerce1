FROM php:8.4-fpm-alpine AS builder

# Define arguments for UID/GID, default to a common value if not provided
ARG WWWUSER=1000
ARG WWWGROUP=1000

# Install development packages and PHP extensions in a single layer
RUN apk add --no-cache \
    zlib-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    oniguruma-dev \
    libxml2-dev \
    icu-dev \
    autoconf \
    g++ \
    make \
    linux-headers \
    libwebp-dev \
    curl-dev \
    openssl-dev \
    bash \
    shadow \
    sudo \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
       pdo pdo_mysql bcmath gd mbstring zip exif dom xml simplexml xmlreader xmlwriter ctype fileinfo session mysqli intl \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --force-php=/usr/local/bin/php \
    && rm -rf /var/cache/apk/* 

# Set working directory
WORKDIR /var/www/html

# Copy composer files first to leverage Docker cache
COPY composer.json composer.lock* ./

# Install dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts --no-autoloader

# Copy the rest of the application
COPY . .

# Generate optimized autoloader
RUN composer install --no-dev --optimize-autoloader

# Optimize Laravel application
RUN php artisan optimize:clear \
 && php artisan config:cache \
 && php artisan route:cache \
 && php artisan view:cache

# Final stage
FROM php:8.4-fpm-alpine

# Define arguments for UID/GID again for this stage
ARG WWWUSER=1000
ARG WWWGROUP=1000

# Copy necessary utilities for user management if they were not in the base image
# (bash, shadow, sudo are already copied from builder, but good to be explicit or ensure they are present)
RUN apk add --no-cache bash shadow sudo

# Create the 'sail' user and group here, in the final stage
RUN set -eux; \
    addgroup -g "$WWWGROUP" sail; \
    adduser -u "$WWWUSER" -G sail -s /bin/bash -D sail; \
    # Give 'sail' user sudo privileges without password
    echo 'sail ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/sail; \
    chmod 0440 /etc/sudoers.d/sail; \
    # Add www-data to the 'sail' group (optional, but good for shared permissions)
    addgroup www-data sail

# Copy pre-built extensions from builder
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

# Set working directory
WORKDIR /var/www/html

# Copy application from builder Ensure sail user owns files
COPY --from=builder --chown=sail:sail /var/www/html /var/www/html

# Set proper permissions for Laravel (logs, cache)
# This ensures www-data can write, while sail can still operate on the files
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R ug+rwx /var/www/html/storage /var/www/html/bootstrap/cache

# Switch to the 'sail' user for running the application
USER sail

# Expose port
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]