const { Kafka } = require('kafkajs');

console.log('Starting KafkaJS tester...');
const kafka = new Kafka({
    clientId: 'my-app',
    brokers: ['localhost:9092']
});

const producer = kafka.producer();
const consumer = kafka.consumer({ groupId: 'test-group' });

const topic = 'test-topic';

async function runTest() {
    try {
        // Connect producer
        await producer.connect();
        console.log('Producer connected');

        // Send test messages first (this will create the topic)
        await producer.send({
            topic,
            messages: [
                { value: 'Hello Kafka!' },
                { value: 'Test message 2' },
                { value: JSON.stringify({ id: 1, data: 'test' }) }
            ],
        });
        console.log('Messages sent successfully');

        // Now connect consumer
        await consumer.connect();
        console.log('Consumer connected');

        // Subscribe to topic
        await consumer.subscribe({ topic, fromBeginning: true });

        // Set up message handler
        await consumer.run({
            eachMessage: async ({ topic, partition, message }) => {
                console.log({
                    topic,
                    partition,
                    offset: message.offset,
                    value: message.value.toString(),
                });
            },
        });

        // Keep running to receive messages
        await new Promise(resolve => setTimeout(resolve, 5000));

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await producer.disconnect();
        await consumer.disconnect();
        console.log('Disconnected');
    }
}

runTest();