# Alpine LAP Server with Extensions

Provides a basic LAP stack using Alpine, Apache2 and php8, loading in the various extensions along the way (see Dockerfile for full list).

Should allow you to get going with a full LAP stack and support for DB via linked container (such as mysql) with ease, allowing you to fine tune various aspects of the server and php via environment variables.

## Included in this image

bash, apache2, php8, php8-apache2, curl, ca-certificates, git, mercurial, subversion, unzip, nano

php8-phar, php8-json, php8-iconv, php8-openssl, php8-ftp, php8-mbstring, php8-soap, php8-gmp, php8-pdo_odbc, php8-dom, php8-pdo, php8-zip, php8-mysqli, php8-sqlite3, php8-pdo_pgsql, php8-bcmath, php8-gd, php8-odbc, php8-pdo_mysql, php8-pdo_sqlite, php8-gettext, php8-xml, php8-xmlreader, php8-xmlwriter, php8-tokenizer, php8-bz2, php8-pdo_dblib, php8-curl, php8-ctype, php8-session, php8-redis, php8-exif, php8-intl, php8-fileinfo, php8-ldap, php8-pecl-apcu, php8-pecl-mcrypt, php8-pecl-xdebug, php8-pecl-xmlrpc, php8-opcache php8-simplexml

## Environment Variables

Various env vars can be set at runtime via your docker command or docker-compose environment section.

**APACHE_DOCUMENT_ROOT:** Change document root in httpd.conf (Default: /app/public)

**APACHE_SERVER_NAME:** Change server name to match your domain name in httpd.conf

**PHP_SHORT_OPEN_TAG:** Maps to php.ini 'short_open_tag'

**PHP_OUTPUT_BUFFERING:** Maps to php.ini 'output_buffering'

**PHP_OPEN_BASEDIR:** Maps to php.ini 'open_basedir'

**PHP_MAX_EXECUTION_TIME:** Maps to php.ini 'max_execution_time'

**PHP_MAX_INPUT_TIME:** Maps to php.ini 'max_input_time'

**PHP_MAX_INPUT_VARS:** Maps to php.ini 'max_input_vars'

**PHP_MEMORY_LIMIT:** Maps to php.ini 'memory_limit'

**PHP_ERROR_REPORTING:** Maps to php.ini 'error_reporting'

**PHP_DISPLAY_ERRORS:** Maps to php.ini 'display_errors'

**PHP_DISPLAY_STARTUP_ERRORS:** Maps to php.ini 'display_startup_errors'

**PHP_LOG_ERRORS:** Maps to php.ini 'log_errors'

**PHP_LOG_ERRORS_MAX_LEN:** Maps to php.ini 'log_errors_max_len'

**PHP_IGNORE_REPEATED_ERRORS:** Maps to php.ini 'ignore_repeated_errors'

**PHP_REPORT_MEMLEAKS:** Maps to php.ini 'report_memleaks'

**PHP_HTML_ERRORS:** Maps to php.ini 'html_errors'

**PHP_ERROR_LOG:** Maps to php.ini 'error_log'

**PHP_POST_MAX_SIZE:** Maps to php.ini 'post_max_size'

**PHP_DEFAULT_MIMETYPE:** Maps to php.ini 'default_mimetype'

**PHP_DEFAULT_CHARSET:** Maps to php.ini 'default_charset'

**PHP_FILE_UPLOADS:** Maps to php.ini 'file_uploads'

**PHP_UPLOAD_TMP_DIR:** Maps to php.ini 'upload_tmp_dir'

**PHP_UPLOAD_MAX_FILESIZE:** Maps to php.ini 'upload_max_filesize'

**PHP_MAX_FILE_UPLOADS:** Maps to php.ini 'max_file_uploads'

**PHP_ALLOW_URL_FOPEN:** Maps to php.ini 'allow_url_fopen'

**PHP_ALLOW_URL_INCLUDE:** Maps to php.ini 'allow_url_include'

**PHP_DEFAULT_SOCKET_TIMEOUT:** Maps to php.ini 'default_socket_timeout'

**PHP_DATE_TIMEZONE:** Maps to php.ini 'date.timezone'

**PHP_PDO_MYSQL_CACHE_SIZE:** Maps to php.ini 'pdo_mysql.cache_size'

**PHP_PDO_MYSQL_DEFAULT_SOCKET:** Maps to php.ini 'pdo_mysql.default_socket'

**PHP_SESSION_SAVE_HANDLER:** Maps to php.ini 'session.save_handler'

**PHP_SESSION_SAVE_PATH:** Maps to php.ini 'session.save_path'

**PHP_SESSION_USE_STRICT_MODE:** Maps to php.ini 'session.use_strict_mode'

**PHP_SESSION_USE_COOKIES:** Maps to php.ini 'session.use_cookies'

**PHP_SESSION_COOKIE_SECURE:** Maps to php.ini 'session.cookie_secure'

**PHP_SESSION_NAME:** Maps to php.ini 'session.name'

**PHP_SESSION_COOKIE_LIFETIME:** Maps to php.ini 'session.cookie_lifetime'

**PHP_SESSION_COOKIE_PATH:** Maps to php.ini 'session.cookie_path'

**PHP_SESSION_COOKIE_DOMAIN:** Maps to php.ini 'session.cookie_domain'

**PHP_SESSION_COOKIE_HTTPONLY:** Maps to php.ini 'session.cookie_httponly'

**PHP_XDEBUG_ENABLED:** Add this env and give it a value to turn it on, such as true, or On or Awesome, or beer, or socks... Turns on xdebug (which is not for production really)

## Usage

To use this image directly, you can use a docker-compose file to keep things nice and simple... if you have a load balancer like traefik and mysql containers running on another docker network, you may have something like this...

```yml
version: '2'
services:
  myservice:
    build: ./
    labels:
      - 'traefik.backend=myservice'
      - 'traefik.frontend.rule=Host:myservice.docker.localhost'
    environment:
      - MYSQL_HOST=mysql
      - APACHE_SERVER_NAME=myservice.docker.localhost
      - PHP_SHORT_OPEN_TAG=On
      - PHP_ERROR_REPORTING=E_ALL
      - PHP_DISPLAY_ERRORS=On
      - PHP_HTML_ERRORS=On
      - PHP_XDEBUG_ENABLED=true
    networks:
      - default
    volumes:
      - ./:/app
    # ADD in permission for setting system time to host system time
    cap_add:
      - SYS_TIME
      - SYS_NICE
networks:
  default:
    external:
      name: docker_docker-localhost
```

Then run...

```sh
docker-compose up -d
```

This will patch the container through to traefik load balancer running from another dc file.

If you would like to add to this, expand on this, maybe you don't want to map your volume and want to copy files for a production system. You can create your own Dockerfile based on this image...

```dockerfile
FROM dre1080/alpine-apache-php8

ENV APACHE_DOCUMENT_ROOT /srv/web
ENV PHP_MEMORY_LIMIT 256M

COPY public /srv/web
```

## Where Do I Put My Files

Your public access files should be located at `APACHE_DOCUMENT_ROOT`. This allows you to have your src files and other outside your public directory.
