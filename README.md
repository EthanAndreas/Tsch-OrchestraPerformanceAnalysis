# Performance Analysis of TSCH Protocol and Orchestra Scheduling in IoT Networks
[![version](https://img.shields.io/badge/version-0.0.1-blue.svg)](https://github.com/EthanAndreas/Tsch-OrchestraPerformanceAnalysis)
[![compiler](https://img.shields.io/badge/compiler-gcc-red.svg)](https://github.com/EthanAndreas/Tsch-OrchestraPerformanceAnalysis/blob/main/Makefile)
[![author](https://img.shields.io/badge/author-EthanAndreas-blue)](https://github.com/EthanAndreas)
[![author](https://img.shields.io/badge/author-Cottelle-blue)](https://github.com/Cottelle)

## Table of Contents
1. [Abstract](#abstract)
2. [Command](#command)
3. [Remark](#remark)

## Abstract

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
The purpose of this project is to compare the performance of the TSCH protocol and the Orchestra scheduler in an IoT network with different configurations. Indeed, Time Slotted Channel Hopping (TSCH) is a MAC protocol that allows to reduce energy consumption and increase network throughput and Orchestra is a standalone scheduling solution for TSCH that allows, with the use of RPL , to reduce latency and network packet loss.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
To carry out this project, we use the IoTLab test platform which allows us to deploy experiments on real IoT nodes via an API or command line via an SSH connection. Thus, we created experiments containing different nodes using TSCH and Orchestra. We set up groups of experiments focused on the analysis of a particular metric, where each experiment contained different configurations. As a result, we were able to obtain results that we could analyse.

## Command

* ### Clone the repository on the iotlab space 
```bash
cd ~/iot-lab/parts/iot-lab-contiki-ng/contiki-ng/examples/
git clone ...
```

* ### Compile the project

```bash
make
```
The binary file is stored in ``build/iotlab/m3`` folder.

* ###  Flash the experiment with the two nodes on iotlab
```bash
./script/submit.sh <experiment_name> <duration> <nodes_number> <site>
```

* ### Stop experiment or last experiment
```bash
./script/stop.sh <id>
```

* ### Check available nodes 
```bash
./script/check_free_nodes.sh <site>
```

* ### Flash experiment with monitoring (power or radio consumption)

The monitoring is only possible on Strasbourg site because of the accessibility of data file.
```bash
./script/monitor.sh <experiment_name> <duration> <nodes_number>
```

* ### Analyse power consumption or radio activity 
```bash
./script/monitor.py <id> <duration> <power | radio> <coordinator | sender> <plot>
```

* ### Get the network traffic with netcat

```bash
./script/netcat.sh <experiment_name> <duration> <nodes_number>
```
The txt files are stored in ``netcat`` folder.

* ### Analyse network traffic
```bash
python3 script/netcat.py
```

## Remark

For all of our experiment, we choose to implement only one coordinator and one or several sender.
