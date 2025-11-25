FROM goofball222/pritunl:latest
RUN apk add --no-cache wireguard-tools ca-certificates openssl nginx php81-pdo_mysql php-fpm php-curl php-gd php-intl php-pear php-imap php81-pecl-memcache php81-pecl-imagick
RUN sed -i '2a\nginx ; php-fpm81' /usr/local/bin/docker-entrypoint.sh
ADD   pritunl-fake-api.conf /etc/nginx/http.d/default.conf
ADD www/ /var/www/html/
ADD hard_nginx.conf /etc/nginx/nginx.conf
ADD setup.py  /opt/pritunl/
RUN python /opt/pritunl/setup.py --install --api-server ""
ADD cert.sh /opt/pritunl/
RUN sh /opt/pritunl/cert.sh
ENV SSL_CERT_FILE=/usr/local/share/ca-certificates/myca.crt
ENV REQUESTS_CA_BUNDLE=/usr/local/share/ca-certificates/myca.crt
