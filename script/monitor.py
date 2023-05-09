import sys
import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

# Check that the correct number of arguments was given
if len(sys.argv) != 5:
    print("Usage: python3 monitor.py <experiment_id> <duration> <nodes_number> <power | radio> <coordinator | sender>")
    sys.exit()
    
if sys.argv[4] not in ['power', 'radio']:
    print("Invalid argument : [power | radio]")
    sys.exit()
    
if sys.argv[5] not in ['coordinator', 'sender']:
    print("Invalid argument : [coordinator | sender]")
    sys.exit()
    
# get the first file of /senslab/users/wifi2023stras10/.iot-lab/$id/consumption/
directory = '/senslab/users/wifi2023stras10/.iot-lab/' + sys.argv[1]

if sys.argv[4] == 'power':
    directory = directory + '/consumption/'
elif sys.argv[4] == 'radio':
    directory = directory + '/radio/'

files = os.listdir(directory)
file = files[0]

# Read the data from the file
with open(file, 'r') as f:
    data = f.readlines()

# Skip the 9 first lines
data = data[9:]

# Extract the relevant values from the data
timestamps = []
values = []
if sys.argv[4] == 'power':
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
        values.append(float(parts[4]))
        
else:
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
        values.append(float(parts[3]))

# Apply a moving average to smooth the graph
window_size = 10
values_smooth = np.convolve(values, np.ones(window_size)/window_size, mode='valid')
timestamps_smooth = timestamps[window_size//2:-(window_size//2)]

# Set figure size and plot the data using matplotlib
plt.figure(figsize=(8, 6))
plt.plot(timestamps, values)
plt.title(f"Consumption of experiment {sys.argv[1]} for {sys.argv[5]}")
plt.xlabel("Time (s)")
plt.ylabel("Power (W)" if sys.argv[4] == 'power' else "Radio activity")

# display the average value aside the plot
if sys.argv[3] == 'power':
    text = f"Average power: {sum(values)/len(values):.2f} W"
else:
    text = f"Radio activity: {max(values):.2f}"
text_rect = patches.Rectangle((0.92, 0.02), 0.06, 0.07, fill=True, facecolor='white', transform=plt.gca().transAxes)
plt.gca().add_patch(text_rect)
plt.text(0.95, 0.05, text, transform=plt.gca().transAxes, ha='right')

# Set y-axis label and limit
plt.ylabel("Power (W)" if sys.argv[4] == 'power' else "Radio activity")
plt.ylim(bottom=0)

# Show the plot
plt.show(block=True)

# Save the plot to a file
plt.savefig(f"plot/{sys.argv[5]}_d{sys.argv[2]}_n{sys.argv[3]}_plot.png")