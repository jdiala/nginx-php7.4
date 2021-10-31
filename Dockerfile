FROM php:7.4-fpm
LABEL maintainer="jdiala@keymind.com"

RUN apt-get update && apt-get install -y --fix-missing \
    sudo \
    nginx \
    default-mysql-client \
    imagemagick \
    graphviz \
    git \
    libpng-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libxml2-dev \
    libxslt1-dev \
    wget \
    linux-libc-dev \
    libyaml-dev \
    libzip-dev \
    libicu-dev \
    libpq-dev \
    libonig-dev \
    libssl-dev && \
    rm -r /var/lib/apt/lists/*
    
RUN docker-php-ext-configure gd --with-jpeg=/usr/include/
RUN docker-php-ext-install \
    mysqli \
    pdo_mysql \
    gd \
    mbstring \
    xsl \
    opcache \
    calendar \
    intl \
    exif \
    ftp \
    bcmath \
    zip

RUN apt-get update && apt-get install -y --fix-missing \
    unzip && \
    rm -r /var/lib/apt/lists/*

RUN cd /usr/src && \
    curl -sS http://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN /usr/bin/composer self-update --1

RUN echo "upload_max_filesize = 500M\n" \
         "post_max_size = 500M\n" \
         > /usr/local/etc/php/conf.d/maxsize.ini

RUN echo "memory_limit = -1\n" \
         > /usr/local/etc/php/conf.d/memory_limit.ini

RUN usermod -d $HOME www-data && chown -R www-data:www-data $HOME

RUN useradd --create-home --shell /bin/bash phpuser
RUN usermod -a -G sudo phpuser
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER phpuser

RUN export PATH="$PATH:vendor/bin"

WORKDIR /app/html

EXPOSE 80 443

ENTRYPOINT sudo nginx -c /etc/nginx/nginx.conf -g 'daemon off;'
