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

#  Update conf file
print_msg "- Config backup..."
# to force write permission, will be reverted later
sudo chmod 777 "/root/pialert/config/pialert.conf"
cp "/root/pialert/config/pialert.conf" "/root/pialert/config/pialert.conf.back"  2>&1 >> "$LOG"

print_msg "- Updating config file..."

# 2023-10-19
if ! grep -Fq "# Automatic Speedtest" "/root/pialert/config/pialert.conf" ; then
  cat << EOF >> "/root/pialert/config/pialert.conf"

# Automatic Speedtest
# ----------------------
SPEEDTEST_TASK_ACTIVE = False
SPEEDTEST_TASK_HOUR   = []
EOF
fi

# 2024-01-28
if ! grep -Fq "PUSHOVER_PRIO" "/root/pialert/config/pialert.conf" ; then
  cat << EOF >> "/root/pialert/config/pialert.conf"

PUSHOVER_PRIO = 0
PUSHSAFER_PRIO = 0
NETWORK_DNS_SERVER = 'localhost'
EOF
fi

# 2024-02-08
if ! grep -Fq "AUTO_UPDATE_CHECK" "/root/pialert/config/pialert.conf" ; then
  cat << EOF >> "/root/pialert/config/pialert.conf"

AUTO_UPDATE_CHECK      = True
EOF
fi

# 2024-02-21
if ! grep -Fq "NTFY_CLICKABLE" "/root/pialert/config/pialert.conf" ; then
  cat << EOF >> "/root/pialert/config/pialert.conf"

NTFY_CLICKABLE      = True
EOF
fi

# 2024-03-12
if ! grep -Fq "PUSHOVER_SOUND" "/root/pialert/config/pialert.conf" ; then
  cat << EOF >> "/root/pialert/config/pialert.conf"

PUSHOVER_SOUND      = 'siren'
PUSHSAFER_SOUND     = 22
EOF
fi

# 2024-04-07
if ! grep -Fq "AUTO_DB_BACKUP_CRON" "/root/pialert/config/pialert.conf" ; then
  cat << EOF >> "/root/pialert/config/pialert.conf"

AUTO_UPDATE_CHECK_CRON = '0 3,9,15,21 * * *'
AUTO_DB_BACKUP         = False
AUTO_DB_BACKUP_CRON    = '0 1 * * 1'
SPEEDTEST_TASK_CRON   = '0 7,22 * * *'
EOF
fi

# 2024-04-20
if ! grep -Fq "AUTO_DB_BACKUP_KEEP" "/root/pialert/config/pialert.conf" ; then
  cat << EOF >> "/root/pialert/config/pialert.conf"

AUTO_DB_BACKUP_KEEP    = 5
EOF
fi

# 2024-06-23
if ! grep -Fq "SATELLITES_ACTIVE" "/root/pialert/config/pialert.conf" ; then
  cat << EOF >> "/root/pialert/config/pialert.conf"

SATELLITES_ACTIVE = False

# Satellite Configuration
# -----------------------
SATELLITE_PROXY_MODE = False
SATELLITE_PROXY_URL = ''
EOF
fi

# 2024-07-12
if ! grep -Fq "REPORT_NEW_CONTINUOUS" "/root/pialert/config/pialert.conf" ; then
  cat << EOF >> "/root/pialert/config/pialert.conf"

REPORT_NEW_CONTINUOUS  = False
REPORT_NEW_CONTINUOUS_CRON = '0 * * * *'
EOF
fi

# 2024-08-20
if ! grep -Fq "PIHOLE_VERSION" "/root/pialert/config/pialert.conf" ; then
  cat << EOF >> "/root/pialert/config/pialert.conf"

PIHOLE_VERSION    = 5
PIHOLE6_URL       = ''
PIHOLE6_PASSWORD  = ''
IP_IGNORE_LIST  = []
EOF
fi

# 2024-08-28
if ! grep -Fq "NEW_DEVICE_PRESET_EVENTS" "/root/pialert/config/pialert.conf" ; then
  cat << EOF >> "/root/pialert/config/pialert.conf"

NEW_DEVICE_PRESET_EVENTS   = True
NEW_DEVICE_PRESET_DOWN     = False
EOF
fi

# 2024-09-24
if ! grep -Fq "DHCP_INCL_SELF_TO_LEASES" "/root/pialert/config/pialert.conf" ; then
  cat << EOF >> "/root/pialert/config/pialert.conf"

DHCP_INCL_SELF_TO_LEASES   = False
EOF
fi

# 2024-10-14
if ! grep -Fq "SYSTEM_TIMEZONE" "/root/pialert/config/pialert.conf" ; then
  cat << EOF >> "/root/pialert/config/pialert.conf"

SYSTEM_TIMEZONE            = 'Europe/Berlin'
OFFLINE_MODE               = False
EOF
fi

# 2024-10-29
if ! grep -Fq "REPORT_TO_ARCHIVE" "/root/pialert/config/pialert.conf" ; then
  cat << EOF >> "/root/pialert/config/pialert.conf"

REPORT_TO_ARCHIVE          = 0
# Number of hours after which a report is moved to the archive. The value 0 disables the feature

PIHOLE6_API_MAXCLIENTS     = 100
EOF
fi

exit 0
