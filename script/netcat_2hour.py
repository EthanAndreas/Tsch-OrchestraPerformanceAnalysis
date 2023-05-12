#reutilisation de netcat.py pour juster avoir le PoS de TSCH (6tisch + Orchestra)


import os
import re


def average(tab, a):
    sum = 0
    for i in range(len(tab)):
        sum += tab[i][a]
    return sum/(len(tab))


def average2(tab, a, b):
    sum = 0
    for i in range(len(tab)):
        if (tab[i][b] == 0):
            continue  # ignore
        sum += tab[i][a]/tab[i][b]
    return sum/(len(tab))


def parse_sender(file):
    lines = file.readlines()

    nb_send = 0
    nb_reciv = 0
    sum_ping = 0
    nb_ping_forget=0



    for line in lines:
        if ("Sending" in line):
            nb_send += 1
        elif ("Received" in line):
            nb_reciv += 1
            print(line.split()[11])
            if (abs(int(line.split()[11])) >1000):
                nb_ping_forget+=1
            else:
                sum_ping += int(line.split()[11])

    if (nb_reciv != 0):
        print("nb sending :", nb_send, "\nnb reciv :",
              nb_reciv, "\naverage ping :", sum_ping/nb_reciv)
        return [-1, nb_send, nb_reciv, sum_ping/(nb_reciv-nb_ping_forget)]
    else:
        print("nb sending :", nb_send, "\nnb reciv :",
              nb_reciv, "\naverage ping :NaN")
        return [-1, nb_send, nb_reciv, -1]


def parse_coor_tsch(file):
    lines = file.readlines()

    log_tsch = []

    for line in lines:
        if (not "{asn" in line or "bc-" in line):
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

coord = []
sender = []

for dir in ["netcat/tsch2hour/","netcat/orchestra2hour/"]:
    sender_pro=[]
    coord_pro=[]
    for file in os.listdir(dir):


        file = dir+file

        print(file)
        with open(file, "r") as f:
            if ("sender" in file):
                sender_pro.append(parse_sender(f))
            elif ("coordinator" in file):
                coord_pro.append(parse_coor_tsch(f))
        print()
    sender.append(sender_pro)
    coord.append(coord_pro)


# pos
average_pdr = []

temp = []
temp2 = []

temp.append(average2(sender[0], 2, 1))
temp2.append(average2(sender[1], 2, 1))
average_pdr.append(temp)
average_pdr.append(temp2)
print("Average Pos :",average_pdr)

# ping
average_ping = []

temp = []
temp2 = []
temp.append(average(sender[0], 3))
temp2.append(average(sender[1], 3))
average_ping.append(temp)
average_ping.append(temp2)

print("Average ping :",average_ping)




#ack /total
ratio_ack = []
for k in range(len(coord)):
    ratio_ack_pro = []
    logs_tsch_coord = coord[k]
    for i in range(len(logs_tsch_coord)):
        nb_ack = 0
        nb_nack = 0
        for j in range(len(logs_tsch_coord[i])):
            if (logs_tsch_coord[i][j][0]):
                nb_ack += 1
            else:
                nb_nack += 1
        if ((nb_ack+nb_nack) == 0):
            ratio_ack_pro.append(1000)
        else:
            ratio_ack_pro.append(nb_ack/(nb_ack+nb_nack))
    ratio_ack.append(ratio_ack_pro)
print("ratio ack/all tsch coordinator:", ratio_ack)
