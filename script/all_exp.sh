#! /bin/bash

for i in "2" "4" "10" "25"
do
mkdir netcat/$1
./script/netcat.sh $1$i 10 $i strasbourg $1
for j in $(ls  netcat/ | grep -E  "sender*|coordinator*")
do
mv netcat/$j netcat/$1/
done
done

