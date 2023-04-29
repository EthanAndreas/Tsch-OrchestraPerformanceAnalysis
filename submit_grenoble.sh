#!/bin/bash

if [ $# -ne 3 ]; then
echo "Usage: ./submit.sh <experiment_name> <number_of_nodes> <duration>"
echo "Example: ./submit.sh my_experiment 2 10"
exit 1
fi  

echo "$(tput setaf 3)Compilation...$(tput setaf 7)"
make > /dev/null 2>&1
echo "$(tput setaf 2)Compiled$(tput setaf 7)"

nodes="-l grenoble,m3,1-1000,build/iotlab/m3/coordinator.iotlab "
for i in $(seq 1 $2); do
    j=$((i + 1))
    nodes+="-l grenoble,m3,1-1000,build/iotlab/m3/sender.iotlab "
done

echo "$(tput setaf 3)Submitting experiment...$(tput setaf 7)"
iotlab-experiment submit -n $1 -d $3 $nodes 
iotlab-experiment wait 
echo "$(tput setaf 2)Experiment start$(tput setaf 7)"
