# Performance Analysis of TSCH Protocol and Orchestra Scheduling in IoT Networks

## Launch project

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
