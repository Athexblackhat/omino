if [[ "$FULLNMAPSCAN" = "0" ]]; then
  echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[`date +"%Y-%m-%d](%H:%M)"`${RESET}x•"
  echo -e "$OKRED SKIPPING FULL NMAP PORT SCAN $RESET"
  echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[`date +"%Y-%m-%d](%H:%M)"`${RESET}x•"
else
  echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[`date +"%Y-%m-%d](%H:%M)"`${RESET}x•"
  echo -e "$OKRED PERFORMING TCP PORT SCAN $RESET"
  echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[`date +"%Y-%m-%d](%H:%M)"`${RESET}x•"
  echo "[ominosecurity.com] •?((¯°·._.• Started omino full portscan: $TARGET [$MODE] (`date +"%Y-%m-%d %H:%M"`) •._.·°¯))؟•" >> $LOOT_DIR/scans/notifications_new.txt
  if [[ "$SLACK_NOTIFICATIONS" == "1" ]]; then
    /bin/bash "$INSTALL_DIR/bin/slack.sh" "[ominosecurity.com] •?((¯°·._.• Started omino full portscan: $TARGET [$MODE] (`date +"%Y-%m-%d %H:%M"`) •._.·°¯))؟•"
  fi
  mv -f $LOOT_DIR/nmap/ports-$TARGET.txt $LOOT_DIR/nmap/ports-$TARGET.old 2> /dev/null
  nmap $NMAP_OPTIONS -sU -sS --script=/usr/share/nmap/scripts/vulners -oX $LOOT_DIR/nmap/nmap-$TARGET.xml -p $FULL_PORTSCAN_PORTS $TARGET | tee $LOOT_DIR/nmap/nmap-$TARGET
  sed -r "s/</\&lh\;/g" $LOOT_DIR/nmap/nmap-$TARGET 2> /dev/null > $LOOT_DIR/nmap/nmap-$TARGET.txt 2> /dev/null
  rm -f $LOOT_DIR/nmap/nmap-$TARGET 2> /dev/null
  xsltproc $INSTALL_DIR/bin/nmap-bootstrap.xsl $LOOT_DIR/nmap/nmap-$TARGET.xml -o $LOOT_DIR/nmap/nmapreport-$TARGET.html 2> /dev/null
  cp -f $LOOT_DIR/nmap/nmapreport-$TARGET.html $LOOT_DIR/nmap/nmapreport-$TARGET-`date +"%Y-%m-%d-%H-%M"`.html 2> /dev/null
  if [[ "$SLACK_NOTIFICATIONS_NMAP" == "1" ]]; then
    /bin/bash "$INSTALL_DIR/bin/slack.sh" postfile "$LOOT_DIR/nmap/nmap-$TARGET.txt"
  fi
  sed -r "s/</\&lh\;/g" $LOOT_DIR/nmap/nmap-$TARGET-udp 2> /dev/null > $LOOT_DIR/nmap/nmap-$TARGET-udp.txt 2> /dev/null
  rm -f $LOOT_DIR/nmap/nmap-$TARGET 2> /dev/null
  HOST_UP=$(cat $LOOT_DIR/nmap/nmap-$TARGET.txt $LOOT_DIR/nmap/nmap-$TARGET-*.txt 2> /dev/null | grep "host up" 2> /dev/null)
  if [[ ${#HOST_UP} -ge 2 ]]; then
    echo "$TARGET" >> $LOOT_DIR/nmap/livehosts-unsorted.txt 2> /dev/null
  fi
  sort -u $LOOT_DIR/nmap/livehosts-unsorted.txt 2> /dev/null > $LOOT_DIR/nmap/livehosts-sorted.txt 2> /dev/null
  rm -f $LOOT_DIR/nmap/ports-$TARGET.txt 2> /dev/null
  for PORT in `cat $LOOT_DIR/nmap/nmap-$TARGET.xml $LOOT_DIR/nmap/nmap-$TARGET-*.xml 2>/dev/null | egrep 'state="open"' | cut -d' ' -f3 | cut -d\" -f2 | sort -u | grep '[[:digit:]]'`; do
    echo "$PORT " >> $LOOT_DIR/nmap/ports-$TARGET.txt
  done  
  diff $LOOT_DIR/nmap/ports-$TARGET.old $LOOT_DIR/nmap/ports-$TARGET.txt 2> /dev/null > $LOOT_DIR/nmap/ports-$TARGET.diff 2> /dev/null

  cat $LOOT_DIR/nmap/nmap-$TARGET.txt $LOOT_DIR/nmap/nmap-$TARGET-*.txt 2>/dev/null | egrep "MAC Address:" | awk '{print $3 " " $4 " " $5 " " $6}' > $LOOT_DIR/nmap/macaddress-$TARGET.txt 2> /dev/null

  cat $LOOT_DIR/nmap/nmap-$TARGET.txt $LOOT_DIR/nmap/nmap-$TARGET-*.txt $LOOT_DIR/output/nmap-$TARGET-*.txt 2>/dev/null | egrep "OS details:|OS guesses:" | cut -d\: -f2 | sed 's/,//g' | head -c50 - > $LOOT_DIR/nmap/osfingerprint-$TARGET.txt 2> /dev/null
  
  if [[ "$SLACK_NOTIFICATIONS_NMAP" == "1" ]]; then
    /bin/bash "$INSTALL_DIR/bin/slack.sh" postfile "$LOOT_DIR/nmap/nmap-$TARGET-udp.txt"
  fi
  if [[ -s "$LOOT_DIR/nmap/ports-$TARGET.diff" ]]; then
    if [[ "$SLACK_NOTIFICATIONS_NMAP_DIFF" == "1" ]]; then
      /bin/bash "$INSTALL_DIR/bin/slack.sh" "[ominosecurity.com] •?((¯°·._.• Port change detected on $TARGET (`date +"%Y-%m-%d %H:%M"`) •._.·°¯))؟•"
      /bin/bash "$INSTALL_DIR/bin/slack.sh" postfile "$LOOT_DIR/nmap/ports-$TARGET.diff"
    fi
    echo "[ominosecurity.com] •?((¯°·._.• Port change detected on $TARGET (`date +"%Y-%m-%d %H:%M"`) •._.·°¯))؟•" >> $LOOT_DIR/scans/notifications_new.txt
    cat $LOOT_DIR/nmap/ports-$TARGET.diff | egrep "<|>" >> $LOOT_DIR/scans/notifications_new.txt
  fi
  echo "[ominosecurity.com] •?((¯°·._.• Finished omino full portscan: $TARGET [$MODE] (`date +"%Y-%m-%d %H:%M"`) •._.·°¯))؟•" >> $LOOT_DIR/scans/notifications_new.txt
  if [[ "$SLACK_NOTIFICATIONS" == "1" ]]; then
    /bin/bash "$INSTALL_DIR/bin/slack.sh" "[ominosecurity.com] •?((¯°·._.• Finished omino full portscan: $TARGET [$MODE] (`date +"%Y-%m-%d %H:%M"`) •._.·°¯))؟•"
  fi
fi