package org.ulutas.flink;

import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.connectors.kafka.FlinkKafkaConsumer;
import org.apache.flink.streaming.connectors.kafka.FlinkKafkaProducer;

import java.util.Locale;

import static org.ulutas.flink.context.Utils.createStringConsumerForTopic;
import static org.ulutas.flink.context.Utils.createStringProducer;

public class Main {

    public static void main(String[] args) throws Exception {
        String inputTopic = "flink_input";
        String outputTopic = "flink_output";
        String consumerGroup = "ulutas";
        String address = "kafka1:9094,kafka2:9094,kafka3:9094";

        StreamExecutionEnvironment environment = StreamExecutionEnvironment.getExecutionEnvironment();

        FlinkKafkaConsumer<String> flinkKafkaConsumer = createStringConsumerForTopic(inputTopic, address, consumerGroup);

        DataStream<String> stringInputStream = environment.addSource(flinkKafkaConsumer, "Kafka topic \"" + inputTopic + "\"");

        FlinkKafkaProducer<String> flinkKafkaProducer = createStringProducer(outputTopic, address);

        stringInputStream
            .map((MapFunction<String, String>) s -> s.toUpperCase(Locale.forLanguageTag("tr-TR")))
            .addSink(flinkKafkaProducer)
            .name("Kafka topic \"" + outputTopic +"\"");

        environment.execute();
    }

}
