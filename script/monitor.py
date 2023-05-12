import sys
import os
import glob
import subprocess
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import math
import numpy as np

# Check that the correct number of arguments was given
if len(sys.argv) != 4 and len(sys.argv) != 5:
    print("Usage: python3 monitor.py <experiment_id> <duration> <power | radio> <coordinator | sender> <plot>")
    print("Usage: <plot> (not necessary) permit to plot the result")
    sys.exit()

if sys.argv[3] not in ['power', 'radio']:
    print("Invalid argument : [power | radio]")
    sys.exit()

if sys.argv[4] not in ['coordinator', 'sender']:
    print("Invalid argument : [coordinator | sender]")
    sys.exit()

if len(sys.argv) == 6 and sys.argv[5] not in ['plot']:
    print("Invalid argument : [plot]")
    sys.exit()

# Check if the script is executed in the good folder
current_folder_path = os.getcwd()
folder_name = os.path.basename(current_folder_path)
if folder_name != 'Tsch-OrchestraPerformanceAnalysis':
    print('Usage: execute the script in Tsch-OrchestraPerformanceAnalysis folder')
    sys.exit()

# Retrieve the folder path where the data is stored
directory = os.path.expanduser("~") + '/.iot-lab/' + sys.argv[1]

if sys.argv[3] == 'power':
    directory = directory + '/consumption/'
elif sys.argv[3] == 'radio':
    directory = directory + '/radio/'

# Check if the folder contains the data file
pattern = "m3_*.oml"
nodes_number = glob.glob(os.path.join(directory, pattern))
if len(nodes_number) < 2:
    print(f'Usage: the folder {directory} does not contain the data file required')
    sys.exit()

# Retrieve the file
files = os.listdir(directory)
if sys.argv[4] == 'coordinator':
	file = files[-1]
elif sys.argv[4] == 'sender':
	file = files[-2]
file_path = directory + file

# Read the data from the file
with open(file_path, 'r') as f:
    data = f.readlines()

# Skip the 9 first lines
data = data[9:]

# Extract the relevant values from the data
if sys.argv[3] == 'power':
    timestamps = []
    values = []
    for line in data:
        if line.startswith('#'):
            continue
        parts = line.split()
        if len(parts) < 2:
            continue  # skip over lines without enough parts
        try:
            timestamp = float(parts[0])
        except ValueError:
            continue  # skip over lines with non-numeric timestamp
        timestamps.append(timestamp)
        values.append(float(parts[-1]))

elif sys.argv[3] == 'radio':
    timestamps = [[], []]
    values = [[], []]
    for line in data:
        if line.startswith('#'):
            continue
        parts = line.split()
        if len(parts) < 2:
            continue  # skip over lines without enough parts
        try:
            if parts[5] == '11':
                timestamps[0].append(float(parts[0]))
                timestamps[1].append(int(parts[5]))
            elif parts[5] == '14':
                timestamps[0].append(float(parts[0]))
                timestamps[1].append(int(parts[5]))
        except ValueError:
            continue  # skip over lines with non-numeric timestamp

        if parts[5] == '11':
            values[0].append(10*math.log10(1/float(parts[4].replace('\x00', ''))))
            values[1].append(int(parts[5]))
        elif parts[5] == '14':
            values[0].append(10*math.log10(1/float(parts[4].replace('\x00', ''))))
            values[1].append(int(parts[5]))

# put the same size for timestamps and values (avoid any error)
if sys.argv[3] == 'power':
    if len(timestamps) > len(values):
        timestamps = timestamps[:len(values)]
    else:
        values = values[:len(timestamps)]

# display the average value aside the plot
if sys.argv[3] == 'power':
    text = f"Average power: {sum(values)/len(values)*1000:.2f} mW"
elif sys.argv[3] == 'radio':
    # total time
    total_time = timestamps[0][-1] - timestamps[0][0]
    # calculate the duration of use of the channel 11 and 14 
    duration_channel_11 = 0 
    duration_channel_14 = 0
    for i in range(len(timestamps[0])-1): 
        if timestamps[i][1] == 11:
            duration_channel_11 += timestamps[0][i+1] - timestamps[0][i]
        elif timestamps[i][1] == 14:
            duration_channel_14 += timestamps[0][i+1] - timestamps[0][i]
    
    text = f"Radio consumption of channel 11: {sum(values[0][i] for i in range(len(values[0])) if timestamps[1][i] == 11):.2f} dBm\n"
    text += f"Radio consumption of channel 14: {sum(values[0][i] for i in range(len(values[0])) if timestamps[1][i] == 14):.2f} dBm\n"
    text += f"Duty cycle of channel 11: {duration_channel_11/total_time*100:.2f} %\n"
    text += f"Duty cycle of channel 14: {duration_channel_14/total_time*100:.2f} %"

if len(sys.argv) == 5:
    print(text)

if len(sys.argv) == 6:
    if sys.argv[3] == 'power':
        command = f'plot_oml_consum -p -i {file_path}'
    elif sys.argv[3] == 'radio':
        command = f'plot_oml_radio -p -i {file_path}'

    subprocess.run(command, shell=True)
