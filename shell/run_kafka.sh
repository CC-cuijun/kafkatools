#!/bin/sh
# Create by cuijun 2015-12-24
# Update 2016-03-24
# update 2020-06-23 增加注释，删除一些不再使用都方法
 
# 配置kafka路径
kafka_dir=/opt/kafka
# kafka配置
kafka_conf=$kafka_dir/config/server.properties 
# kafka broker配置
kafka_broker_list=127.0.0.1:9092,10.11.12.13:9092,10.11.12.13:9092

# 日志文件路径
logdir=/opt/logs/kafka
# zk地址
zookeeper=127.0.0.1:2181
# 配置partition
partition=4
replication=1

# 使用说明
Usage(){
        echo Usage:
        echo "$0 start|stop|restart|status"
        echo "$0 list|conlist"
        echo "$0 consumerstatus topicname consumer"
        echo "$0 watch|send|create|delete topicname"
}

Start(){
     $kafka_dir/bin/kafka-server-start.sh $kafka_conf >> $logdir/kafka_start.log  2>&1 &
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

# 若需要重头消费去掉--from-beginnin前得'#'
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
