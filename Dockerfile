FROM alpine:edge

# Add repos
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Add basics first
RUN apk update && apk upgrade && apk add \
	bash \
  nano \
  apache2 \
  php8-apache2 \
  curl \
  ca-certificates \
  openssl \
  openssh \
  git \
  mercurial \
  subversion \
  php8 \
  php8-phar \
  php8-json \
  php8-iconv \
  php8-openssl \
  tzdata \
  openntpd \
  unzip \
  mysql-client \
  shadow

# Setup apache and php
RUN apk add \
	php8-ftp \
	php8-mbstring \
	php8-soap \
	php8-gmp \
	php8-pdo_odbc \
	php8-dom \
	php8-pdo \
	php8-zip \
	php8-mysqli \
	php8-sqlite3 \
	php8-pdo_pgsql \
	php8-bcmath \
	php8-gd \
	php8-odbc \
	php8-pdo_mysql \
	php8-pdo_sqlite \
	php8-gettext \
	php8-xml \
	php8-xmlreader \
	php8-xmlwriter \
	php8-tokenizer \
	php8-bz2 \
	php8-pdo_dblib \
	php8-curl \
	php8-ctype \
	php8-session \
	php8-redis \
	php8-exif \
	php8-intl \
	php8-fileinfo \
	php8-ldap \
  php8-pecl-apcu \
  php8-pecl-mcrypt \
  php8-pecl-xdebug \
  php8-pecl-xmlrpc \
  php8-opcache

# Problems installing in above stack
RUN apk add php8-simplexml

RUN cp /usr/bin/php8 /usr/bin/php \
    && rm -f /var/cache/apk/*

# Add Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/

# Add wp-cli
COPY --from=wordpress:cli-php8.0 /usr/local/bin/wp /usr/bin/

# Add apache to run and configure
RUN sed -i "s/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_module/LoadModule\ session_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_cookie_module/LoadModule\ session_cookie_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ session_crypto_module/LoadModule\ session_crypto_module/" /etc/apache2/httpd.conf \
    && sed -i "s/#LoadModule\ deflate_module/LoadModule\ deflate_module/" /etc/apache2/httpd.conf

# set recommended PHP.ini settings

RUN sed -i "s/\;\?\\s\?cgi.fix_pathinfo\\s\?=\\s\?.*/cgi.fix_pathinfo = 0/" /etc/php8/php.ini

# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
	} > /etc/php8/conf.d/opcache-recommended.ini

RUN { \
		echo 'error_reporting = E_ERROR | E_WARNING | E_PARSE | E_CORE_ERROR | E_CORE_WARNING | E_COMPILE_ERROR | E_COMPILE_WARNING | E_RECOVERABLE_ERROR'; \
		echo 'display_errors = Off'; \
		echo 'display_startup_errors = Off'; \
		echo 'log_errors = On'; \
		echo 'error_log = /dev/stderr'; \
		echo 'log_errors_max_len = 1024'; \
		echo 'ignore_repeated_errors = On'; \
		echo 'ignore_repeated_source = Off'; \
		echo 'html_errors = Off'; \
	} > /etc/php8/conf.d/error-logging.ini

# Fix permissions
RUN usermod -u 1000 apache

COPY docker-entrypoint.sh /usr/local/bin/

WORKDIR /var/www/fleet
COPY fleet/ /var/www/fleet/
RUN cd /var/www/fleet && \
    composer install

EXPOSE 80
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["httpd", "-D", "FOREGROUND"]
