#!/bin/bash

if [ $# -ne 5 ]; then
echo "Usage: ./serial.sh <experiment_name> <duration> <nodes_number> <site> <protocol>"
echo "Example: ./serial.sh my_experiment 10 2 strasbourg tsch"
echo "<duration> : in minutes"
echo "<protocol> : csma, tsch or orchestra"
exit 1
fi

if [ $5 != "tsch" ] && [ $5 != "csma" ] && [ $5 != "orchestra" ]; then
    echo "$(tput setaf 1)Please enter a valid protocol$(tput setaf 7)"
    exit 1
fi

echo "$(tput setaf 3)Compilation...$(tput setaf 7)"
make $5 > /dev/null 2>&1
echo "$(tput setaf 2)Compiled$(tput setaf 7)"

# check if there are enough nodes available
iotlab-status --nodes --archi m3 --state Alive --site $4 | grep network |cut -d"-" -f2 |cut -d"." -f1 > nodes_free.txt
if [ $(cat nodes_free.txt | wc -l) -lt $3 ]; then
    echo "$(tput setaf 1)Not enough nodes available$(tput setaf 7)"
    exit 1
fi

# build nodes list
nodes="-l $4,m3,$(cat nodes_free.txt | head -n 1),build/iotlab/m3/coordinator.iotlab"
for i in $(seq 1 $(($3 - 1))); do
    node_id=$(cat nodes_free.txt | tail -n +$((i + 1)) | head -n 1) 
    nodes+=", -l $4,m3,$node_id,build/iotlab/m3/sender.iotlab"
done

# submit experiment
echo "$(tput setaf 3)Submitting experiment...$(tput setaf 7)"
id=$(iotlab-experiment submit -n $1 -d $2 $nodes 2>&1 |grep id |cut -d":" -f2)
echo "Waiting for experiment $id to be in state RUNNING"
iotlab-experiment wait -i $id > /dev/null 2>&1 
echo "$(tput setaf 2)Experiment start$(tput setaf 7)"

rm nodes_free.txt > /dev/null 2>&1

# retrieve node names
iotlab-experiment get -n | grep "network_address" | sed 's/.*: "\(.*\)".*/\1/' > nodes.txt

echo "$(tput setaf 3)Retrieving info...$(tput setaf 7)"
mkdir sniffer > /dev/null 2>&1
sleep 3

# launch sniffer_aggregator processes on nodes
serial_aggregator -i $id >> "sniffer/$5/d$2_n$3.txt"

echo "$(tput setaf 2)Data retrieved and stored in sniffer folder$(tput setaf 7)"

rm nodes.txt > /dev/null 2>&1
