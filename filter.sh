#!/bin/bash

if [ $# -ne 3 ]; then
echo "Usage: ./monitor.sh <experiment_name> <number_of_nodes> <duration>"
echo "Example: ./monitor.sh my_experiment 2 10"
exit 1
fi  

echo "$(tput setaf 3)Compilation...$(tput setaf 7)"
make > /dev/null
echo "$(tput setaf 2)Compiled$(tput setaf 7)"

nodes="-l strasbourg,m3,1,build/iotlab/m3/coordinator.iotlab "
for i in $(seq 1 $2); do
    j=$((i + 1))
    nodes+="-l strasbourg,m3,$j,build/iotlab/m3/sender.iotlab "
done

echo "$(tput setaf 3)Submitting experiment...$(tput setaf 7)"
iotlab-experiment submit -n $1 -d $3 $nodes > /dev/null
iotlab-experiment wait 
echo "$(tput setaf 2)Experiment start$(tput setaf 7)"


# retrieve node names
iotlab-experiment get -n | grep "network_address" | sed 's/.*: "\(.*\)".*/\1/' > nodes.txt

echo "$(tput setaf 2)Retrieving info...$(tput setaf 7)"
if [ -z $4 ]; then
    for node in $(cat nodes.txt)
    do
        # retrieve TSCH & RPL info with netcat during 10s, simplify it and display it
        echo "$(tput setaf 3)Node $node :$(tput setaf 7)"
        # TODO: remove timeout and replace by thread, one thread per node that execute nc
        timeout 10 nc $node 20000 | (grep "TSCH" & grep "RPL") 
    done
fi

rm nodes.txt