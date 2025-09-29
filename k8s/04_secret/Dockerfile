FROM nginx:1.29.1-bookworm
COPY index.php default /tmp/
RUN apt update && apt install php-fpm php-mysql -y && apt autoremove && \
    rm -rf /usr/share/nginx/html/index* && cp /tmp/index.php /usr/share/nginx/html/ && \
    cp -f /tmp/default /etc/nginx/conf.d/default.conf 
