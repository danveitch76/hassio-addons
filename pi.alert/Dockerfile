ARG BUILD_FROM
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

FROM ${BUILD_FROM}

ARG BUILD_ARCH

# Setup base
ARG BUILD_ARCH
ARG CLI_VERSION

# Location of add-on persistent data directory.
WORKDIR /data

# Copy files required for add-on
COPY rootfs /

# Install requirements for add-on:
#RUN apt-get update && apt-get install cron whiptail apt-utils lighttpd php php-cgi php-fpm php-curl php-sqlite3 php-xml sqlite3 mmdb-bin arp-scan dnsutils net-tools libwww-perl libtext-csv-perl nmap zip wakeonlan aria2 python3 python3-pip python3-cryptography python3-requests -y
RUN apt-get update && apt-get install lighttpd
RUN lighttpd-enable-mod fastcgi-php accesslog
#RUN pip3 -q install mac-vendor-lookup fritzconnection routeros_api pyunifi paho-mqtt --break-system-packages --no-warn-script-location 
RUN touch "/data/pialert/log/pialert.vendors.log"
RUN touch "/data/pialert/log/pialert.1.log"
RUN touch "/data/pialert/log/pialert.cleanup.log"
RUN touch "/data/pialert/log/access-pialert.log"
RUN touch "/data/pialert/log/error-pialert.log"
RUN ln -s "/data/pialert/log/access-pialert.log" "/var/log/lighttpd/access-pialert.log"
RUN ln -s "/data/pialert/log/error-pialert.log" "/var/log/lighttpd/error-pialert.log"
RUN ln -s "/data/pialert/log/pialert.vendors.log" "/data/pialert/front/php/server/pialert.vendors.log"
RUN ln -s "/data/pialert/log/pialert.IP.log" "/data/pialert/front/php/server/pialert.IP.log"
RUN ln -s "/data/pialert/log/pialert.1.log" "/data/pialert/front/php/server/pialert.1.log"
RUN ln -s "/data/pialert/log/pialert.cleanup.log" "/data/pialert/front/php/server/pialert.cleanup.log"
RUN ln -s "/data/pialert/log/pialert.webservices.log" "/data/pialert/front/php/server/pialert.webservices.log"
RUN ln -s "/data/pialert/front" "/var/www/html/pialert"
RUN ln -s "/data/pialert/install/pialert_front.conf" "/etc/lighttpd/conf-available"
RUN ln -s "/etc/lighttpd/conf-available/pialert_front.conf" "/etc/lighttpd/conf-enabled/pialert_front.conf"
RUN ln -s "/usr/bin/python3" "/usr/bin/python"
RUN (crontab -l 2>/dev/null || : ; cat /data/pialert/install/pialert.cron) | crontab -
RUN mv "/var/www/html/index.html" "/var/www/html/index.html.orig"
RUN ln -s "/data/pialert/install/index.html" "/var/www/html/index.html"
RUN ln -s "/usr/share/ieee-data/" "/var/lib/ieee-data"
RUN ln -s "/data/pialert/config/lighttpd.conf" "/etc/lighttpd/lighttpd.conf"
RUN sed -i 's/error.log/error-pialert.log/g' /etc/lighttpd/lighttpd.conf
RUN echo 'accesslog.filename          = "/var/log/lighttpd/access-pialert.log"' | tee -a /etc/lighttpd/lighttpd.conf
RUN chmod -R go+x /data/pialert
RUN chmod -R +x /data/pialert/*.sh
RUN chmod -R +x /data/pialert/*.py
RUN chmod -R +x /data/pialert/back/pialert-cli
RUN chmod -R +x /data/pialert/back/speedtest-cli
RUN chgrp -R www-data "/data/pialert/db"
RUN chmod -R 775 "/data/pialert/db"
RUN chmod -R 775 "/data/pialert/db/temp"
RUN chgrp -R www-data "/data/pialert/config"
RUN chmod -R 775 "/data/pialert/config"
RUN chgrp -R www-data "/data/pialert/front/reports"
RUN chmod -R 775 "/data/pialert/front/reports"
RUN chgrp -R www-data "/data/pialert/back/speedtest/"
RUN chmod -R 775 "/data/pialert/back/speedtest/"
RUN chmod +x "/data/pialert/back/shoutrrr/arm64/shoutrrr"
RUN chmod +x "/data/pialert/back/shoutrrr/armhf/shoutrrr"
RUN chmod +x "/data/pialert/back/shoutrrr/x86/shoutrrr"

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Dan Veitch <@danveitch76>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Dan Add-ons" \
    org.opencontainers.image.authors="Dan Veitch <@danveitch76>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/danveitch76/hassio-addons" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
