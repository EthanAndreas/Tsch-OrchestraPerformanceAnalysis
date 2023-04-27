#!/bin/bash

if [ $# -ne 3 || $# -ne 4 ]; then
echo "Usage: ./filter.sh <experiment_name> <number_of_nodes> <duration> <monitor>"
echo "Example: ./filter.sh my_experiment 2 10 power"
echo "<monitor> is optional, if not specified, no monitoring, else power or radio"
exit 1
fi

echo "$(tput setaf 3)Compilation...$(tput setaf 7)"
make > /dev/null
echo "$(tput setaf 2)Compiled$(tput setaf 7)"

if [ $4 -z ]; then
    nodes="-l strasbourg,m3,1,build/iotlab/m3/coordinator.iotlab "
elif [ $4 = "power" ]; then
    nodes="-l strasbourg,m3,1,build/iotlab/m3/coordinator.iotlab,power_monitor "
elif [ $4 = "radio" ]; then
    nodes="-l strasbourg,m3,1,build/iotlab/m3/coordinator.iotlab,radio_monitor "
fi
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
for node in $(cat nodes.txt)
do
    # retrieve TSCH & RPL info with netcat during 10s, simplify it and display it
    echo "$(tput setaf 3)Node $node :$(tput setaf 7)"
    timeout 10 nc $node 20000 
    # | (grep "TSCH" & grep "RPL") 
done

rm nodes.txt
iotlab-experiment stop > /dev/null
echo "$(tput setaf 2)Experiment stop$(tput setaf 7)"