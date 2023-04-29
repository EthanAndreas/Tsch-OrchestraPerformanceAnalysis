#!/bin/bash

if [ $# -ne 4 ]; then
echo "Usage: ./monitor.sh <experiment_name> <duration> <nodes_number> <monitor>"
echo "Example: ./monitor.sh my_experiment 10 2 strasbourg power"
echo "<duration> : in minutes"
echo "<monitor> : power or radio"
echo "PS: Result of experiment is only accessible for Strasbourg site"
exit 1
fi

echo "$(tput setaf 3)Compilation...$(tput setaf 7)"
make > /dev/null 2>&1
echo "$(tput setaf 2)Compiled$(tput setaf 7)"

iotlab-status --nodes --archi m3 --state Alive --site strasbourg | grep network |cut -d"-" -f2 |cut -d"." -f1 > nodes_free.txt
if [ $(cat nodes_free.txt | wc -l) -lt $3 ]; then
    echo "$(tput setaf 1)Not enough nodes available$(tput setaf 7)"
    exit 1
fi

if [ $4 == "power" ]; then
    # observe power consumption on coordinator 
    iotlab-profile addm3 -n power_monitor -voltage -current -power -period 8244 -avg 4 > /dev/null 2>&1
    nodes="-l strasbourg,m3,$(cat nodes_free.txt | head -n 1),build/iotlab/m3/coordinator.iotlab,power_monitor"
elif [ $4 == "radio" ]; then
    # observe radio consumption on coordinator
    iotlab-profile addm3 -n radio_monitor -rssi -channels 11 14 -rperiod 1 -num 1 > /dev/null 2>&1
    nodes="-l strasbourg,m3,$(cat nodes_free.txt | head -n 1),build/iotlab/m3/coordinator.iotlab,radio_monitor"
else
    echo "$(tput setaf 1)Please enter a monitoring type$(tput setaf 7)"
    exit 1
fi

for i in $(seq 1 $(($3 - 1))); do
    node_id=$(cat nodes_free.txt | tail -n +$((i + 1)) | head -n 1)
    if [ $4 == "power" ]; then
        nodes+=" -l strasbourg,m3,$node_id,build/iotlab/m3/sender.iotlab,power_monitor"
    elif [ $4 == "radio" ]; then
        nodes+=" -l strasbourg,m3,$node_id,build/iotlab/m3/sender.iotlab,radio_monitor"
    fi
done

echo "$(tput setaf 3)Submitting experiment...$(tput setaf 7)"
id=$(iotlab-experiment submit -n $1 -d $2 $nodes 2>&1 | grep id | cut -d":" -f2 | tr -d ' ')
echo "Waiting for experiment $id to be in state RUNNING"
iotlab-experiment wait -i $id > /dev/null 2>&1 
echo "$(tput setaf 2)Experiment start$(tput setaf 7)"

if [ $4 == "power" ]; then
    echo "$(tput setaf 3)Retrieving power info...$(tput setaf 7)"
    file="/senslab/users/wifi2023stras10/.iot-lab/$id/consumption/m3_$(cat nodes_free.txt | head -n 1).oml"
elif [ $4 == "radio" ]; then
    echo "$(tput setaf 3)Retrieving radio info...$(tput setaf 7)"
    file="/senslab/users/wifi2023stras10/.iot-lab/$id/radio/m3_$(cat nodes_free.txt | head -n 1).oml"
fi

# wait for the file to be created
while [ ! -f "$file" ]; do
    sleep 1
done

# wait a short time the value entered in the file
echo "Wait for the end of the experiment"
sleep $(($2 * 60))

if [ $4 == "power" ]; then
    python3 monitor.py $file $id power
elif [ $4 == "radio" ]; then
    python3 monitor.py $file $id radio
fi

rm nodes_free.txt > /dev/null 2>&1
