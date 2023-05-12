#Count the number of message send/recived (app)


import os


def coutsending_reciv(file):
    lines= file.readlines()

    nb_send =0
    nb_reciv = 0

    for line in lines:
        if ("Sending" in line):
            nb_send+=1
        elif("Received" in line):
            nb_reciv+=1
    return[nb_send,nb_reciv]


for dir in ["monitor_netcat/csma/","monitor_netcat/tsch/","monitor_netcat/orchestra/"]:
    for file in os.listdir(dir):


        file = dir+file

        with open(file, "r") as f:
            if ("sender" in file):
                print(coutsending_reciv(f))
            elif ("coordinator" in file):
                continue
        print(file)
        print()