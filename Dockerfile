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