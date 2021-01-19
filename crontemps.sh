#!/bin/bash
 mkdir /dev/shm/pizero/
 cd /dev/shm/pizero/

 if [ -d .git ]; then
  echo .git;
 else
  git clone https://github.com/chrisdotcollins/pizero-cron.git
 fi;

 TEMP_IS=$( ./gettemp.sh )
 DATE_IS=$( date +%Y-%m-%dT%H:%M:%S )
 git pull pizero-crontemp.log
 echo $DATE_IS $TEMP_IS > /dev/shm/pizero/pizero-crontemp.log
 git add /dev/shm/pizero/pizero-crontemp.log
 git commit -m "Updated pizero-crontemp.log"
 git push


