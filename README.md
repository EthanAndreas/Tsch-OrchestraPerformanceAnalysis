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
The purpose of this project is to compare the performance of the TSCH protocol to CSMA in non-beacon mode and to compare the performance of the Orchestra scheduler to the default Contiki scheduler : 6TiSCH. Indeed, Time Slotted Channel Hopping (TSCH) is a MAC protocol that reduces power consumption and increases network reliability and Orchestra is a standalone scheduling solution for TSCH which improves , with the use of RPL, the latency-energy balance and reduces
network packet loss.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
To carry out this project, we use the IoTLab test platform, which permits the deployment of experiments on real IoT nodes through an API or in command line with an SSH connection.
Thus, we created experiments containing different nodes using CSMA/TSCH and 6TiSCH/Orchestra.
We set up groups of experiments focused on the analysis of several metrics, where each experiment contained different configurations.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
As result, we have observed the promises of TSCH compared to CSMA in non-beacon mode, which
is to reduce energy consumption and increase reliability by reducing packet loss.
packet loss. However, we have not been able to observe the promises made by Orchestra compared to
6TiSCH, which is to reduce packet loss and increase latency-energy balance.  

## Command

* ### Clone the repository on the iotlab space 
```bash
cd ~/iot-lab/parts/iot-lab-contiki-ng/contiki-ng/examples/
git clone ...
```

* ### Compile the project

```bash
make <protocol>
<protocol> = orchestra | tsch | csma
```
``csma`` and ``tsch`` rules define MAC protocol.
``orchestra`` rule define the scheduler over TSCH.
The binary file is stored in ``build/iotlab/m3`` folder.

* ###  Flash the experiment with the two nodes on iotlab
```bash
./script/submit.sh <experiment_name> <duration> <nodes_number> <site>
```

* ### Stop experiment or last experiment
```bash
./script/stop.sh <experiment_id>
```

* ### Check available nodes 
```bash
./script/check_free_nodes.sh <site>
```

* ### Flash experiment with monitoring (power or radio consumption)

The monitoring is only possible on Strasbourg site because of the accessibility of data file.
```bash
./script/monitor.sh <experiment_name> <duration> <nodes_number> <monitor> <protocol>
```

* ### Analyse power consumption or radio activity 
```bash
./script/monitor.py <experiment_id> <power | radio> <coordinator | sender> <plot>
```

* ### Get the network traffic with netcat

```bash
./script/netcat.sh <experiment_name> <duration> <nodes_number> <site> <protocol>
```
The txt files are stored in ``netcat`` folder.

* ### Analyse network traffic
```bash
python3 script/netcat.py
```

* ### Get the network traffic with serial_aggregator

```bash
./script/serial.sh <experiment_name> <duration> <nodes_number> <site> <protocol>
```

* ### Flash experiment with monitoring and get the network traffic with netcat
```bash
./script/monitor_netcat.sh <experiment_name> <duration> <nodes_number> <power | consumption> <protocol>
```


## Remark

For all of our experiment, we choose to implement only one coordinator and one or several sender.
