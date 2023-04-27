#!/bin/bash

make

iotlab-experiment submit -n $1 -d 20 -l strasbourg,m3,1,build/iotlab/m3/sender.iotlab -l strasbourg,m3,2,build/iotlab/m3/coordinator.iotlab
