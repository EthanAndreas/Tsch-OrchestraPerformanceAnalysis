#!/bin/bash

if [ $# -ne 2 ]; then
echo "Usage: ./filter.sh <experiment_name> <number_of_nodes>"
echo "Example: ./filter.sh my_experiment 2"
exit 1
fi

echo "\033[92mCompilation...\033[0m"
make > /dev/null
echo "\033[95mTests ended\033[0m"
nodes=""
for i in $(seq 1 $2); do
    j=$((i + 1))
    nodes+="-l strasbourg,m3,$j,build/iotlab/m3/sender.iotlab "
done
echo "\033[92mSubmitting experiment...\033[0m"
iotlab-experiment submit -n $1 -d 20 -l strasbourg,m3,1,build/iotlab/m3/coordinator.iotlab $nodes > /dev/null
iotlab-experiment wait
echo "\033[92mExperiment start\033[0m"


# retrieve node names
iotlab-experiment get -n | grep "network_address" | sed 's/.*: "\(.*\)".*/\1/' > nodes.txt

echo "\033[92mRetrieving info...\033[0m"
for node in $(cat nodes.txt)
do
    # retrieve TSCH & RPL info with netcat during 10s, simplify it and display it
     echo "Node $node :"
    nc $node 20000 | (grep "TSCH" & grep "RPL") &
done