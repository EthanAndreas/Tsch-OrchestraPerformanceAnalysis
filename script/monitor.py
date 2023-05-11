import sys
import os
import glob
import subprocess
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
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
timestamps = []
values = []
if sys.argv[3] == 'power':
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
    interval = []
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
        values.append(parts[4])
        if timestamps[len(timestamps) - 1] != timestamps[len(timestamps) - 2]:
            interval.append(1/(timestamps[len(timestamps) - 1]*1000 - timestamps[len(timestamps) - 2]*1000))

# put the same size for timestamps and values
if len(timestamps) > len(values):
    timestamps = timestamps[:len(values)]
else:
    values = values[:len(timestamps)]

# display the average value aside the plot
if sys.argv[3] == 'power':
    text = f"Average power: {sum(values)/len(values)*1000:.2f} mW"
elif sys.argv[3] == 'radio':
    text = f"Average frequency of radio activity: {sum(interval)/len(interval):.2f} kHz"

if len(sys.argv) == 5:
    print(text)

if len(sys.argv) == 6:
    if sys.argv[3] == 'power':
        command = f'plot_oml_consum -p -i {file_path}'
    elif sys.argv[3] == 'radio':
        command = f'plot_oml_radio -p -i {file_path}'

    subprocess.run(command, shell=True)
