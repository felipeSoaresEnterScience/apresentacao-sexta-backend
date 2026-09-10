FROM php:8.4-cli

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        unzip \
        libpq-dev \
        libzip-dev \
        libicu-dev \
        libpng-dev \
        libjpeg-dev \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        pdo_pgsql \
        pgsql \
        zip \
        intl \
        bcmath \
        gd \
        opcache \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

WORKDIR /var/www

EXPOSE 8000

CMD ["/usr/local/bin/setup.sh"]
