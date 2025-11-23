using Confluent.Kafka;
using System.Text.Json;

Console.WriteLine("C# Kafka Producer & Consumer");

// Producer Configuration
var producerConfig = new ProducerConfig
{
    BootstrapServers = "localhost:9092"
};

// Consumer Configuration
var consumerConfig = new ConsumerConfig
{
    BootstrapServers = "localhost:9092",
    GroupId = "csharp-consumer-group",
    AutoOffsetReset = AutoOffsetReset.Earliest
};

using var producer = new ProducerBuilder<Null, string>(producerConfig).Build();
using var consumer = new ConsumerBuilder<Ignore, string>(consumerConfig).Build();

try
{
    // Send a test message
    var message = new
    {
        timestamp = DateTime.UtcNow,
        source = "csharp-app",
        data = "Hello from C#!",
        id = Guid.NewGuid()
    };

    var jsonMessage = JsonSerializer.Serialize(message);

    var result = await producer.ProduceAsync("test-topic", new Message<Null, string>
    {
        Value = jsonMessage
    });

    Console.WriteLine($"\n✅ Message sent to {result.Topic}, partition {result.Partition}, offset {result.Offset}");
    Console.WriteLine($"Message content: {jsonMessage}");

    // Now consume messages
    Console.WriteLine("\n📨 Starting consumer to read messages from test-topic...\n");
    
    consumer.Subscribe("test-topic");

    var cts = new CancellationTokenSource();
    Console.CancelKeyPress += (_, e) =>
    {
        e.Cancel = true;
        cts.Cancel();
    };

    int messageCount = 0;
    while (!cts.Token.IsCancellationRequested)
    {
        var consumeResult = consumer.Consume(TimeSpan.FromSeconds(1));
        
        if (consumeResult != null)
        {
            messageCount++;
            Console.WriteLine($"Message #{messageCount}:");
            Console.WriteLine($"  Topic: {consumeResult.Topic}");
            Console.WriteLine($"  Partition: {consumeResult.Partition}");
            Console.WriteLine($"  Offset: {consumeResult.Offset}");
            Console.WriteLine($"  Value: {consumeResult.Message.Value}");
            Console.WriteLine("---");
        }
    }
}
catch (ProduceException<Null, string> e)
{
    Console.WriteLine($"Failed to send message: {e.Error.Reason}");
}
catch (ConsumeException e)
{
    Console.WriteLine($"Failed to consume message: {e.Error.Reason}");
}
finally
{
    consumer.Close();
    Console.WriteLine("\nConsumer closed.");
}
