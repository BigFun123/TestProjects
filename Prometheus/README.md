# Prometheus & Grafana Sample with .NET

This project demonstrates monitoring a .NET application using Prometheus and Grafana.

## Prerequisites

- Docker and Docker Compose
- .NET 8.0 SDK or later

## Getting Started

### 1. Start Prometheus and Grafana

```bash
docker-compose up -d
```

This will start:
- **Prometheus** on http://localhost:9090
- **Grafana** on http://localhost:3000 (admin/admin)

### 2. Run the .NET Sample Application

```bash
dotnet run
```

The application will start on http://localhost:5000 and expose metrics at `/metrics`.

### 3. Generate Some Metrics

Visit the following endpoints to generate metrics:
- http://localhost:5000/ - Home page
- http://localhost:5000/weather - Weather forecast
- http://localhost:5000/metrics - Prometheus metrics endpoint

### 4. View Metrics in Prometheus

1. Open http://localhost:9090
2. Go to Status → Targets to verify the app is being scraped
3. Try queries like:
   - `http_requests_received_total`
   - `rate(http_requests_received_total[1m])`
   - `http_request_duration_seconds`

### 5. View Dashboards in Grafana

1. Open http://localhost:3000
2. Login with admin/admin
3. Add Prometheus as a data source:
   - Configuration → Data Sources → Add data source
   - Select Prometheus
   - URL: http://prometheus:9090
   - Click "Save & Test"
4. Create dashboards or import pre-built .NET dashboards

## Metrics Exposed

The sample application exposes:
- HTTP request counters
- Request duration histograms
- Custom business metrics (order processing, etc.)
- ASP.NET Core runtime metrics

## Stopping Services

```bash
docker-compose down
```

To remove volumes as well:
```bash
docker-compose down -v
```
