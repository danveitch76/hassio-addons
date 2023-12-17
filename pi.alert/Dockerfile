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
RUN apt-get update && apt-get install cron whiptail apt-utils lighttpd php php-cgi php-fpm php-curl php-sqlite3 php-xml sqlite3 mmdb-bin arp-scan dnsutils net-tools libwww-perl libtext-csv-perl nmap zip wakeonlan aria2 python3 python3-pip python3-cryptography python3-requests -y
RUN lighttpd-enable-mod fastcgi-php
RUN service lighttpd restart
RUN pip3 -q install mac-vendor-lookup fritzconnection routeros_api pyunifi paho-mqtt --break-system-packages --no-warn-script-location 
RUN chmod go+x /root/pialert
RUN chgrp -R www-data "/root/pialert/db"
RUN chmod -R 775 "/root/pialert/db"
RUN chmod -R 775 "/root/pialert/db/temp"
RUN chgrp -R www-data "/root/pialert/config"
RUN chmod -R 775 "/root/pialert/config"
RUN chgrp -R www-data "/root/pialert/front/reports"
RUN chmod -R 775 "/root/pialert/front/reports"
RUN chgrp -R www-data "/root/pialert/back/speedtest/"
RUN chmod -R 775 "/root/pialert/back/speedtest/"
RUN chmod +x "/root/pialert/back/shoutrrr/arm64/shoutrrr"
RUN chmod +x "/root/pialert/back/shoutrrr/armhf/shoutrrr"
RUN chmod +x "/root/pialert/back/shoutrrr/x86/shoutrrr"
RUN touch "/root/pialert/log/pialert.vendors.log"
RUN touch "/root/pialert/log/pialert.1.log"
RUN touch "/root/pialert/log/pialert.cleanup.log"
RUN touch "/root/pialert/log/pialert.webservices.log"
RUN ln -s "/root/pialert/log/pialert.vendors.log" "/root/pialert/front/php/server/pialert.vendors.log"
RUN ln -s "/root/pialert/log/pialert.IP.log" "/root/pialert/front/php/server/pialert.IP.log"
RUN ln -s "/root/pialert/log/pialert.1.log" "/root/pialert/front/php/server/pialert.1.log"
RUN ln -s "/root/pialert/log/pialert.cleanup.log" "/root/pialert/front/php/server/pialert.cleanup.log"
RUN ln -s "/root/pialert/log/pialert.webservices.log" "/root/pialert/front/php/server/pialert.webservices.log"
RUN /root/pialert/back/pialert-cli set_sudoers
RUN ln -s "/root/pialert/front" "/var/www/html/pialert"
RUN rm -r "/etc/lighttpd/conf-available/pialert_front.conf"
RUN cp "/root/pialert/install/pialert_front.conf" "/etc/lighttpd/conf-available"
RUN rm -r "/etc/lighttpd/conf-enabled/pialert_front.conf"
RUN ln -s ../conf-available/pialert_front.conf "/etc/lighttpd/conf-enabled/pialert_front.conf"
RUN service lighttpd restart

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
