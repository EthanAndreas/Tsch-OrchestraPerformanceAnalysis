import sys
import os
import subprocess
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

# Check that the correct number of arguments was given
if len(sys.argv) != 5 and len(sys.argv) != 6:
    print("Usage: python3 monitor.py <experiment_id> <duration> <power | radio> <coordinator | sender> <plot>")
    print("Usage: <plot> is not necessary, if you want to save the plot with matplotlib : save, and if you want to display the plot : plot")
    sys.exit()

if sys.argv[3] not in ['power', 'radio']:
    print("Invalid argument : [power | radio]")
    sys.exit()

if sys.argv[4] not in ['coordinator', 'sender']:
    print("Invalid argument : [coordinator | sender]")
    sys.exit()

if len(sys.argv) == 6 and sys.argv[5] not in ['plot', 'save']:
    print("Invalid argument : [plot | save]")
    sys.exit()

# get the first file of /senslab/users/wifi2023stras10/.iot-lab/$id/consumption_or_radio/
directory = '/senslab/users/wifi2023stras10/.iot-lab/' + sys.argv[1]

if sys.argv[3] == 'power':
    directory = directory + '/consumption/'
elif sys.argv[3] == 'radio':
    directory = directory + '/radio/'

files = os.listdir(directory)
nodes_number = len(files)

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
    if sys.argv[5] == 'save':
        # Set figure size and plot the data using matplotlib
        plt.figure(figsize=(8, 6))
        if sys.argv[3] == 'power':
            # plot the power consumption
            plt.plot(timestamps, values, color='blue')
        elif sys.argv[3] == 'radio':
            # plot vertical bar when radio activity is detected
            plt.bar(timestamps, values, color='blue')

        plt.title(f"Consumption of experiment {sys.argv[1]} for {sys.argv[4]}")
        plt.xlabel("Time (s)")
        plt.ylabel("Power (W)" if sys.argv[4] == 'power' else "Radio activity")

        text_rect = patches.Rectangle((0.92, 0.02), 0.06, 0.07, fill=True, facecolor='white', transform=plt.gca().transAxes)

        plt.gca().add_patch(text_rect)
        plt.text(0.95, 0.05, text, transform=plt.gca().transAxes, ha='right')

        # Set y-axis label and limit
        plt.ylabel("Power (W)" if sys.argv[3] == 'power' else "Radio activity")
        if sys.argv[3] == 'power':
             plt.ylim(bottom=min(values))
        elif sys.argv[3] == 'radio':
             plt.ylim(bottom=0)

        # Save the plot to a file
        plt.savefig(f"plot/{sys.argv[4]}_d{sys.argv[2]}_n{nodes_number}_plot.png")

    elif sys.argv[5] == 'plot':
        if sys.argv[3] == 'power':
            command = f'plot_oml_consum -p -i {file_path}'
        elif sys.argv[3] == 'radio':
            command = f'plot_oml_radio -p -i {file_path}'

        subprocess.run(command, shell=True)
