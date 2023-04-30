function write_terminal(){
	nc $node 20000  | while read line ; do echo $(date +%s) $line | grep -E "TSCH|RPL"; done >>.terminal_out/$1.txt
	echo End of process $1
}

./submit.sh $1 $2 $3 $4

# retrieve node names
iotlab-experiment get -n | grep "network_address" | sed 's/.*: "\(.*\)".*/\1/' > nodes.txt

echo "$(tput setaf 2)Retrieving info...$(tput setaf 7)"
rm -rf .terminal_out/
mkdir .terminal_out/
sleep 3
for node in $(cat nodes.txt)
do
    # retrieve TSCH & RPL info with netcat during 10s, simplify it and display it
    echo "$(tput setaf 3)Node $node :$(tput setaf 7)"
    # TODO: remove timeout and replace by thread, one thread per node that execute nc
   (write_terminal $node)&

done

rm nodes.txt > /dev/null 2>&1
