FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["OtelSampleApp.csproj", "./"]
RUN dotnet restore "OtelSampleApp.csproj"
COPY . .
RUN dotnet build "OtelSampleApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "OtelSampleApp.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "OtelSampleApp.dll"]
