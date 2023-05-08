#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi


if [ ! -f $1 ]; then
    echo "$(tput setaf 1)File not found: $1$(tput setaf 7)"
    exit 1
fi

loss_packets=$(grep "TSCH: packet not acked" $1 | wc -l)
echo "Loss Packets: $loss_packets"

latency_sum=$(grep "TSCH: ACK received in" $1 | awk '{print $NF}' | paste -sd+ - | bc)
latency_count=$(grep "TSCH: ACK received in" $1 | wc -l)
if [ $latency_count -eq 0 ]; then
    latency_average=0
else
    latency_average=$(echo "scale=2; $latency_sum / $latency_count" | bc)
fi
echo "Latency Average: $latency_average"
