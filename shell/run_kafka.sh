#!/bin/sh
# Create by cuijun 2015-12-24
# Update 2016-03-24
 
#kafka_dir=/usr/hdp/2.5.3.0-37/kafka
kafka_dir=/opt/kafka
kafka_conf=$kafka_dir/config/server.properties 
kafka_broker_list=172.20.28.47:9092
#kafka_broker_list=10.7.97.176:9092,10.7.97.177:9092,10.7.97.178:9092
#kafka_broker_list=10.224.32.21:9092
#kafka_broker_list=172.20.61.117:9092
#kafka_broker_list=172.20.66.221:9092
logdir=/var/log/tima/kafka
#zookeeper=172.20.66.89:2181
#zookeeper=172.20.66.97:2181
zookeeper=172.20.28.47:2181
#zookeeper=10.7.97.176:2181,10.7.97.177:2181,10.7.97.178:2181
partition=4
replication=1

Usage(){
        echo Usage:
        echo "$0 start|stop|restart|status|start-manager"
        echo "$0 list|conlist"
        echo "$0 consumerstatus topicname consumer"
        echo "$0 watch|send|create|delete topicname"
}

Start(){
     $kafka_dir/bin/kafka-server-start.sh $kafka_conf >> $logdir/kafka_start.log  2>&1 &
}

StartManager(){
    /home/cuijun/tools/kafka-manager-1.3.0.7/bin/kafka-manager -Dconfig.file=/home/cuijun/tools/kafka-manager-1.3.0.7/conf/application.conf >/dev/null 2>&1 &
}

Stop(){
     SIG=$1
     [ -z "$SIG" ] && SIG='-SIGTERM'
     jps|grep Kafka
     echo "SIG=$SIG"
     ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}' | xargs kill "$SIG"
     jps|grep Kafka
}
  
Restart(){
    Stop
    Start
}

status(){
    ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep
}
  
List(){
    $kafka_dir/bin/kafka-topics.sh --list --zookeeper "$zookeeper"
}

List_consumer(){
    echo "zookeeper:"
    $kafka_dir/bin/kafka-consumer-groups.sh --zookeeper "$zookeeper" --list
    echo "kafka:"
    $kafka_dir/bin/kafka-consumer-groups.sh --bootstrap-server "$kafka_broker_list" --list --new-consumer
}

consumerstatus(){
    $kafka_dir/bin/kafka-run-class.sh kafka.tools.ConsumerOffsetChecker --zookeeper "$zookeeper" --group "$consumer" --topic "$TopicName"
}

watch(){
       $kafka_dir/bin/kafka-console-consumer.sh --zookeeper "$zookeeper" --topic "$TopicName" #--from-beginnin
} 

send(){
       $kafka_dir/bin/kafka-console-producer.sh --broker-list "$kafka_broker_list" --topic "$TopicName"
}

create(){
       $kafka_dir/bin/kafka-topics.sh --create --zookeeper "$zookeeper" --replication-factor "$replication" --partitions "$partition" --topic "$TopicName"
}

delete(){
       $kafka_dir/bin/kafka-topics.sh --delete --zookeeper "$zookeeper" --topic $TopicName
}
OPT="$1"
TopicName="$2"
consumer="$3"  
case $OPT in
    start)
        Start
    ;;
    start\-manager)
        StartManager
    ;;
    stop)
        Stop "$2"
    ;;
    restart)
        Restart
    ;;
    status)
    	status
    ;;
    consumerstatus)
	consumerstatus
    ;;
    list)
        List
    ;;
    conlist)
        List_consumer
    ;;
    watch)
    	watch
    ;;
    send)
    	send
    ;;
    create)
    	create
    ;;
    delete)
    	delete
    ;;
    *)
        Usage
        exit
    ;;
esac
exit
