#!/bin/bash

if [ $# -ne 4 ]; then
echo "Usage: ./submit.sh <experiment_name> <number_of_nodes> <duration> <site>"
echo "Example: ./submit.sh my_experiment 2 10 strasbourg"
exit 1
fi

echo "$(tput setaf 3)Compilation...$(tput setaf 7)"
make > /dev/null 2>&1
echo "$(tput setaf 2)Compiled$(tput setaf 7)"
nodes_free=$(iotlab-status --nodes --archi m3 --state Alive --site $4 |grep network |cut -d"-" -f2 |cut -d"." -f1)
nb_nodes_free=${#nodes_free[*]}
echo $nodes_free
echo $nb_nodes_free

iotlab-status --nodes --archi m3 --state Alive --site strasbourg |grep network |cut -d"-" -f2 |cut -d"." -f1 > nodes_free.txt
if [ $(cat nodes_free.txt | wc -l) -lt $2 ]; then
    echo "$(tput setaf 1)Not enough nodes available$(tput setaf 7)"
    exit 1
fi

nodes="-l $4,m3,$(cat nodes_free.txt | head -n 1),build/iotlab/m3/coordinator.iotlab "

i=1
nb_nodes="$2"
for node_id in $(cat nodes_free.txt | tail -n +2); do
    if [[ "$i" -gt "$nb_nodes" ]]; then
        break
    fi
    nodes+="-l $4,m3,$node_id,build/iotlab/m3/sender.iotlab "
    i=$((i+1))
done

rm nodes_free.txt > /dev/null 2>&1

echo "$(tput setaf 3)Submitting experiment...$(tput setaf 7)"
echo $1 $3 $nodes
iotlab-experiment submit -n $1 -d $3 $nodes > /dev/null 2>&1
iotlab-experiment wait
echo "$(tput setaf 2)Experiment start$(tput setaf 7)"
