FROM alpine:latest

RUN apk --update --no-cache add curl ca-certificates nginx
RUN apk add php8 php8-xml php8-xmlwriter php8-xmlreader php8-exif php8-fpm php8-session php8-soap php8-openssl php8-gmp libxml2 php8-curl php8-ctype php8-dom php8-gd php8-json php8-mbstring php8-posix php8-session php8-simplexml php8-zip php8-zlib php8-pdo_mysql php8-pdo_sqlite php8-fileinfo php8-bz2 php8-intl php8-ftp php8-imap php8-bcmath php8-gmp php8-exif php8-pcntl redis ffmpeg libreoffice
COPY --from=composer:latest  /usr/bin/composer /usr/bin/composer

USER container
ENV  USER container
ENV HOME /home/container

WORKDIR /home/container
COPY ./entrypoint.sh /entrypoint.sh


CMD ["/bin/ash", "/entrypoint.sh"]
LABEL org.opencontainers.image.source="https://github.com/Dragon-Node/nextcloud-image"
