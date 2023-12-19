#!/usr/bin/env python

## Tiny Syslog Server in Python.
##
## https://gist.github.com/marcelom/4218010
##
## This is a tiny syslog server that is able to receive UDP based syslog
## entries on a specified port and save them to a file.
## That's it... it does nothing else...
## There are a few configuration parameters.

from config import (
    CUSTOM_HOST,
    CUSTOM_PORT,
    CUSTOM_LOG_FILE,
    DEBUG_MODE
)

#LOG_FILE = 'youlogfile.log'
#HOST, PORT = "0.0.0.0", 514
print('DEBUG_MODE: '+DEBUG_MODE)
#
# NO USER SERVICEABLE PARTS BELOW HERE...
#

#import logging
import socketserver
import os
#from requests import post

#logging.basicConfig(level=logging.INFO, format='%(message)s', datefmt='', filename=CUSTOM_LOG_FILE, filemode='a')

class SyslogUDPHandler(socketserver.BaseRequestHandler):

	def handle(self):
		data = bytes.decode(self.request[0].strip())
		socket = self.request[1]
		#if DEBUG_MODE: print( "%s : " % self.client_address[0], str(data));
		#logging.info(str(data))
		log_file = open(CUSTOM_LOG_FILE, 'at')
		log_file.write(str(data)+'\n')
		log_file.close()


if __name__ == "__main__":
	try:
		server = socketserver.UDPServer((CUSTOM_HOST,CUSTOM_PORT), SyslogUDPHandler)
		server.serve_forever(poll_interval=0.5)
	except (IOError, SystemExit):
		raise
	except KeyboardInterrupt:
		print ("Crtl+C Pressed. Shutting down.")
