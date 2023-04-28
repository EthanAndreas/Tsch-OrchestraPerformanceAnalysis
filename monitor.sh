#!/bin/bash

if [ $# -ne 4 ]; then
echo "Usage: ./monitor.sh <experiment_name> <number_of_nodes> <duration> <monitor>"
echo "Example: ./monitor.sh my_experiment 2 10 power"
echo "<monitor> : power or radio"
exit 1
fi  

echo "$(tput setaf 3)Compilation...$(tput setaf 7)"
make > /dev/null
echo "$(tput setaf 2)Compiled$(tput setaf 7)"

if [ -z $4 ]; then
    nodes="-l strasbourg,m3,1,build/iotlab/m3/coordinator.iotlab "
elif [ $4 = "power" ]; then
    # do not display error output and classic output of iotlab-profile addm3 -n power_monitor -voltage -current -power -period 8244 -avg 4
    iotlab-profile addm3 -n power_monitor -voltage -current -power -period 8244 -avg 4 > /dev/null
    nodes="-l strasbourg,m3,1,build/iotlab/m3/coordinator.iotlab,power_monitor "
elif [ $4 = "radio" ]; then
    iotlab-profile addm3 -n radio_monitor -rssi -channels 11 14 -rperiod 1 -num 1 > /dev/null
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

if [ $4 = "power" ]; then
    echo "$(tput setaf 3)Retrieving power info...$(tput setaf 7)"
    node = $(cat nodes.txt | head -n 1)
    # check if the experiment entered the values in the file
    while [ -s /senslab/users/wifi2023stras10/.iot-lab/last/consumption/m3_1.oml ]; do
        sleep 1
    done
    ./usr/bin/python3 monitor.py power
    fi
elif [ $4 = "radio" ]; then
    echo "$(tput setaf 3)Retrieving radio info...$(tput setaf 7)"
    node = $(cat nodes.txt | head -n 1)
    # check if the experiment entered the values in the file
     while [ -s /senslab/users/wifi2023stras10/.iot-lab/last/radio/m3_1.oml ]; do
        sleep 1
    done
    ./usr/bin/python3 monitor.py radio
fi

rm nodes.txt