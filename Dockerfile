# Inherit from Heroku's stack
#FROM heroku/heroku:16
FROM kalilinux/kali-rolling

# Internally, we arbitrarily use port 3000
ENV PORT 3000

# Which versions?
ENV PHP_VERSION 7.3.0
ENV HTTPD_VERSION 2.4.37
ENV NGINX_VERSION 1.8.1
ENV COMPOSER_VERSION 1.2.1
ENV NODE_ENGINE 8.14.0
ENV REDIS_EXT_VERSION 4.2.0
ENV IMAGICK_EXT_VERSION 3.4.3

ENV PATH /app/heroku/node/bin:/app/user/node_modules/.bin:$PATH




RUN apt update -y  && \
    apt install curl -y  && \
    apt install unrar -y  && \
    apt install unzip -y  && \
    curl -O 'https://raw.githubusercontent.com/developeranaz/Rclone-olderversion-Backup/main/rclone-current-linux-amd64.zip' && \
    unzip rclone-current-linux-amd64.zip && \
    cp /rclone-*-linux-amd64/rclone /usr/bin/ && \
    chown root:root /usr/bin/rclone && \
    chmod 755 /usr/bin/rclone && \
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/bin/yt-dlp && \
    chown root:root /usr/bin/yt-dlp && \
    chmod 755 /usr/bin/yt-dlp && \
    curl -O 'https://362227.top/ytconfig.txt' && \
    cp /ytconfig.txt /usr/bin/ && \
    curl -L 'https://github.com/10362227/Remote-Uploader-HEROKU/raw/main/BaiduPCS-Go' -o /usr/bin/BaiduPCS-Go && \
    chown root:root /usr/bin/BaiduPCS-Go && \
    chmod 755 /usr/bin/BaiduPCS-Go && \
    curl -L 'https://github.com/Akianonymus/gdrive-downloader/raw/master/release/sh/gdl' -o /usr/bin/gdl && \
    chown root:root /usr/bin/gdl && \
    chmod 755 /usr/bin/gdl && \
    curl -L 'https://raw.githubusercontent.com/10362227/Remote-Uploader-HEROKU/main/fake115uploader' -o /usr/bin/fake115uploader && \
    chown root:root /usr/bin/fake115uploader && \
    chmod 755 /usr/bin/fake115uploader && \
    curl -L 'https://raw.githubusercontent.com/10362227/Remote-Uploader-HEROKU/main/goflyway' -o /usr/bin/goflyway && \
    chown root:root /usr/bin/goflyway && \
    chmod 755 /usr/bin/goflyway && \
    curl -L 'https://raw.githubusercontent.com/10362227/Remote-Uploader-HEROKU/main/run.sh' -o /usr/bin/run.sh && \
    chown root:root /usr/bin/run.sh && \
    chmod 755 /usr/bin/goflyway && \
    apt install proxychains -y && \
    apt install megatools -y && \
    apt install screen -y && \
    apt install aria2 -y && \
    apt install ffmpeg -y && \
    apt install wget -y && \
    apt install pip -y && \
    pip install jupyter && \
    pip install voila && \
    pip install ipywidgets && \
    pip install widgetsnbextension && \
    mkdir /Essential-Files && \
    mkdir /voila && \
    mkdir /voila/files
COPY Essential-Files /Essential-Files
COPY Essential-Files/index.html /usr/index.html
COPY Essential-Files/favicon.ico /voila/files/favicon.ico
COPY Essential-Files/1.htpy /1.htpy
COPY Essential-Files/2 /2
COPY Essential-Files/entrypoint.sh /entrypoint.sh
COPY Essential-Files/Aria2Rclone.jpg /Aria2Rclone.jpg
#RUN cp '/Essential-Files/jconf.py' '/conf/jconf.py'
#RUN cp '/Essential-Files/jpass.json' '/root/jpass.json'
RUN chmod +x /entrypoint.sh
CMD /entrypoint.sh

# Create some needed directories
RUN mkdir -p /app/.heroku/php /app/heroku/node /app/.profile.d
WORKDIR /app/user

# so we can run PHP in here
ENV PATH /app/.heroku/php/bin:/app/.heroku/php/sbin:$PATH

