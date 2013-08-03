#!/bin/bash


check_exist () {
	if [ -a $@ ] ; then
		echo "RSDEPLOY CRITICAL : $@ exists"
		exit 2
	fi
}

check_exist "/etc/bird.conf.trip"
check_exist "/etc/bird6.conf.trip"
check_exist "/etc/bgpd.conf.trip"

echo 'RSDEPLOY OK'
exit 0

