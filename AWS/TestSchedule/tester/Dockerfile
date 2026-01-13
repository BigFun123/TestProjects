FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["tester.csproj", "."]
RUN dotnet restore "./tester.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "tester.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "tester.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "tester.dll"]