#!/bin/bash

if [ $# -ne 4 ]; then
echo "Usage: ./monitor.sh <experiment_name> <number_of_nodes> <duration> <monitor>"
echo "Example: ./monitor.sh my_experiment 2 10 power"
echo "<monitor> : power or radio"
exit 1
fi  

echo "$(tput setaf 3)Compilation...$(tput setaf 7)"
make > /dev/null 2>&1
echo "$(tput setaf 2)Compiled$(tput setaf 7)"

if [ -z $4 ]; then
    nodes="-l strasbourg,m3,1,build/iotlab/m3/coordinator.iotlab "
elif [ $4 = "power" ]; then
    # do not display error output and classic output of iotlab-profile addm3 -n power_monitor -voltage -current -power -period 8244 -avg 4
    iotlab-profile addm3 -n power_monitor -voltage -current -power -period 8244 -avg 4 > /dev/null 2>&1
    nodes="-l strasbourg,m3,1,build/iotlab/m3/coordinator.iotlab,power_monitor "
elif [ $4 = "radio" ]; then
    iotlab-profile addm3 -n radio_monitor -rssi -channels 11 14 -rperiod 1 -num 1 > /dev/null 2>&1
    nodes="-l strasbourg,m3,1,build/iotlab/m3/coordinator.iotlab,radio_monitor "
fi
for i in $(seq 1 $2); do
    j=$((i + 1))
    nodes+="-l strasbourg,m3,$j,build/iotlab/m3/sender.iotlab "
done

echo "$(tput setaf 3)Submitting experiment...$(tput setaf 7)"
iotlab-experiment submit -n $1 -d $3 $nodes > /dev/null 2>&1
iotlab-experiment wait 
echo "$(tput setaf 2)Experiment start$(tput setaf 7)"


# retrieve node names
iotlab-experiment get -n | grep "network_address" | sed 's/.*: "\(.*\)".*/\1/' > nodes.txt

node=""
node=$(head -n 1 nodes.txt)
if [ $4 = "power" ]; then
    echo "$(tput setaf 3)Retrieving power info...$(tput setaf 7)"
    # wait for file to be created
    while [ ! -f /senslab/users/wifi2023stras10/.iot-lab/last/consumption/m3_1.oml ]; do
        sleep 1
    done
    # check if the experiment entered at least 100  values in the file
    line_count=$(wc -l < /senslab/users/wifi2023stras10/.iot-lab/last/consumption/m3_1.oml)
    while [ $line_count -lt 100 ]; do   
        line_count=$(wc -l < /senslab/users/wifi2023stras10/.iot-lab/last/consumption/m3_1.oml)
    done
    python3 monitor.py power
elif [ $4 = "radio" ]; then
    echo "$(tput setaf 3)Retrieving radio info...$(tput setaf 7)"
    while [ ! -f /senslab/users/wifi2023stras10/.iot-lab/last/consumption/m3_1.oml ]; do
        sleep 1
    done
    # check if the experiment entered at least 100 values in the file
    line_count=$(wc -l < /senslab/users/wifi2023stras10/.iot-lab/last/consumption/m3_1.oml)
    while [ $line_count -lt 100 ]; do   
        line_count=$(wc -l < /senslab/users/wifi2023stras10/.iot-lab/last/consumption/m3_1.oml)
    done
    python3 monitor.py radio
fi

rm nodes.txt > /dev/null 2>&1