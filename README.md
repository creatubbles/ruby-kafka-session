# Ruby Kafka Session

A Ruby library to start up a kafka session. Useful for testing.

# Download Kafka

We are currently using Kafka 0.9.0.1.

```
wget http://ftp.tc.edu.tw/pub/Apache/kafka/0.9.0.1/kafka_2.11-0.9.0.1.tgz
tar zxvf kafka_2.11-0.9.0.1.tgz
```

# Start session

```
k = Kafka::Session.new('path/to/kafka_2.11-0.9.0.1')
# wait for it to start up
sleep 50
```
