#!/bin/bash

if [ $# -lt 4 ]; then
echo "Usage: ./monitor.sh <experiment_name> <duration> <nodes_number> <site> [mac_mode]"
echo "Example: ./monitor.sh my_experiment 10 2 strasbourg"
echo "<duration> : in minutes"
exit 1
fi

echo "$(tput setaf 3)Compilation...$(tput setaf 7)"
make clean
if [ $# -ge 5 ]; then 
if [[ $5 == TSCH ]]; then 
make TSCH=1 > /dev/null 2>&1
else 
make TSCH=0 >/dev/null 2>&1
fi
fi
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
