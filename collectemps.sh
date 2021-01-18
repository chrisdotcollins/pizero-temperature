#!/bin/bash

while true; do
 TEMP_IS=$( ./gettemp.sh )
# DATE_IS=$( date +%Y-%m-%dT%H:%M:%S )
 DATE_IS=$( date +%s )
 echo $DATE_IS,$TEMP_IS
 sleep 1
done

