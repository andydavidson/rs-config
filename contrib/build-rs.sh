perl RSBuild.pl -c cfgLonapPeers.cfg -b cfgTplConfigs.cfg
perl RPSLBuild.pl -c cfgLonapPeers.cfg -t tplRipeDB.tpl > send-to-ripe

# submit to RIPE bot:
# simple anti-break password/checksum:
CHECKSUM=`printf "JVMfBA1270 \`date +%F\`"|md5sum|awk '{print $1}'`
mail -s "Auto Submit:$CHECKSUM" ripebot@lonap.net < send-to-ripe

