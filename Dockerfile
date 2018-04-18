FROM php:7.1-apache
COPY composer-installer.sh /usr/local/bin/composer-installer

# Install composer
RUN apt-get -yqq update \
    && apt-get -yqq install --no-install-recommends unzip \
    && chmod +x /usr/local/bin/composer-installer \
    && composer-installer \
    && mv composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    && composer --version

# Cache Composer dependencies
WORKDIR /tmp
# Copies the composer.json, composer.lock and auth.json files into
#  the temporary folder (/tmp/) with the ADD instruction. When using ADD with more
#  than one source file, the destination (/tmp/) must be a directory and end with a
#  forward slash.
ADD app/composer.json app/composer.lock app/auth.json /tmp/
# Additionally, we need the database/ folder so the installation doesn't fail; the
#  database/seeds and database/factories paths are defined in the Composer autoload and
#  must exist.
# The final Docker instruction in the cache step removes the files installed in the
#  /tmp/vendor/ folder. We don't need them anymore because the vendor files get copied
#  from Composer's cache during the second composer install. The cached vendor files
#  remain in the layer (~/.composer/cache), so we can use them later.
RUN mkdir -p database/seeds \
    mkdir -p database/factories \
    && composer install \
        --no-interaction \
        --no-plugins \
        --no-scripts \
        --prefer-dist \
    && rm -rf composer.json composer.lock auth.json \
        database/ vendor/
#END. Cache Composer dependencies

# Add the project
ADD app /var/www/html

WORKDIR /var/www/html

RUN composer install \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist


# Alternative way to install composer: https://stackoverflow.com/a/42147748
#FROM php:7.1-apache
#RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
#    && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
#    && php -r "if (hash('SHA384',file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
#    && php /tmp/composer-setup.php \
#        --no-ansi \
#        --install-dir=/usr/local/bin \
#        --filename=composer \
#        --snapshot \
#    && rm -f /tmp/composer-setup.*