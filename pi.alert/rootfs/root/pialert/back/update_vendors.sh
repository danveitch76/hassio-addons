#!/bin/sh
# ------------------------------------------------------------------------------
#  Pi.Alert
#  Open Source Network Guard / WIFI & LAN intrusion detector 
#
#  update_vendors.sh - Back module. IEEE Vendors db update
# ------------------------------------------------------------------------------
#  Puche 2021        pi.alert.application@gmail.com        GNU GPLv3
# ------------------------------------------------------------------------------

# ----------------------------------------------------------------------
#  Main directories to update:
#    /usr/share/arp-scan
#    /usr/share/ieee-data
#    /var/lib/ieee-data
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
echo "Updating... /usr/share/ieee-data/"
cd /usr/share/ieee-data/

aria2c --dir=/usr/share/ieee-data --max-connection-per-server=3 --allow-overwrite=true --quiet=true "https://standards-oui.ieee.org/oui/oui.csv"
aria2c --dir=/usr/share/ieee-data --max-connection-per-server=3 --allow-overwrite=true --quiet=true "https://standards-oui.ieee.org/oui/oui.txt"
aria2c --dir=/usr/share/ieee-data --max-connection-per-server=3 --allow-overwrite=true --quiet=true "https://standards-oui.ieee.org/oui36/oui36.csv"
aria2c --dir=/usr/share/ieee-data --max-connection-per-server=3 --allow-overwrite=true --quiet=true "https://standards-oui.ieee.org/oui36/oui36.txt"
aria2c --dir=/usr/share/ieee-data --max-connection-per-server=3 --allow-overwrite=true --quiet=true "https://standards-oui.ieee.org/oui28/mam.csv"
aria2c --dir=/usr/share/ieee-data --max-connection-per-server=3 --allow-overwrite=true --quiet=true "https://standards-oui.ieee.org/oui28/mam.txt"
aria2c --dir=/usr/share/ieee-data --max-connection-per-server=3 --allow-overwrite=true --quiet=true "https://standards-oui.ieee.org/iab/iab.csv"
aria2c --dir=/usr/share/ieee-data --max-connection-per-server=3 --allow-overwrite=true --quiet=true "https://standards-oui.ieee.org/iab/iab.txt"

# ----------------------------------------------------------------------
echo ""
echo "Updating... /usr/share/arp-scan/"
cd /usr/share/arp-scan

# Update from /var/lib/ieee-data
get-oui -v

# Update from ieee website
# get-iab -v -u https://standards-oui.ieee.org/iab/iab.txt
# get-oui -v -u https://standards-oui.ieee.org/oui/oui.txt

# Update from Sanitized oui (linuxnet.ca)
# get-oui -v -u https://linuxnet.ca/ieee/oui.txt

