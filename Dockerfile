FROM php:7.4-fpm AS libretime-legacy

ENV LIBRETIME_CONFIG_FILEPATH=/home/container/config.yml
ENV LIBRETIME_LOG_FILEPATH=php://stderr

# Custom user
ARG USER=root
ARG UID=1000
ARG GID=1000

RUN set -eux \
    && adduser --disabled-password --uid=$UID --gecos '' --no-create-home ${USER} \
    && install --directory --owner=${USER} /etc/libretime /srv/libretime

RUN set -eux \
    && DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    gettext \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libonig-dev \
    libpng-dev \
    libpq-dev \
    libxml2-dev \
    libyaml-dev \
    libzip-dev \
    locales \
    unzip \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && pecl install apcu yaml \
    && docker-php-ext-enable apcu yaml \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    bcmath \
    curl \
    exif \
    gd \
    gettext \
    mbstring \
    opcache \
    pdo_pgsql \
    pgsql \
    sockets \
    xml

COPY legacy/locale/locale.gen /etc/locale.gen
RUN locale-gen

COPY "legacy/install/php/libretime-legacy.ini" "/home/container/php-fpm/conf.d/"

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

WORKDIR /home/container/webroot

COPY legacy/composer.* ./
RUN composer --no-cache install --no-progress --no-interaction --no-dev --no-autoloader

COPY legacy .
RUN set -eux \
    && make locale-build \
    && composer --no-cache dump-autoload --no-interaction --no-dev

# Run
USER ${UID}:${GID}

ARG LIBRETIME_VERSION
ENV LIBRETIME_VERSION=$LIBRETIME_VERSION

RUN apt-get install curl ca-certificates nginx
COPY --from=composer:latest  /usr/bin/composer /usr/bin/composer

USER container
ENV  USER container
ENV HOME /home/container

WORKDIR /home/container


COPY ./entrypoint.sh /entrypoint.sh


CMD ["/bin/ash", "/entrypoint.sh"]
LABEL org.opencontainers.image.source="https://github.com/FavoShane/radio-image"
