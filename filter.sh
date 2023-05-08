function write_terminal(){
	nc $1 20000  | while read line ; do echo $(date +%s) $line | grep -E "TSCH|RPL"; done >> netcat/$2_d$3_$1.txt
}

if [ $# -ne 5 ]; then
echo "Usage: ./monitor.sh <experiment_name> <architecture> <duration> <nodes_number> <site>"
echo "Example: ./monitor.sh my_experiment m3 10 2 strasbourg"
echo "<architecture> : m3 or a8"
echo "<duration> : in minutes"
exit 1
fi

echo "$(tput setaf 3)Compilation...$(tput setaf 7)"
make > /dev/null 2>&1
echo "$(tput setaf 2)Compiled$(tput setaf 7)"

iotlab-status --nodes --archi $2 --state Alive --site $5 | grep network |cut -d"-" -f2 |cut -d"." -f1 > nodes_free.txt
if [ $(cat nodes_free.txt | wc -l) -lt $4 ]; then
    echo "$(tput setaf 1)Not enough nodes available$(tput setaf 7)"
    exit 1
fi

nodes="-l $5,$2,$(cat nodes_free.txt | head -n 1),build/iotlab/$2/coordinator.iotlab"

for i in $(seq 1 $(($4 - 1))); do
    node_id=$(cat nodes_free.txt | tail -n +$((i + 1)) | head -n 1) 
    nodes+=", -l $5,$2,$node_id,build/iotlab/$2/sender.iotlab"
done

echo "$(tput setaf 3)Submitting experiment...$(tput setaf 7)"
id=$(iotlab-experiment submit -n $1 -d $3 $nodes 2>&1 |grep id |cut -d":" -f2)
echo "Waiting for experiment $id to be in state RUNNING"
iotlab-experiment wait -i $id > /dev/null 2>&1 
echo "$(tput setaf 2)Experiment start$(tput setaf 7)"

rm nodes_free.txt > /dev/null 2>&1

# retrieve node names
iotlab-experiment get -n | grep "network_address" | sed 's/.*: "\(.*\)".*/\1/' > nodes.txt

echo "$(tput setaf 3)Retrieving info...$(tput setaf 7)"
rm -rf netcat > /dev/null 2>&1
mkdir netcat > /dev/null 2>&1
sleep 3

for node in $(cat nodes.txt)
do
    # retrieve TSCH & RPL info with netcat of each node, simplify it and display it
    (write_terminal $node $id $3)&
done

echo "$(tput setaf 3)Waiting for the end of the experiment...$(tput setaf 7)"
sleep $(($3 * 60))

# kill netcat processes
pkill -f write_terminal > /dev/null 2>&1

echo "$(tput setaf 2)Data retrieved and stored in netcat folder$(tput setaf 7)"

rm nodes.txt > /dev/null 2>&1
