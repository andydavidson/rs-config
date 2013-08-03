#!/bin/bash

SVNBASE=svn+ssh://rs@svn.lonap.net/var/svn-repos/lonapvc/rs-config/

case "$1" in
	bird)
		CFGFILE=bird.conf
		MAXCHANGES=8000
		RELOADCMD='birdc configure soft'
		;;
	bird6)
		CFGFILE=bird6.conf
		MAXCHANGES=500
		RELOADCMD='birdc6 configure soft'
		;;
	bgpd)	
		CFGFILE=bgpd.conf
		MAXCHANGES=8000
		RELOADCMD='bgpctl reload'
		;;
	*)
		echo "Invoke with bird, bird6, or bgpd"
		exit 1
esac

if [ -a /etc/$CFGFILE.trip ] ; then
		# we tripped MAXCHANGES last time we ran, so exit 
		echo "Not doing anything as /etc/$CFGFILE.trip exists"
		echo "Remove this file to force a build next time"
		exit 1
fi


TMP=`mktemp -t $CFGFILE.XXXXXXXXXX` || exit 1

svn -q export $SVNBASE$CFGFILE $TMP

CHANGES=`diff $TMP /etc/$CFGFILE | wc -l`

if [ -a /etc/$CFGFILE.ignoremaxchanges ] ; then
	# ignore the maxchanges limit
	echo "Ignoring MAXCHANGES limit ($MAXCHANGES) for $CFGFILE, going ahead with $CHANGES changes"
	rm /etc/$CFGFILE.ignoremaxchanges
elif [ $CHANGES -ge $MAXCHANGES ] ; then
	# diff is large, bail out
	echo "Diff for new $CFGFILE is $CHANGES lines, bigger than configured max of $MAXCHANGES"
	echo "rm $HOSTNAME:/etc/$CFGFILE.trip and MAXCHANGES limit will be ignored next time"
	touch /etc/$CFGFILE.trip
      	touch /etc/$CFGFILE.ignoremaxchanges
      	rm $TMP
      	exit 1
fi

if [ $CHANGES -gt 4 ] ; then
	# config has changed (excluding header)
	# OK, now we deploy the config
	mv /etc/$CFGFILE /etc/$CFGFILE.old-rsdeploy
	mv $TMP /etc/$CFGFILE
	chmod 600 /etc/$CFGFILE
	# now do the config reload
	$RELOADCMD
fi

if [ -a $TMP ] ; then
	rm $TMP
fi


