using Amazon.SQS;
using Amazon.SQS.Model;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using System.IO;

namespace TestSQS.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SQSController : ControllerBase
{
    private readonly IAmazonSQS _sqsClient;
    private const string QueueUrl = "https://sqs.eu-west-1.amazonaws.com/984778981719/testquee";

    public SQSController(IAmazonSQS sqsClient)
    {
        _sqsClient = sqsClient;
    }

    [HttpPost("delete")]
    public async Task<IActionResult> DeleteMessage([FromBody] DeleteMessageRequestModel request)
    {
        if (request == null || string.IsNullOrEmpty(request.ReceiptHandle))
        {
            return BadRequest("ReceiptHandle is required");
        }
        try
        {
            var deleteRequest = new DeleteMessageRequest
            {
                QueueUrl = QueueUrl,
                ReceiptHandle = request.ReceiptHandle
            };
            await _sqsClient.DeleteMessageAsync(deleteRequest);
            return Ok(new { Message = "Message deleted successfully" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Internal server error: {ex.Message}");
        }
    }

    [HttpGet("messages")]
    public async Task<IActionResult> GetMessages()
    {
        try
        {
            var request = new ReceiveMessageRequest
            {
                QueueUrl = QueueUrl,
                MaxNumberOfMessages = 10,
                WaitTimeSeconds = 20
            };

            var response = await _sqsClient.ReceiveMessageAsync(request);

            // // To delete messages after processing, add:
            // foreach (var message in response.Messages)
            // {
            //     await _sqsClient.DeleteMessageAsync(new DeleteMessageRequest
            //     {
            //         QueueUrl = QueueUrl,
            //         ReceiptHandle = message.ReceiptHandle
            //     });
            // }

            if (response.Messages != null && response.Messages.Any())
            {
                var messages = response.Messages.Select(m => new
                {
                    m.MessageId,
                    m.Body,
                    m.ReceiptHandle
                }).ToList();

                return Ok(messages);
            }
            else
            {
                return Ok(new List<object>()); // Return empty list if no messages
            }
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Internal server error: {ex.Message}");
        }
    }

    [HttpPost("save")]
    public async Task<IActionResult> SaveMessagesLocally()
    {
        try
        {
            var request = new ReceiveMessageRequest
            {
                QueueUrl = QueueUrl,
                MaxNumberOfMessages = 10,
                WaitTimeSeconds = 20
            };

            var response = await _sqsClient.ReceiveMessageAsync(request);

            if (response.Messages != null && response.Messages.Any())
            {
                var messages = response.Messages.Select(m => new
                {
                    m.MessageId,
                    m.Body,
                    m.ReceiptHandle,
                    Timestamp = DateTime.UtcNow
                }).ToList();

                // Save to local JSON file
                var json = JsonSerializer.Serialize(messages, new JsonSerializerOptions { WriteIndented = true });
                var filePath = Path.Combine(Directory.GetCurrentDirectory(), "sqs_messages.json");
                await System.IO.File.WriteAllTextAsync(filePath, json);

                return Ok(new { Message = "Messages saved locally", FilePath = filePath, Count = messages.Count });
            }
            else
            {
                return Ok(new { Message = "No messages to save", Count = 0 });
            }
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Internal server error: {ex.Message}");
        }
    }

    [HttpPost("sendmessage")]
    public async Task<IActionResult> SendMessage([FromBody] SendMessageRequestModel request)
    {
        if (request == null || string.IsNullOrEmpty(request.Body))
        {
            return BadRequest("Message body is required");
        }

        try
        {
            var sendRequest = new SendMessageRequest
            {
                QueueUrl = QueueUrl,
                MessageBody = request.Body
            };

            var response = await _sqsClient.SendMessageAsync(sendRequest);

            return Ok(new
            {
                Message = "Message sent successfully",
                MessageId = response.MessageId,
                SequenceNumber = response.SequenceNumber
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, $"Internal server error: {ex.Message}");
        }
    }
}

public class SendMessageRequestModel
{
    public required string Body { get; set; }
}

public class DeleteMessageRequestModel
{
    public required string ReceiptHandle { get; set; }
}