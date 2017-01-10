module Kafka
  class Session
    def initialize(kafka_file_path)
      # make sure that the file path to kafka exists
      # this program assumes that the following exist
      #   bin/zookeeper-server-start.sh
      #   bin/kafka-server-start.sh
      #   config/zookeeper.properties
      #   config/server.properties

      # port is set in the config file

      kafka_file_path_exists = system("[ -d #{kafka_file_path} ]")
      if kafka_file_path_exists
        @zookeeper_pid = fork do
          print "start zookeeper"
          system("#{kafka_file_path}/bin/zookeeper-server-start.sh #{kafka_file_path}/config/zookeeper.properties")
        end

        @kafka_pid = fork do
          # zookeeper needs to be running before starting kafka.
          # It takes a few seconds.
          sleep 30
          print "start kafka"
          system("#{kafka_file_path}/bin/kafka-server-start.sh #{kafka_file_path}/config/server.properties")
        end

        @kafka_file_path = kafka_file_path
      else
        raise ArgumentError, "The kafka_file_path does not exist", kafka_file_path
      end

      ObjectSpace.define_finalizer(self, self.class.destructor)
    end

    def create_topic(topic)
      print "Creating topic: #{topic}"
      system("#{@kafka_file_path}/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic #{topic}")
    end

    def purge_topic(topic)
      print "Purging topic: #{topic}"
      # set topic retention to 1 ms to delete
      system("#{@kafka_file_path}/bin/kafka-configs.sh --zookeeper localhost:2181 --alter --entity-type topic --entity-name #{topic} --add-config retention.ms=1")

      # reset topic retention to 24 hours
      system("#{@kafka_file_path}/bin/kafka-configs.sh --zookeeper localhost:2181 --alter --entity-type topic --entity-name #{topic} --add-config retention.ms=86400000")
    end

    def self.destructor
      proc {
        puts 'closing Kafka::Session';
        # get pids for zookeeper and kafka.
        # WARNING: will accidentally get any process that match and are
        # not related to this program
        pids = `ps -ef | grep 'zookeeper\\|kafka' | awk '{print $2}'`.split("\n")
        # don't include this current process in the pids, it would end the
        # program prematurely.
        pids.delete(String(Process.pid))
        # kill -9 for each pid
        pids.map { |pid| begin Process.kill(9, Integer(pid)) rescue Exception end }
        }
    end
  end
end

=begin
puts 'starting Kafka::Session'
Kafka::Session.new('~/Downloads/kafka_2.11-0.9.0.1', 9092)
# let it start everything and then destruct
sleep 20

Run the following command in the shell after the class has been destroyed if
you want to make sure that it properly closed the processes.
ps -ef | grep 'zookeeper\|kafka'


# if you want to run manually do this
bin/zookeeper-server-start.sh config/zookeeper.properties
bin/kafka-server-start.sh config/server.properties
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic ctb-images-for-tagging
bin/kafka-topics.sh --zookeeper localhost:2181 --alter --topic ctb-images-for-tagging --deleteConfig retention.ms
bin/kafka-configs.sh --zookeeper localhost:2181 --alter --entity-type topics --entity-name ctb-images-for-tagging --delete-config retention.ms
bin/kafka-configs.sh --zookeeper localhost:2181 --alter --entity-type topics --entity-name ctb-images-for-tagging --add-config retention.ms=1
bin/kafka-configs.sh --zookeeper localhost:2181 --alter --entity-type topics --entity-name ctb-images-for-tagging --add-config retention.ms=86400000
=end
