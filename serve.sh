#!/bin/sh

#./collectemps.sh > /dev/shm/log.txt &

#../websocketd --port=8080 --staticdir=./static --sameorigin=true tail -f /dev/shm/log.txt
./websocketd --port=8080 --staticdir=./static --sameorigin=true ./collectemps.sh

