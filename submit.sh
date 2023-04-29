#!/bin/bash

if [ $# -ne 3 ]; then
echo "Usage: ./submit.sh <experiment_name> <number_of_nodes> <duration>"
echo "Example: ./submit.sh my_experiment 2 10"
exit 1
fi  

echo "$(tput setaf 3)Compilation...$(tput setaf 7)"
make > /dev/null 2>&1
echo "$(tput setaf 2)Compiled$(tput setaf 7)"

iotlab-status --nodes --archi m3 --state Alive --site strasbourg |grep network |cut -d"-" -f2 |cut -d"." -f1 > nodes_free.txt
if [ $(wc -l nodes_free.txt ) -lt $2 ]; then
    echo "$(tput setaf 1)Not enough nodes available$(tput setaf 7)"
    exit 1
fi

nodes="-l strasbourg,m3,$(cat nodes_free.txt | head -n 1),build/iotlab/m3/coordinator.iotlab "
for i in $(cat nodes_free.txt | tail -n +2); do
    nodes+="-l strasbourg,m3,$i,build/iotlab/m3/sender.iotlab "
done

rm nodes_free.txt > /dev/null 2>&1

echo "$(tput setaf 3)Submitting experiment...$(tput setaf 7)"
iotlab-experiment submit -n $1 -d $3 $nodes > /dev/null 2>&1
iotlab-experiment wait 
echo "$(tput setaf 2)Experiment start$(tput setaf 7)"