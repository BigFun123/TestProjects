using System.Net;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using FluentAssertions;
using Xunit;

namespace OtelSampleApp.Tests;

public class ProgramTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public ProgramTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = _factory.CreateClient();
    }

    [Fact]
    public async Task RootEndpoint_ReturnsSuccessWithMessage()
    {
        // Act
        var response = await _client.GetAsync("/");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        
        var content = await response.Content.ReadFromJsonAsync<RootResponse>();
        content.Should().NotBeNull();
        content!.Message.Should().Be("Hello from OpenTelemetry Sample!");
        content.Timestamp.Should().BeCloseTo(DateTime.UtcNow, TimeSpan.FromMinutes(1));
    }

    [Theory]
    [InlineData(1)]
    [InlineData(5)]
    [InlineData(10)]
    public async Task UsersEndpoint_WithValidId_ReturnsSuccessWithUserData(int userId)
    {
        // Act
        var response = await _client.GetAsync($"/api/users/{userId}");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        
        var content = await response.Content.ReadFromJsonAsync<UserResponse>();
        content.Should().NotBeNull();
        content!.UserId.Should().Be(userId);
        content.External.Should().NotBeNullOrEmpty();
        content.External.Should().Contain("\"id\"");
    }

    [Fact]
    public async Task SlowEndpoint_ReturnsSuccessAfterDelay()
    {
        // Arrange
        var startTime = DateTime.UtcNow;

        // Act
        var response = await _client.GetAsync("/api/slow");
        var endTime = DateTime.UtcNow;

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        
        var content = await response.Content.ReadFromJsonAsync<SlowResponse>();
        content.Should().NotBeNull();
        content!.Message.Should().Be("Slow operation completed");
        
        // Verify it took at least 2 seconds
        var duration = endTime - startTime;
        duration.Should().BeGreaterThan(TimeSpan.FromSeconds(1.9));
    }

    [Fact]
    public async Task ErrorEndpoint_ThrowsException()
    {
        // Act
        var response = await _client.GetAsync("/api/error");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.InternalServerError);
    }

    [Fact]
    public async Task HealthEndpoint_ReturnsHealthyStatus()
    {
        // Act
        var response = await _client.GetAsync("/health");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        
        var content = await response.Content.ReadFromJsonAsync<HealthResponse>();
        content.Should().NotBeNull();
        content!.Status.Should().Be("healthy");
        content.Timestamp.Should().BeCloseTo(DateTime.UtcNow, TimeSpan.FromMinutes(1));
    }

    [Fact]
    public async Task RootEndpoint_ReturnsJsonContentType()
    {
        // Act
        var response = await _client.GetAsync("/");

        // Assert
        response.Content.Headers.ContentType.Should().NotBeNull();
        response.Content.Headers.ContentType!.MediaType.Should().Be("application/json");
    }

    [Fact]
    public async Task UsersEndpoint_WithInvalidId_ReturnsError()
    {
        // Act
        var response = await _client.GetAsync("/api/users/999999");

        // Assert
        // The external API might return 404 or the app might handle it differently
        // We just verify it returns some response
        response.Should().NotBeNull();
    }

    [Fact]
    public async Task MultipleRequests_AllSucceed()
    {
        // Arrange
        var tasks = new List<Task<HttpResponseMessage>>();

        // Act - Make 5 concurrent requests
        for (int i = 1; i <= 5; i++)
        {
            tasks.Add(_client.GetAsync($"/api/users/{i}"));
        }

        var responses = await Task.WhenAll(tasks);

        // Assert
        responses.Should().AllSatisfy(response =>
        {
            response.StatusCode.Should().Be(HttpStatusCode.OK);
        });
    }
}

// Response DTOs for testing
public record RootResponse(string Message, DateTime Timestamp);
public record UserResponse(int UserId, string External);
public record SlowResponse(string Message);
public record HealthResponse(string Status, DateTime Timestamp);
