# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY HelloWorldApp/*.csproj ./HelloWorldApp/
RUN dotnet restore "./HelloWorldApp/HelloWorldApp.csproj"

# Copy everything else and build
COPY HelloWorldApp/. ./HelloWorldApp/
WORKDIR "/src/HelloWorldApp"
RUN dotnet build "HelloWorldApp.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "HelloWorldApp.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Create non-root user
RUN adduser --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

COPY --from=publish /app/publish .

# Set environment variables
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "HelloWorldApp.dll"]
