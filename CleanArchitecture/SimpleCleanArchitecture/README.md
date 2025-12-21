# Simple Clean Architecture (.NET 8)

This sample contains a minimal Clean Architecture layout for .NET 8, with four projects:

- `Core` — domain entities and interfaces
- `Application` — services/use-cases
- `Infrastructure` — repository implementations
- `Web` — ASP.NET Core minimal API

How to build and run (from repository root):

```bat
cd d:\dev\TestProjects\CleanArchitecture\SimpleCleanArchitecture\src\Web
dotnet restore ..\..\..\
dotnet build ..\Web.csproj
dotnet run --project ..\Web\Web.csproj
```

Notes:
- This creates a tiny in-memory repository. Replace `Infrastructure` with a real DB for production.
- If you want a solution file, run `dotnet new sln` and `dotnet sln add` for each project.
