# Performance Analysis of TSCH Protocol and Orchestra Scheduling in IoT Networks
[![version](https://img.shields.io/badge/version-0.0.1-blue.svg)](https://github.com/EthanAndreas/Tsch-OrchestraPerformanceAnalysis)
[![compiler](https://img.shields.io/badge/compiler-gcc-red.svg)](https://github.com/EthanAndreas/Tsch-OrchestraPerformanceAnalysis/blob/main/Makefile)
[![author](https://img.shields.io/badge/author-EthanAndreas-blue)](https://github.com/EthanAndreas)
[![author](https://img.shields.io/badge/author-Cottelle-blue)](https://github.com/Cottelle)

## Table of Contents
1. [Abstract](#abstract)
2. [Command](#command)

## Abstract

...

## Command

- Clone the repository on the iotlab space 
```bash
cd ~/iot-lab/parts/iot-lab-contiki-ng/contiki-ng/examples/TschOrchestraPerformanceAnalysis
git clone ...
```

- Compile the project
```bash
make
```

- Flash the experiment with the two nodes on iotlab
```bash
iotlab-experiment submit -n <alias-experiment> -d <time> -l <site>,m3,1,build/iotlab/m3/sender.iotlab -l <site>,m3,2,build/iotlab/m3/coordinator.iotlab
```
