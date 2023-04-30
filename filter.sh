function write_terminal(){
	nc $1 20000  | while read line ; do echo $(date +%s) $line | grep -E "TSCH|RPL"; done >> netcat/$2_d$3_$1.txt
	echo "$(tput setaf 2)Process $1 terminated$(tput setaf 7)"
}

if [ $# -ne 5 ]; then
echo "Usage: ./filter.sh <experiment_name> <duration> <number_of_nodes> <site>"
echo "Example: ./filter.sh my_experiment 10 2 strasbourg"
exit 1
fi

./submit.sh $1 $2 $3 $4 $5

# retrieve node names
iotlab-experiment get -n | grep "network_address" | sed 's/.*: "\(.*\)".*/\1/' > nodes.txt

echo "$(tput setaf 3)Retrieving info...$(tput setaf 7)"
rm -rf netcat > /dev/null 2>&1
mkdir netcat > /dev/null 2>&1
sleep 3

for node in $(cat nodes.txt)
do
    # retrieve TSCH & RPL info with netcat of each node, simplify it and display it
    (write_terminal $node $2 $3)&
done

echo "$(tput setaf 3)Waiting for the end of the experiment...$(tput setaf 7)"
sleep $2

# kill netcat processes
pkill -f write_terminal > /dev/null 2>&1

echo "$(tput setaf 3)Data retrieved and stored in netcat folder$(tput setaf 7)"

rm nodes.txt > /dev/null 2>&1
