import sys
import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# Check that the correct number of arguments was given
if len(sys.argv) != 2:
    print("Usage: python script.py [power | radio]")
    sys.exit()

# Get the argument and check that it is valid
arg = sys.argv[1]
if arg not in ['power', 'radio']:
    print("Invalid argument. Usage: python script.py [power | radio]")
    sys.exit()

# Define the path to the data file based on the argument
if arg == 'power':
    file_path = '/senslab/users/wifi2023stras10/.iot-lab/last/consumption/m3_1.oml'
elif arg == 'radio':
    file_path = '/senslab/users/wifi2023stras10/.iot-lab/last/radio/m3_1.oml'

# Check that the file exists
if not os.path.isfile(file_path):
    print(f"File {file_path} does not exist")
    sys.exit()

# Read the data from the file
with open(file_path, 'r') as f:
    data = f.readlines()
    
# Skip the 9 first lines
data = data[9:]

# Extract the relevant values from the data
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
    values.append(float(parts[1]))

# Plot the data using matplotlib
plt.plot(timestamps, values)
plt.title(f"{arg.capitalize()} consumption")
plt.xlabel("Time (s)")
plt.ylabel("Power (W)" if arg == 'power' else "Radio activity")
plt.show()

# Save the plot to a file
plt.savefig(f"plot/{arg}_plot.png")
