#!/bin/sh

# zk配置
zk=10.11.12.13:2181,10.12.13.11:2181,127.0.0.1:2181
# topic配置
topicName=test
# comsumer配置
groupName=tester
# partition配置
partitionNum=3
# kafka路径配置
kafka_dir=/opt/kafka

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
