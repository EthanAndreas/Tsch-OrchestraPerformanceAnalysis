#!/bin/bash

if [ $# -ne 2 ]; then
echo "Usage: ./filter.sh <experiment_name> <number_of_nodes>"
echo "Example: ./filter.sh my_experiment 2"
exit 1
fi

make
for i in $(seq 1 $2)
do
    j = $i + 1
    nodes+="-l strasbourg,m3,$j,build/iotlab/m3/sender.iotlab "
done

iotlab-experiment submit -n $1 -d 20 -l strasbourg,m3,1,build/iotlab/m3/coordinator.iotlab 
iotlab-experiment wait


# retrieve node names
iotlab-experiment get -n | grep "network_address" | sed 's/.*: "\(.*\)".*/\1/' > nodes.txt

for node in $(cat nodes.txt)
do
    # retrieve TSCH & RPL info with netcat during 10s, simplify it and display it
    timeout 10 nc $node 20000 | (grep "TSCH" & grep "RPL")  
done

make clean
iotlab-experiment stop