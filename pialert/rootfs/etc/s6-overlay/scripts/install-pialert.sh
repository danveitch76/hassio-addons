#!/bin/bash
# ------------------------------------------------------------------------------
#  Pi.Alert
#  Open Source Network Guard / WIFI & LAN intrusion detector 
#
#  install-pialert.sh - Install script for Hassio addon
# ------------------------------------------------------------------------------
#  danveitch76 2023                                        GNU GPLv3
# ------------------------------------------------------------------------------

# Tidy up pialert folder
if [ -e /root/pialert/install ]; then
	# Remove install folder from pialert folder
	rm -rf "/root/pialert/install"
fi

if [ -e /root/pialert/docs ]; then
	# Remove docs folder from pialert folder
	rm -rf "/root/pialert/docs"
fi

if [ -e /root/pialert/license.txt ]; then
	# Remove license file from pialert folder
	rm -rf "/root/pialert/LICENSE.txt"
fi

if [ -e /root/pialert/README.md ]; then
	# Remove readme file from pialert folder
	rm -rf "/root/pialert/README.md"
fi

# Setup DB location for persitent data
if [ -e /data/db ]; then
	# Remove DB folder from pialert folder
	rm -rf "/root/pialert/db"
else
	# First setup of DB folder
	mv "/root/pialert/db" "/data/"
fi
ln -s "/data/db/" "/root/pialert/db"

# Setup config location for persitent data
if [ -e /data/config ]; then
	# Replace Version File
	cp "/root/pialert/config/version.conf" "/data/config/"
	# Remove config folder from pialert folder
	rm -rf "/root/pialert/config"
else
	# First setup of config folder
	mv "/root/pialert/config" "/data/"
fi
ln -s "/data/config/" "/root/pialert/config"

# Create log files
if [ -e /root/pialert/log ]; then
	# Remove log folder from pialert folder
	rm -rf "/root/pialert/log"
else
	# First setup of log folder
	mkdir -p "/data/log/"
fi
ln -s "/data/log/" "/root/pialert/log"

touch "/root/pialert/log/access-pialert.log"
ln -s "/root/pialert/log/access-pialert.log" "/var/log/lighttpd/access.log"
touch "/root/pialert/log/error-pialert.log"
ln -s "/root/pialert/log/error-pialert.log" "/var/log/lighttpd/error.log"
touch "/root/pialert/log/pialert.vendors.log"
ln -s "/root/pialert/log/pialert.vendors.log" "/root/pialert/front/php/server/pialert.vendors.log"
ln -s "/root/pialert/log/pialert.IP.log" "/root/pialert/front/php/server/pialert.IP.log"
touch "/root/pialert/log/pialert.1.log"
ln -s "/root/pialert/log/pialert.1.log" "/root/pialert/front/php/server/pialert.1.log"
touch "/root/pialert/log/pialert.cleanup.log"
ln -s "/root/pialert/log/pialert.cleanup.log" "/root/pialert/front/php/server/pialert.cleanup.log"
touch "/root/pialert/log/pialert.webservices.log"
ln -s "/root/pialert/log/pialert.webservices.log" "/root/pialert/front/php/server/pialert.webservices.log"


# Set permissions on folders
chgrp -R www-data "/root/pialert/db"
chmod -R 775 "/root/pialert/db"
chmod -R 775 "/root/pialert/db/temp"
chgrp -R www-data "/root/pialert/log"
chmod -R 775 "/root/pialert/log"
chgrp -R www-data "/data/db"
chmod -R 775 "/data/db"
chmod -R 775 "/data/db/temp"
chgrp -R www-data "/data/log"
chmod -R 775 "/data/log"
chgrp -R www-data "/data/config"
chmod -R 775 "/data/config"

# Update DB
/root/pialert/back/pialert-cli update_db

exit 0
