# Usamos una imagen base oficial de Apache en Alpine
FROM httpd:2.4-alpine

# Instalar módulos de Apache necesarios para proxyar a FPM y mod_rewrite
# En Alpine, los módulos se cargan descomentando líneas en httpd.conf
# Usamos sed para encontrar y descomentar las líneas de LoadModule
RUN sed -i 's!#LoadModule rewrite_module modules/mod_rewrite.so!LoadModule rewrite_module modules/mod_rewrite.so!g' /usr/local/apache2/conf/httpd.conf \
    && sed -i 's!#LoadModule proxy_module modules/mod_proxy.so!LoadModule proxy_module modules/mod_proxy.so!g' /usr/local/apache2/conf/httpd.conf \
    && sed -i 's!#LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so!LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so!g' /usr/local/apache2/conf/httpd.conf

# Copiar nuestro archivo de configuración de VirtualHost personalizado
# Asumimos que el archivo se llama laravel.conf y está en una carpeta 'apache' en la raíz del proyecto
COPY ./apache/laravel.conf /usr/local/apache2/conf/extra/laravel.conf

# Incluir nuestro archivo de configuración personalizado en el archivo de configuración principal de Apache
# Añadimos una línea 'Include' al final de httpd.conf para cargar nuestra configuración
RUN echo "Include conf/extra/laravel.conf" >> /usr/local/apache2/conf/httpd.conf

# El directorio de trabajo por defecto de httpd:alpine es /usr/local/apache2.
# No necesitamos cambiarlo explícitamente si nuestro VirtualHost apunta correctamente a /var/www/html/public

# Exponer el puerto 80, que es el puerto por defecto de Apache
EXPOSE 80

# Comando por defecto para iniciar Apache en primer plano
# Este es el CMD por defecto de la imagen httpd, lo mantenemos así
CMD ["httpd", "-DFOREGROUND"]