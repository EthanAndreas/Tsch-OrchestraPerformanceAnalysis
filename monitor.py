import sys
import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# Check that the correct number of arguments was given
if len(sys.argv) != 4:
    print("Usage: python script.py file_path experiment_id [power | radio]")
    sys.exit()

# Check that the file exists
if not os.path.isfile(sys.argv[1]):
    print(f"File {sys.argv[1]} does not exist")
    sys.exit()

if sys.argv[3] not in ['power', 'radio']:
    print("Invalid argument. Usage: python script.py [power | radio]")
    sys.exit()

# Read the data from the file
with open(sys.argv[1], 'r') as f:
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

# Plot the data using matplotlib
plt.plot(timestamps, values)
plt.title(f"Consumption of experiment {sys.argv[2]}")
plt.xlabel("Time (s)")
plt.ylabel("Power (W)" if sys.argv[3] == 'power' else "Radio activity")
plt.show()

# Save the plot to a file
plt.savefig(f"plot/{sys.argv[2]}_{sys.argv[3]}_plot.png")
