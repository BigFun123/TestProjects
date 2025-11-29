# Unit Tests for OtelSampleApp

## Test Suite Overview

The test suite uses **xUnit**, **FluentAssertions**, and **WebApplicationFactory** to perform integration tests on all API endpoints with full OpenTelemetry instrumentation.

## Test Results

✅ **All 10 tests passed**

## Test Coverage

### 1. `RootEndpoint_ReturnsSuccessWithMessage`
- **Tests**: `GET /`
- **Validates**: 
  - HTTP 200 status
  - Correct message content
  - Timestamp within expected range

### 2. `UsersEndpoint_WithValidId_ReturnsSuccessWithUserData` (Theory Test)
- **Tests**: `GET /api/users/{id}` with IDs: 1, 5, 10
- **Validates**:
  - HTTP 200 status
  - User ID matches request
  - External API data is returned
  - JSON structure contains expected fields

### 3. `SlowEndpoint_ReturnsSuccessAfterDelay`
- **Tests**: `GET /api/slow`
- **Validates**:
  - HTTP 200 status
  - Response message
  - Execution time >= 2 seconds (verifies delay)

### 4. `ErrorEndpoint_ThrowsException`
- **Tests**: `GET /api/error`
- **Validates**:
  - HTTP 500 status (exception handled)

### 5. `HealthEndpoint_ReturnsHealthyStatus`
- **Tests**: `GET /health`
- **Validates**:
  - HTTP 200 status
  - Healthy status message
  - Current timestamp

### 6. `RootEndpoint_ReturnsJsonContentType`
- **Tests**: `GET /`
- **Validates**:
  - Content-Type header is `application/json`

### 7. `UsersEndpoint_WithInvalidId_ReturnsError`
- **Tests**: `GET /api/users/999999`
- **Validates**:
  - Response is not null (graceful handling)

### 8. `MultipleRequests_AllSucceed`
- **Tests**: Concurrent requests to `GET /api/users/{1-5}`
- **Validates**:
  - All 5 concurrent requests succeed
  - HTTP 200 for all responses

## Technologies Used

- **xUnit 2.6.2**: Test framework
- **FluentAssertions 6.12.0**: Readable assertions
- **Microsoft.AspNetCore.Mvc.Testing 8.0.0**: In-memory test server
- **Moq 4.20.70**: Mocking framework (available for future use)
- **Coverlet**: Code coverage collection

## Running the Tests

### Run all tests:
```cmd
cd dotnet-sample\OtelSampleApp.Tests
dotnet test
```

### Run with verbose output:
```cmd
dotnet test --verbosity normal
```

### Run with code coverage:
```cmd
dotnet test --collect:"XPlat Code Coverage"
```

### Run specific test:
```cmd
dotnet test --filter "FullyQualifiedName~SlowEndpoint"
```

## OpenTelemetry Instrumentation in Tests

All tests execute with **full OpenTelemetry instrumentation**:
- ✅ Distributed tracing for HTTP requests
- ✅ Metrics collection (request duration, active requests, etc.)
- ✅ Structured logging with trace correlation
- ✅ External HTTP calls are traced (jsonplaceholder API)
- ✅ Runtime metrics (GC, thread pool, JIT, etc.)

Test execution generates real telemetry data that can be observed in the console output.

## Key Metrics Captured During Tests

From the test run, OpenTelemetry captured:
- **Traces**: All HTTP requests with parent-child relationships
- **HTTP Server Metrics**: Request duration, active requests, routing matches
- **HTTP Client Metrics**: External API calls, connection pooling, request queuing
- **Runtime Metrics**: GC collections, memory usage, JIT compilation, thread pool
- **DNS Metrics**: Lookup duration for external services

## Test Structure

```
OtelSampleApp.Tests/
├── OtelSampleApp.Tests.csproj    # Project file with dependencies
├── ProgramTests.cs                # Main test class with all endpoint tests
└── Usings.cs                      # Global using directives
```

## Response DTOs

The tests use simple record types for deserialization:
```csharp
public record RootResponse(string Message, DateTime Timestamp);
public record UserResponse(int UserId, string External);
public record SlowResponse(string Message);
public record HealthResponse(string Status, DateTime Timestamp);
```

## CI/CD Integration

These tests are ready for CI/CD pipelines:
```yaml
# Example GitHub Actions
- name: Run Tests
  run: dotnet test --logger "trx;LogFileName=test-results.trx"
  
- name: Publish Test Results
  uses: dorny/test-reporter@v1
  if: always()
  with:
    name: Test Results
    path: '**/*.trx'
    reporter: dotnet-trx
```

## Future Enhancements

Potential additions:
- [ ] Performance benchmarks
- [ ] Load testing integration
- [ ] Mock external API calls for isolated tests
- [ ] Custom OpenTelemetry exporters for test validation
- [ ] Snapshot testing for trace structures
