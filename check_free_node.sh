#!/bin/bash

if [ $# -ne 1 ]; then
echo "Usage: ./check_free_node.sh <site>"
echo "Example: ./check_free_node.sh strasbourg"
exit 1
fi

iotlab-status --nodes --archi m3 --state Alive --site $1 | grep network  | cut -d ":" -f2 | tr -d '",'
