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
RUN \
  #Installing dependencies... \
  apt install cron whiptail apt-utils lighttpd php php-cgi php-fpm php-curl php-sqlite3 php-xml sqlite3 mmdb-bin arp-scan dnsutils net-tools libwww-perl libtext-csv-perl nmap zip wakeonlan aria2 python3 python3-pip python3-cryptography python3-requests -y \
  # Setup lighttpd \
  lighttpd-enable-mod fastcgi-php \
  service lighttpd restart \
  # Setup PHP PIP packages \
  pip3 -q install mac-vendor-lookup fritzconnection routeros_api pyunifi paho-mqtt --break-system-packages --no-warn-script-location \
  # Set permissions \
  if [ -e "/var/www/html/pialert" ] || [ -L "/var/www/html/pialert" ] ; then \
    echo "- Deleting previous Pi.Alert site" \
    rm -r "/var/www/html/pialert" \
  fi \
  echo "- Setting permissions..." \
  chmod go+x /root/pialert \
  chgrp -R www-data "/root/pialert/db" \
  chmod -R 775 "/root/pialert/db" \
  chmod -R 775 "/root/pialert/db/temp" \
  chgrp -R www-data "/root/pialert/config" \
  chmod -R 775 "/root/pialert/config" \  
  chgrp -R www-data "/root/pialert/front/reports" \
  chmod -R 775 "/root/pialert/front/reports" \
  chgrp -R www-data "/root/pialert/back/speedtest/" \
  chmod -R 775 "/root/pialert/back/speedtest/" \
  chmod +x "/root/pialert/back/shoutrrr/arm64/shoutrrr" \
  chmod +x "/root/pialert/back/shoutrrr/armhf/shoutrrr" \
  chmod +x "/root/pialert/back/shoutrrr/x86/shoutrrr" \
  echo "- Create Logfile Symlinks..." \
  touch "/root/pialert/log/pialert.vendors.log" \
  touch "/root/pialert/log/pialert.1.log" \
  touch "/root/pialert/log/pialert.cleanup.log" \
  touch "/root/pialert/log/pialert.webservices.log" \
  ln -s "/root/pialert/log/pialert.vendors.log" "/root/pialert/front/php/server/pialert.vendors.log" \
  ln -s "/root/pialert/log/pialert.IP.log" "/root/pialert/front/php/server/pialert.IP.log" \
  ln -s "/root/pialert/log/pialert.1.log" "/root/pialert/front/php/server/pialert.1.log" \
  ln -s "/root/pialert/log/pialert.cleanup.log" "/root/pialert/front/php/server/pialert.cleanup.log" \
  ln -s "/root/pialert/log/pialert.webservices.log" "/root/pialert/front/php/server/pialert.webservices.log" \
  echo "- Set sudoers..." \
  /root/pialert/back/pialert-cli set_sudoers \
  echo "- Publishing Pi.Alert web..." \
  ln -s "/root/pialert/front" "/var/www/html/pialert" \
  echo "- Configuring http://pi.alert/ redirection..." \
  if [ -e "/etc/lighttpd/conf-available/pialert_front.conf" ] ; then \
    rm -r "/etc/lighttpd/conf-available/pialert_front.conf" \
  fi \
  cp "/root/pialert/install/pialert_front.conf" "/etc/lighttpd/conf-available" \
  if [ -e "/etc/lighttpd/conf-enabled/pialert_front.conf" ] || \
     [ -L "/etc/lighttpd/conf-enabled/pialert_front.conf" ] ; then \
    rm -r "/etc/lighttpd/conf-enabled/pialert_front.conf" \
  fi \
  ln -s ../conf-available/pialert_front.conf  "/etc/lighttpd/conf-enabled/pialert_front.conf" \
  echo "- Restarting lighttpd..." \
  service lighttpd restart \

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
