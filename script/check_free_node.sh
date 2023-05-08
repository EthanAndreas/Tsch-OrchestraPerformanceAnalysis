#!/bin/bash

if [ $# -ne 1 ]; then
echo "Usage: ./check_free_node.sh <site>"
echo "Example: ./check_free_node.sh strasbourg"
exit 1
fi

if [ $(iotlab-status --nodes --archi m3 --state Alive --site $1 | wc -l) -lt 1 ]; then
    echo "$(tput setaf 1)Not enough nodes available$(tput setaf 7)"
    exit 1
fi

echo "$(tput setaf 2)Nodes available :$(tput setaf 7)"
iotlab-status --nodes --archi m3 --state Alive --site $1 | grep network  | cut -d ":" -f2 | tr -d '",'
