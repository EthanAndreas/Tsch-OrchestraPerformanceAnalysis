import matplotlib.pyplot as plt
import sys
import os
import re

def max_tl(tab):
    themax = 0
    for i in range(len(tab)):
        themax = max(themax, tab[i][0])
    return themax

def average2(tab, a, b):
    sum = 0
    for i in range(len(tab)):
        if (tab[i][b] == 0):
            continue  # ignore
        sum += tab[i][a]/tab[i][b]
    return sum/(len(tab))

def average(tab, a):
    sum = 0
    for i in range(len(tab)):
        sum += tab[i][a]
    return sum/(len(tab))

def parse_sender(file):
    lines = file.readlines()
    debut = lines[0].split()[0]
    i = 0
    nb_send = 0
    nb_reciv = 0
    sum_ping = 0
    find = False
    for line in lines:
        if ("parent" in line):
            find = True
            break
        i += 1
    if (not find):
        print("Time to parent link:NaN")
        return [-1, 0, 0, -1]

    time_link = int(lines[i].split()[0])-int(debut)
    print("Time to link", time_link)

    for line in lines[i::]:
        if ("Sending" in line):
            nb_send += 1
        elif ("Received" in line):
            nb_reciv += 1
            sum_ping += int(line.split()[11])

    if (nb_reciv != 0):
        print("nb sending :", nb_send, "\nnb reciv :",
              nb_reciv, "\naverage ping :", sum_ping/nb_reciv)
        return [time_link, nb_send, nb_reciv, sum_ping/nb_reciv]
    else:
        print("nb sending :", nb_send, "\nnb reciv :",
              nb_reciv, "\naverage ping :NaN")
        return [time_link, nb_send, nb_reciv, -1]

def parse_coor_tsch(file):
    lines = file.readlines()

    log_tsch = []

    for line in lines:
        if (not "{asn" in line):
            continue
        match = re.search(r"ch (\d+)", line)
        if match:
            ch = int(match.group(1))

        match = re.search(r"len (\d+)", line)
        if match:
            length = int(match.group(1))

        match = re.search(r"st (\d+)", line)
        if match:
            set = int(match.group(1))
            if (set == 0):  # ack
                log_tsch.append([True, ch, length])
            elif (set == 2):  # nack
                log_tsch.append([False, ch, length])
            else:
                continue  # unknow -> drop
        else:  # no set -> drop
            continue

    return log_tsch

result = []

for dir in ["/../netcat/csma/", "/../netcat/tsch/"]:
    resu = [[], [], [], []]
    logs_tsch_coord = [[],[],[],[]]
    for file in os.listdir(dir):

        match = re.search(r"_n(\d+)", file)

        if (not match):
            continue
        n = int(match.group(1))
        _n = [2, 4, 10, 25].index(n)
        print(n, _n)
        file = dir+file
        print(file)

        with open(file, "r") as f:
            if ("sender" in file):
                resu[_n].append(parse_sender(f))
            elif("coordinator" in file):
                print("Coordinator")
                logs_tsch_coord[_n]=parse_coor_tsch(f)
            print()
    result.append(resu)

#time to link
time_link = []

temp = []
temp2 = []
for i in range(4):
    temp.append(max_tl(result[0][i]))
    temp2.append(max_tl(result[1][i]))
time_link.append(temp)
time_link.append(temp2)

print(time_link)

#pos
average_pdr = []

temp = []
temp2 = []
for i in range(4):
    temp.append(average2(result[0][i], 2, 1))
    temp2.append(average2(result[1][i], 2, 1))
average_pdr.append(temp)
average_pdr.append(temp2)

print(average_pdr)

#ping
average_ping = []

temp = []
temp2 = []
for i in range(4):
    temp.append(average(result[0][i], 3))
    temp2.append(average(result[1][i], 3))
average_ping.append(temp)
average_ping.append(temp2)

print(average_ping)

#chanel use
chanel_use =[[],[],[],[]]
for i in range(len(logs_tsch_coord)):
    for j in range(len(logs_tsch_coord[i])):
        if (logs_tsch_coord[i][j][1] not in chanel_use[i]):
            chanel_use[i].append(logs_tsch_coord[i][j][1])
print("Chanel use :",chanel_use)

#ack /total
ratio_ack = []
for i in range(len(logs_tsch_coord)):
    nb_ack =0
    nb_nack=0
    for j in range(len(logs_tsch_coord[i])):
        if (logs_tsch_coord[i][j][0]):
            nb_ack+=1
        else:
            nb_nack+=1
    ratio_ack.append(nb_ack/(nb_ack+nb_nack))
print("ration ack/all tsch coordinator:",ratio_ack)

# Labels
labels = [2, 4, 10, 25]

# Plotting
plt.figure(figsize=(10, 6))

# Figure 1
plt.subplot(1, 3, 1)
plt.plot(labels, time_link[0], marker='o', label='CSMA')
plt.plot(labels, time_link[1], marker='o', label='TSCH')
plt.xlabel('Nodes')
plt.ylabel('Time to link the network (sec)')
plt.title('Linking network')
plt.legend()

# Figure 2
plt.subplot(1, 3, 2)
plt.plot(labels, average_pdr[0], marker='o', label='CSMA')
plt.plot(labels, average_pdr[1], marker='o', label='TSCH')
plt.xlabel('Nodes')
plt.ylabel('PoS average (app)')
plt.title('Percentage of success (PoS)')
plt.legend()

# Figure 3
plt.subplot(1, 3, 3)
plt.plot(labels, average_ping[0], marker='o', label='CSMA')
plt.plot(labels, average_ping[1], marker='o', label='TSCH')
plt.xlabel('Nodes')
plt.ylabel('Ping avergae (app)')
plt.title('Ping')
plt.legend()

plt.tight_layout()
plt.show()