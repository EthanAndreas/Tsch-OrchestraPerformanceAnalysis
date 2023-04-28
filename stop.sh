#!/bin/bash

echo "$(tput setaf 3)Clean...$(tput setaf 7)"
make clean > /dev/null
rm *.txt > /dev/null
echo "$(tput setaf 2)Cleaned$(tput setaf 7)"
iotlab-experiment stop > /dev/null
echo "$(tput setaf 2)Experiment stop$(tput setaf 7)"