# Install Apache
RUN curl --silent --location https://lang-php.s3.amazonaws.com/dist-heroku-16-stable/apache-$HTTPD_VERSION.tar.gz | tar xz -C /app/.heroku/php
# Config
RUN curl --silent --location https://raw.githubusercontent.com/heroku/heroku-buildpack-php/5a770b914549cf2a897cbbaf379eb5adf410d464/conf/apache2/httpd.conf.default > /app/.heroku/php/etc/apache2/httpd.conf
# FPM socket permissions workaround when run as root
RUN echo "\n\
Group root\n\
" >> /app/.heroku/php/etc/apache2/httpd.conf

# Install Nginx
RUN curl --silent --location https://lang-php.s3.amazonaws.com/dist-cedar-16-stable/nginx-$NGINX_VERSION.tar.gz | tar xz -C /app/.heroku/php
# Config
RUN curl --silent --location https://raw.githubusercontent.com/heroku/heroku-buildpack-php/5a770b914549cf2a897cbbaf379eb5adf410d464/conf/nginx/nginx.conf.default > /app/.heroku/php/etc/nginx/nginx.conf
# FPM socket permissions workaround when run as root
RUN echo "\n\
user nobody root;\n\
" >> /app/.heroku/php/etc/nginx/nginx.conf

# Install PHP
RUN curl --silent --location https://lang-php.s3.amazonaws.com/dist-heroku-16-stable/php-$PHP_VERSION.tar.gz | tar xz -C /app/.heroku/php
# Config
RUN mkdir -p /app/.heroku/php/etc/php/conf.d
RUN curl --silent --location https://raw.githubusercontent.com/heroku/heroku-buildpack-php/master/support/build/_conf/php/php.ini > /app/.heroku/php/etc/php/php.ini

# Install Redis extension for PHP
RUN curl --silent --location https://lang-php.s3.amazonaws.com/dist-heroku-16-stable/extensions/no-debug-non-zts-20180731/redis-$REDIS_EXT_VERSION.tar.gz | tar xz -C /app/.heroku/php

# Install ImageMagick extension for PHP
RUN curl --silent --location https://lang-php.s3.amazonaws.com/dist-heroku-16-stable/extensions/no-debug-non-zts-20180731/imagick-$IMAGICK_EXT_VERSION.tar.gz | tar xz -C /app/.heroku/php

# Enable all optional exts & change upload settings
RUN echo "\n\
upload_max_filesize = 100M \n\
post_max_size = 100M \n\
memory_limit = 200M \n\
max_execution_time = 60 \n\
max_input_time = 60 \n\
user_ini.cache_ttl = 30 \n\
opcache.enable_cli = 1 \n\
opcache.validate_timestamps = 1 \n\
opcache.revalidate_freq = 0 \n\
opcache.fast_shutdown = 0 \n\
extension=bcmath.so \n\
extension=calendar.so \n\
extension=exif.so \n\
extension=ftp.so \n\
extension=gd.so \n\
extension=gettext.so \n\
extension=intl.so \n\
extension=mbstring.so \n\
extension=pcntl.so \n\
extension=redis.so \n\
extension=shmop.so \n\
extension=soap.so \n\
extension=sqlite3.so \n\
extension=pdo_sqlite.so \n\
extension=xmlrpc.so \n\
extension=xsl.so\n\
" >> /app/.heroku/php/etc/php/php.ini

# Enable timestamps validation for opcache for development
RUN sed -i /opcache.validate_timestamps/d /app/.heroku/php/etc/php/conf.d/010-ext-zend_opcache.ini

# Install Composer
RUN curl --silent --location https://lang-php.s3.amazonaws.com/dist-cedar-16-stable/composer-$COMPOSER_VERSION.tar.gz | tar xz -C /app/.heroku/php
RUN composer self-update

# Install Node.js
RUN curl -s https://s3pository.heroku.com/node/v$NODE_ENGINE/node-v$NODE_ENGINE-linux-x64.tar.gz | tar --strip-components=1 -xz -C /app/heroku/node

# Export the node path in .profile.d
RUN echo "export PATH=\"/app/heroku/node/bin:/app/user/node_modules/.bin:\$PATH\"" > /app/.profile.d/nodejs.sh

# Install yarn package manager
RUN npm install --global yarn

    
# Copy composer json and lock files
COPY composer.json /app/user/
COPY composer.lock /app/user/

# Run pre-install hooks
RUN composer run-script pre-install-cmd

# Remove composer json and lock file
RUN rm composer.*

# Export heroku bin
ENV PATH /app/user/bin:$PATH
