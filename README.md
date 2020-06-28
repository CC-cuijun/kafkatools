# kafkatools

shell目录下run_kafka.sh可针对目标kafka集群进行状态监控，topic创建/删除，模拟消息生产者和消费者，基于kafka原始包中的工具脚本封装简化命令，提高测试效率。
src/main目录下为java代码，基于org.apache.kafka开发，可针对目标topic进行消息模拟发送，并结合kafka_offset.sh脚本进行消费服务的监控。

run_kafka.sh使用方式：
kafka_offset.sh使用方式：
jar包使用方式（消息发送及内容替换代码需要优化，否则将报错，需要尽快优化）：
