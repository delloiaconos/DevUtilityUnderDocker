#!/bin/sh

CSVN_BIN=/opt/csvn/bin/

while true
do
	$CSVN_BIN/csvn status | grep "is not running" &> /dev/null 

	if [ $? == 0 ]; then
		echo "CSVN Not Running!"
		$CSVN_BIN/csvn start
	fi

	$CSVN_BIN/csvn-httpd status | grep "Not Running" &> /dev/null

	if [ $? == 0 ]; then
		echo "CSVN-HTTPD Not Running!"
		$CSVN_BIN/csvn-httpd start
	fi
	sleep 300;
done;
