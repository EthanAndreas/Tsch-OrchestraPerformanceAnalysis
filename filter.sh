#!/bin/bash

if [ $# -ne 3 ] && [ $# -ne 4 ]; then
echo "Usage: ./filter.sh <experiment_name> <number_of_nodes> <duration> <monitor>"
echo "Example: ./filter.sh my_experiment 2 10 power"
echo "<monitor> is optional, if not specified, no monitoring, else power or radio"
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

echo "$(tput setaf 2)Retrieving info...$(tput setaf 7)"
if [ -z $4 ]; then
    for node in $(cat nodes.txt)
    do
        # retrieve TSCH & RPL info with netcat during 10s, simplify it and display it
        echo "$(tput setaf 3)Node $node :$(tput setaf 7)"
        timeout 10 nc $node 20000 
        # | (grep "TSCH" & grep "RPL") 
    done
elif [ $4 = "power" ]; then
    echo "$(tput setaf 2)Retrieving power info...$(tput setaf 7)"
    node = $(cat nodes.txt | head -n 1)
    cat /senslab/users/wifi2023stras10/.iot-lab/last/consumption/m3_1.oml
    if [ $? -eq 0 ]; then
        # make a pipe to the user device to plot the power consumption
        plot_oml_consum -p -i /senslab/users/wifi2023stras10/.iot-lab/last/consumption/m3_1.oml
    fi
fi

rm nodes.txt
# iotlab-experiment stop > /dev/null
# echo "$(tput setaf 2)Experiment stop$(tput setaf 7)"