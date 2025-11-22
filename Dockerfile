FROM php:8.1-apache

# 1. 安装系统依赖
RUN apt-get update && apt-get install -y \
    unzip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype \
    && docker-php-ext-install pdo_mysql pdo_pgsql zip gd mbstring xml \
    && a2enmod rewrite \
    && sed -i 's/80/8000/g' /etc/apache2/ports.conf /etc/apache2/sites-available/*.conf \
    && sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. 下载并解压 Blessing Skin
WORKDIR /var/www/html
RUN curl -L https://github.com/bs-community/blessing-skin-server/releases/download/6.0.0/blessing-skin-server-6.0.0.zip -o blessing.zip \
    && unzip -o blessing.zip -d /tmp/blessing \
    && mv /tmp/blessing/* /var/www/html/ \
    && mv /tmp/blessing/.* /var/www/html/ 2>/dev/null || true \
    && rm -rf /tmp/blessing blessing.zip \
    && chown -R www-data:www-data /var/www/html \
    && sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

# 3. 暴露端口
EXPOSE 8000

# 4. 启动命令 (包含数据库迁移)
CMD sh -c "php artisan migrate --force && apache2-foreground"
