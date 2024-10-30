#!/bin/bash
PFAD=/home/mcserver/

if [[ -f "${PFAD}.paused" ]]; then
    rm "${PFAD}.paused"
fi
#sudo -u mcserver /home/resume.sh
#create .resume file in data directory
#touch /home/mcserver/.resume
#sudo -u mcserver rm /home/mcserver/.paused
#echo "Knockd wurde erfolgreich ausgelöst!" >> /tmp/knockd_triggered.log
#echo "Skript wird als Benutzer: $(whoami) ausgeführt" >> /tmp/knockd_triggered.log

