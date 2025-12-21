# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore
COPY *.csproj .
RUN dotnet restore

# Copy everything else and build
COPY . .
RUN dotnet publish -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/runtime:8.0
WORKDIR /app
COPY --from=build /app/publish .

# Set default environment variables
ENV TARGET_URL=https://httpbin.org/get
ENV INTERVAL_SECONDS=30

ENTRYPOINT ["dotnet", "HelloEKS.dll"]
