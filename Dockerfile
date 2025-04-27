FROM php:8.4-fpm-alpine

# Install development packages needed for PHP extensions
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
    linux-headers
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql bcmath gd mbstring zip exif

# Instalación de composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Establecer el directorio de trabajo
WORKDIR /var/www/html

# Copiar los archivos de la aplicación
COPY . .

# Instalar las dependencias de composer
RUN composer install --no-dev --optimize-autoloader

# Optimizar la aplicación Laravel
RUN php artisan optimize:clear && php artisan config:cache && php artisan route:cache && php artisan view:cache

# Cambiar la propiedad de los directorios para el usuario www-data
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Exponer el puerto 9000 para FPM
EXPOSE 9000

# Comando para ejecutar el servidor de Laravel (se gestionará con Docker Compose)
# CMD ["php-fpm"]