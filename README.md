# kafkatools

shell目录下run_kafka.sh可针对目标kafka集群进行状态监控，topic创建/删除，模拟消息生产者和消费者，基于kafka原始包中的工具脚本封装简化命令，提高测试效率。
src/main目录下为java代码，基于org.apache.kafka开发，可针对目标topic进行消息模拟发送，并结合kafka_offset.sh脚本进行消费服务的监控。

run_kafka.sh使用方式：  
step1.修改脚本配置:
<pre>
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
</pre>
step2.脚本使用方式：
<pre>
./run_kafka.sh 
Usage:
./run_kafka.sh start|stop|restart|status
./run_kafka.sh list|conlist
./run_kafka.sh consumerstatus topicname consumer
./run_kafka.sh watch|send|create|delete topicname
</pre>
kafka_offset.sh使用方式：  
jar包使用方式（消息发送及内容替换代码需要优化，否则将报错，需要尽快优化）：  
