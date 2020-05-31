#!/bin/sh

zk=10.7.97.176:2181,10.7.97.177:2181,10.7.97.178:2181
#zk=172.20.66.120:2181
#topicName=vehicle.drive.action.topic
#topicName=global-status
#topicName=veh.signal.data
topicName=s4_vehicle-position-topic-41
#topicName=s4_veh.signal.data
#groupName=HeartbeatCollector
#groupName=vehicleStatusIndex
#groupName=dataParseConsumers
groupName=s4_vehicleStatusConsumer41x
partitionNum=3
kafka_dir=/usr/hdp/2.5.3.0-37/kafka

while true;do
$kafka_dir/bin/kafka-consumer-offset-checker.sh --zookeeper=$zk --topic=$topicName --group=$groupName|tee -a results.txt
echo "timestamp:"$[$(date +%s%N)/1000000] >> results.txt

sum1=`cat results.txt |grep -E "^Group*|^$groupName*|^timestamp*"|tail -n $((($partitionNum+2)*2))|head -n $(($partitionNum+1))|tail -n $partitionNum|awk '{ sum += $4} END { print sum }'`
sum3=`cat results.txt |grep -E "^Group*|^$groupName*|^timestamp*"|tail -n $((($partitionNum+2)*2))|head -n $(($partitionNum+1))|tail -n $partitionNum|awk '{ sum += $5} END { print sum }'`
time1=`cat results.txt |grep -E "^Group*|^$groupName*|^timestamp*"|tail -n $((($partitionNum+2)*2))|head -n $(($partitionNum+2))|tail -n 1|awk -F\: '{print $2}'`
sum2=`cat results.txt |grep -E "^Group*|^$groupName*|^timestamp*"|tail -n $(($partitionNum+2))|head -n $(($partitionNum+1))|tail -n $partitionNum|awk '{ sum += $4} END { print sum }'`
sum4=`cat results.txt |grep -E "^Group*|^$groupName*|^timestamp*"|tail -n $(($partitionNum+2))|head -n $(($partitionNum+1))|tail -n $partitionNum|awk '{ sum += $5} END { print sum }'`
time2=`cat results.txt |grep -E "^Group*|^$groupName*|^timestamp*"|tail -n 1|awk -F\: '{print $2}'`

#time=`$((($time2-$time1)/1000))|bc`
#采集间隔时间
time_tmp=$(($time2-$time1))
time=$(echo "scale=1;$time_tmp/1000"|bc)

#计算消费写入总条数
sum_tmp1=$(($sum2-$sum1))
sum_tmp2=$(($sum4-$sum3))

#计算平均条数
echo "消费速度： " $(echo "scale=1; $sum_tmp1/$time"|bc)条/s
echo "写入速度： " $(echo "scale=1; $sum_tmp2/$time"|bc)条/s

#echo $[$(date +%s%N)/1000000]
sleep 5
done
