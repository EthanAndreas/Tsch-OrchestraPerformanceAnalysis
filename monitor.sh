#!/bin/bash

if [ $# -ne 5 ]; then
echo "Usage: ./monitor.sh <experiment_name> <duration> <nodes_number> <site> <monitor>"
echo "Example: ./monitor.sh my_experiment 10 2 strasbourg power"
echo "<monitor> : power or radio"
exit 1
fi

echo "$(tput setaf 3)Compilation...$(tput setaf 7)"
make > /dev/null 2>&1
echo "$(tput setaf 2)Compiled$(tput setaf 7)"

iotlab-status --nodes --archi m3 --state Alive --site $4 | grep network |cut -d"-" -f2 |cut -d"." -f1 > nodes_free.txt
if [ $(cat nodes_free.txt | wc -l) -lt $3 ]; then
    echo "$(tput setaf 1)Not enough nodes available$(tput setaf 7)"
    exit 1
fi

if [ $5 == "power" ]; then
    iotlab-profile addm3 -n power_monitor -voltage -current -power -period 8244 -avg 4 > /dev/null 2>&1
    nodes="-l $4,m3,$(cat nodes_free.txt | head -n 1),build/iotlab/m3/coordinator.iotlab,power_monitor"
elif [ $5 == "radio" ]; then
    iotlab-profile addm3 -n radio_monitor -rssi -channels 11 14 -rperiod 1 -num 1 > /dev/null 2>&1
    nodes="-l $4,m3,$(cat nodes_free.txt | head -n 1),build/iotlab/m3/coordinator.iotlab,radio_monitor"
else
    echo "$(tput setaf 1)Please enter a monitoring type$(tput setaf 7)"
    exit 1
fi

for i in $(seq 1 $(($3 - 1))); do
    node_id=$(cat nodes_free.txt | tail -n +$((i + 1)) | head -n 1)
    nodes+=" -l $4,m3,$node_id,build/iotlab/m3/sender.iotlab"
done

echo "$(tput setaf 3)Submitting experiment...$(tput setaf 7)"
iotlab-experiment submit -n $1 -d $2 $nodes > /dev/null 2>&1
iotlab-experiment wait
echo "$(tput setaf 2)Experiment start$(tput setaf 7)"

if [ $5 == "power" ]; then
    echo "$(tput setaf 3)Retrieving power info...$(tput setaf 7)"
    file="/senslab/users/wifi2023stras10/.iot-lab/last/consumption/m3_1.oml"
    # wait for file to be created
    while [ ! -f file ]; do
        sleep 1
    done
    # check if the experiment entered at least 100  values in the file
    line_count=$(wc -l < file)
    while [ $line_count -lt 100 ]; do
        line_count=$(wc -l < file)
    done
    python3 monitor.py power
elif [ $5 == "radio" ]; then
    echo "$(tput setaf 3)Retrieving radio info...$(tput setaf 7)"
    file="/senslab/users/wifi2023stras10/.iot-lab/last/radio/m3_1.oml"
    while [ ! -f file ]; do
	cat file	
echo "test 1"
        sleep 1
    done
	echo "test 2"
    # check if the experiment entered at least 100 values in the file
    line_count=$(wc -l < file)
    while [ $line_count -lt 100 ]; do
	echo "test 3"        
line_count=$(wc -l < file)
    done
	echo "test 4"
    python3 monitor.py radio
fi

rm nodes_free.txt > /dev/null 2>&1
