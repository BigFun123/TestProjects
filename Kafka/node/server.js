const express = require('express');
const cors = require('cors');
const { Kafka } = require('kafkajs');

const app = express();
app.use(cors());
app.use(express.json());

const kafka = new Kafka({
    clientId: 'api-server',
    brokers: ['localhost:9092']
});

const producer = kafka.producer();
const consumer = kafka.consumer({ groupId: 'api-server-group' });

// Connect producer on startup
producer.connect().then(() => {
    console.log('Kafka producer connected');
}).catch(err => {
    console.error('Failed to connect producer:', err);
});

// Connect consumer and start listening
async function startConsumer() {
    try {
        await consumer.connect();
        console.log('Kafka consumer connected');

        // Subscribe to the test topic
        await consumer.subscribe({ topic: 'test-topic', fromBeginning: false });

        // Run consumer to process messages
        await consumer.run({
            eachMessage: async ({ topic, partition, message }) => {
                const value = message.value.toString();
                console.log('\n📨 Received message:');
                console.log(`  Topic: ${topic}`);
                console.log(`  Partition: ${partition}`);
                console.log(`  Offset: ${message.offset}`);
                console.log(`  Value: ${value}`);
                
                try {
                    const parsed = JSON.parse(value);
                    console.log('  Parsed:', parsed);
                } catch {
                    // Not JSON, just display as string
                }
                console.log('---');
            },
        });

        console.log('Consumer is listening for messages on "test-topic"...');
    } catch (error) {
        console.error('Failed to start consumer:', error);
    }
}

startConsumer();

// API endpoint to send messages
app.post('/api/send', async (req, res) => {
    try {
        const { topic, message } = req.body;
        console.log(`Received request to send message to topic "${topic}":`, message);
        
        if (!topic || !message) {
            return res.status(400).json({ error: 'Topic and message are required' });
        }

        await producer.send({
            topic,
            messages: [{ value: JSON.stringify(message) }],
        });

        res.json({ success: true, message: 'Message sent to Kafka' });
    } catch (error) {
        console.error('Error sending message:', error);
        res.status(500).json({ error: error.message });
    }
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`API server running on http://localhost:${PORT}`);
});

// Graceful shutdown
process.on('SIGINT', async () => {
    console.log('\nShutting down...');
    await consumer.disconnect();
    await producer.disconnect();
    process.exit(0);
});
