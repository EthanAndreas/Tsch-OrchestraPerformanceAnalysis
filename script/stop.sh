#!/bin/bash

if [ $# -gt 1 ]; then
echo "Usage: ./stop.sh <id>"
echo "Example: ./stop.sh 123456"
echo "If no id is given, last experiment is stopped"
exit 1
fi

echo "$(tput setaf 3)Clean...$(tput setaf 7)"
rm *.txt > /dev/null 2>&1
echo "$(tput setaf 2)Cleaned$(tput setaf 7)"
if [ $# -eq 1 ]; then
    iotlab-experiment stop -i $1 > /dev/null 2>&1
    echo "$(tput setaf 2)Experiment stop$(tput setaf 7)"
    exit 0
else 
    iotlab-experiment stop > /dev/null 2>&1
    echo "$(tput setaf 2)Last experiment stopped$(tput setaf 7)"
    exit 0
fi
