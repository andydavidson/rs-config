perl RSBuild.pl -c cfgLonapPeers.cfg -b cfgTplConfigs.cfg
perl RPSLBuild.pl -c cfgLonapPeers.cfg -t tplRipeDB.tpl > send-to-ripe

# submit to RIPE bot:
# simple anti-break password/checksum:
CHECKSUM=`printf "fake-password \`date +%F\`"|md5sum|awk '{print $1}'`
mail -s "Auto Submit:$CHECKSUM" auto-dbm@ripe.net < send-to-ripe

