#!/bin/bash

./submit.sh $1 $2 $3 $4

# retrieve node names
iotlab-experiment get -n | grep "network_address" | sed 's/.*: "\(.*\)".*/\1/' > nodes.txt

echo "$(tput setaf 2)Retrieving info...$(tput setaf 7)"
for node in $(cat nodes.txt)
do
    # retrieve TSCH & RPL info with netcat during 10s, simplify it and display it
    echo "$(tput setaf 3)Node $node :$(tput setaf 7)"
    # TODO: remove timeout and replace by thread, one thread per node that execute nc
    timeout 10 nc $node 20000 | (grep "TSCH" & grep "RPL") 
done

rm nodes.txt > /dev/null 2>&1