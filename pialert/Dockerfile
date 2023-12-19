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
RUN apt-get update && apt-get install cron whiptail apt-utils lighttpd php php-cgi php-fpm php-curl php-sqlite3 php-xml sqlite3 mmdb-bin arp-scan dnsutils net-tools libwww-perl libtext-csv-perl nmap zip wakeonlan aria2 python3 python3-pip python3-cryptography python3-requests iproute2 -y

# Setup lighttpd:
RUN lighttpd-enable-mod fastcgi-php accesslog
RUN service lighttpd restart

# Install pip dependencies for pi.alert:
RUN pip3 -q install mac-vendor-lookup fritzconnection routeros_api pyunifi paho-mqtt --break-system-packages --no-warn-script-location 

# Setup links used for pialert
RUN ln -s "/usr/bin/python3" "/usr/bin/python"

# Setup pialert website
RUN ln -s "/root/pialert/front" "/var/www/html/pialert"
RUN ln -s "/root/pialert/config/pialert_front.conf" "/etc/lighttpd/conf-available"
RUN ln -s "/etc/lighttpd/conf-available/pialert_front.conf" "/etc/lighttpd/conf-enabled/pialert_front.conf"

# Setup crontab to run services
RUN (crontab -l 2>/dev/null || : ; cat /root/pialert/config/pialert.cron) | crontab -

# Set default site to pialert
RUN mv "/var/www/html/index.html" "/var/www/html/index.html.orig"
RUN ln -s "/root/pialert/config/index.html" "/var/www/html/index.html"

# Change lighttpd config to pialert version
RUN mv "/etc/lighttpd/lighttpd.conf" "/etc/lighttpd/lighttpd.conf.orig"
RUN ln -s "/root/pialert/config/lighttpd.conf" "/etc/lighttpd/lighttpd.conf"

# Set permissions on folders
RUN chmod -R +x /etc/s6-overlay/scripts/*.sh

RUN chmod -R go+x /root/pialert
RUN chmod -R +x /root/pialert/back/*.sh
RUN chmod -R +x /root/pialert/back/*.py
RUN chmod -R +x /root/pialert/back/pialert-cli
RUN chmod -R +x /root/pialert/back/speedtest-cli
RUN chgrp -R www-data "/root/pialert/config"
RUN chmod -R 775 "/root/pialert/config"
RUN chgrp -R www-data "/root/pialert/front/reports"
RUN chmod -R 775 "/root/pialert/front/reports"
RUN chgrp -R www-data "/root/pialert/back/speedtest/"
RUN chmod -R 775 "/root/pialert/back/speedtest/"
RUN chmod +x "/root/pialert/back/shoutrrr/arm64/shoutrrr"
RUN chmod +x "/root/pialert/back/shoutrrr/armhf/shoutrrr"
RUN chmod +x "/root/pialert/back/shoutrrr/x86/shoutrrr"

# Configure Mac Address database
RUN ln -s "/usr/share/ieee-data/" "/var/lib/ieee-data"

# Update Vendors
RUN aria2c --dir=/usr/share/ieee-data --max-connection-per-server=3 --allow-overwrite=true --quiet=true "https://standards-oui.ieee.org/oui/oui.csv"
RUN aria2c --dir=/usr/share/ieee-data --max-connection-per-server=3 --allow-overwrite=true --quiet=true "https://standards-oui.ieee.org/oui/oui.txt"
RUN aria2c --dir=/usr/share/ieee-data --max-connection-per-server=3 --allow-overwrite=true --quiet=true "https://standards-oui.ieee.org/oui36/oui36.csv"
RUN aria2c --dir=/usr/share/ieee-data --max-connection-per-server=3 --allow-overwrite=true --quiet=true "https://standards-oui.ieee.org/oui36/oui36.txt"
RUN aria2c --dir=/usr/share/ieee-data --max-connection-per-server=3 --allow-overwrite=true --quiet=true "https://standards-oui.ieee.org/oui28/mam.csv"
RUN aria2c --dir=/usr/share/ieee-data --max-connection-per-server=3 --allow-overwrite=true --quiet=true "https://standards-oui.ieee.org/oui28/mam.txt"
RUN aria2c --dir=/usr/share/ieee-data --max-connection-per-server=3 --allow-overwrite=true --quiet=true "https://standards-oui.ieee.org/iab/iab.csv"
RUN aria2c --dir=/usr/share/ieee-data --max-connection-per-server=3 --allow-overwrite=true --quiet=true "https://standards-oui.ieee.org/iab/iab.txt"

# Update from /var/lib/ieee-data
RUN cd /usr/share/arp-scan && get-oui -v

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
