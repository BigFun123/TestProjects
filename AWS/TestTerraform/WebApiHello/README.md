# WebApiHello (.NET 8)

A simple ASP.NET Core Web API that returns a hello message and the value of a setting from `appsettings.json`.

## How it works
- Reads the `GreetingName` setting from `appsettings.json`.
- The `/hello` endpoint returns `Hello {GreetingName}`.

## Usage
1. Run the API:
   ```sh
   dotnet run --no-launch-profile --urls=http://localhost:5000
   ```
2. Call the endpoint:
   - [http://localhost:5000/hello](http://localhost:5000/hello)

## Example Response
```
Hello World
```

## Project Structure
- `Controllers/HelloController.cs`: Main API controller.
- `appsettings.json`: Contains the `GreetingName` setting.

---

This project was generated as a minimal .NET 8 Web API sample.
