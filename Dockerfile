FROM php:8.4-fpm-alpine AS builder

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

# Copy pre-built extensions from builder
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

# Set working directory
WORKDIR /var/www/html

# Copy application from builder
COPY --from=builder /var/www/html /var/www/html

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]