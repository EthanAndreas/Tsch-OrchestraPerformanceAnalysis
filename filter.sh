#!/bin/bash

if [ $# -ne 2 ]; then
echo "Usage: ./filter.sh <experiment_name> <number_of_nodes>"
echo "Example: ./filter.sh my_experiment 2"
exit 1
fi

echo "\033[92mCompilation...\033[0m"
make > /dev/null
echo "$(tput setaf 2) Tests ended $(tput setaf 7)"
nodes=""
for i in $(seq 1 $2); do
    j=$((i + 1))
    nodes+="-l strasbourg,m3,$j,build/iotlab/m3/sender.iotlab "
done
echo "$(tput setaf 2)Submitting experiment...$(tput setaf 7)"
iotlab-experiment submit -n $1 -d 20 -l strasbourg,m3,1,build/iotlab/m3/coordinator.iotlab $nodes > /dev/null
iotlab-experiment wait
echo "$(tput setaf 2)Experiment start$(tput setaf 7)"


# retrieve node names
iotlab-experiment get -n | grep "network_address" | sed 's/.*: "\(.*\)".*/\1/' > nodes.txt

echo "$(tput setaf 2)Retrieving info...$(tput setaf 7)"
for node in $(cat nodes.txt)
do
    # retrieve TSCH & RPL info with netcat during 10s, simplify it and display it
    echo "Node $node :"
    timeout 10 nc $node 20000 | (grep "TSCH" & grep "RPL") 
done