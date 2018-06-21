#!/bin/bash
set -e
re='^[0-9]+$'
if [ $# -ne 3 ] || ! [[ $1 =~ $re ]] || ! [[ "$2" =~ $re ]] || ! [[ -d "$3" ]]
then
echo "Wrong parameters: first param - number of masters, second param : number of replicas, third param : directory to which start all servers in"
exit 1
fi

number_of_master=$1
number_of_replicas=$2
directory=$3
starting_port=6789
current_dir=$(pwd)
echo "masters : "$number_of_master
echo "replicas : "$number_of_replicas
echo "initializing servers in the directory: "$directory
echo "current dir : " $current_dir

total=$(($(($number_of_replicas+1))*$number_of_master))
echo "total servers to start: "$total
echo "server ports :"

basic_conf=" port PORT\n
cluster-enabled yes\n
cluster-config-file nodes.conf\n
cluster-node-timeout 5000\n
appendonly yes"

for i in $(seq 0 $(($total -1)))
do
	port=$(($starting_port + $i))
	echo "starting server on port : " $port " in directory : " $3/$port
	mkdir -p $3/$port
	cd $3/$port
	pwd
	touch redis.conf
	echo -e $basic_conf >> redis.conf
	cat redis.conf
	sed -e "s/PORT/$port/" -e "s/^ //" redis.conf
	redis-server redis.conf &
	cd $current_dir
done

pwd
# gem install redis
# ./redis-trib.rb create --replicas 1 127.0.0.1:7000 127.0.0.1:7001 \
# 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005
