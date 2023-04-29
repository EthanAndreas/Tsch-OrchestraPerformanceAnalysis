#!/bin/bash

iotlab-status --nodes --archi m3 --state Alive --site strasbourg | grep network  | cut -d ":" -f2 | tr -d '",'
