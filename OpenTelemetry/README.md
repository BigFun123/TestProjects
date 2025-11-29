# OpenTelemetry Local and Kubernetes Deployment

This project provides a complete OpenTelemetry setup for both local development and AWS EKS Kubernetes deployment with a C# .NET sample application.

## 🚀 Quick Start

**New to this project?** See [QUICKSTART.md](QUICKSTART.md) for a 5-minute local setup guide.

**Setting up for the first time?** See [SETUP.md](SETUP.md) for configuration instructions.

**Deploying to AWS?** See [aws_instructions.txt](aws_instructions.txt) for detailed deployment steps.

## 🏗️ Architecture

- **OpenTelemetry Collector**: Receives, processes, and exports telemetry data
- **Jaeger**: Visualizes distributed traces (local only)
- **AWS X-Ray & CloudWatch**: Telemetry backend for AWS deployments
- **Sample .NET App**: Instrumented web API demonstrating OpenTelemetry

## 📋 Prerequisites

### Local Development
- Docker Desktop installed
- Docker Compose installed
- .NET 8.0 SDK (optional, for development)

### AWS Deployment
- AWS CLI configured with credentials
- kubectl installed
- Helm 3.x installed
- AWS account with appropriate permissions
- **Configuration files set up** (see [SETUP.md](SETUP.md))

## ⚙️ Initial Configuration

**Before using this project**, you must configure your AWS settings:

1. Copy configuration templates:
   ```cmd
   copy aws-config.template.cmd aws-config.cmd
   copy kubernetes\helm-values.template.yaml kubernetes\helm-values.yaml
   copy kubernetes\sample-app-deployment.template.yaml kubernetes\sample-app-deployment.yaml
   ```

2. Edit the files and replace placeholders with your AWS account ID, region, and cluster name.

3. See [SETUP.md](SETUP.md) for detailed configuration instructions.

⚠️ **Security Note:** Configuration files with your AWS details are in `.gitignore` and will not be committed.

## 🚀 Local Testing

### Quick Start

1. **Start all services:**
   ```cmd
   start-local.cmd
   ```

2. **Access the services:**
   - Sample App: http://localhost:5000
   - Jaeger UI: http://localhost:16686
   - OTel Collector metrics: http://localhost:8888/metrics

3. **Test the application endpoints:**
   ```cmd
   curl http://localhost:5000/
   curl http://localhost:5000/api/users/1
   curl http://localhost:5000/api/slow
   curl http://localhost:5000/health
   ```

4. **View traces in Jaeger:**
   - Open http://localhost:16686
   - Select "otel-sample-app" from the service dropdown
   - Click "Find Traces"
   - Explore custom spans with tags, events, and error tracking

5. **Stop all services:**
   ```cmd
   stop-local.cmd
   ```

### Generate Load for Testing

```cmd
test-load.cmd
```

This will generate multiple requests to see traces in Jaeger.

## ☸️ Kubernetes Deployment on AWS EKS

**Complete deployment guide:** See [aws_instructions.txt](aws_instructions.txt)

### Prerequisites

1. Configure your AWS settings (see [SETUP.md](SETUP.md))
2. Create an EKS cluster
3. Set up IAM roles for IRSA

### Quick Deployment

After configuration is complete:

```cmd
REM Deploy OpenTelemetry Collector
deploy-k8s.cmd

REM Build and push Docker image to ECR
docker build -t otel-sample-app:latest dotnet-sample/OtelSampleApp
aws ecr get-login-password --region YOUR_REGION | docker login --username AWS --password-stdin YOUR_ACCOUNT_ID.dkr.ecr.YOUR_REGION.amazonaws.com
docker tag otel-sample-app:latest YOUR_ACCOUNT_ID.dkr.ecr.YOUR_REGION.amazonaws.com/otel-sample-app:latest
docker push YOUR_ACCOUNT_ID.dkr.ecr.YOUR_REGION.amazonaws.com/otel-sample-app:latest

REM Deploy sample application
kubectl apply -f kubernetes/sample-app-deployment.yaml
```

### Cleanup

```cmd
REM Delete only Kubernetes resources
cleanup-k8s-only.cmd

REM Delete all AWS resources including cluster
cleanup-aws.cmd
```

## 📊 Observability Features

### Automatic Instrumentation
- ASP.NET Core requests and responses
- HTTP client calls
- Runtime metrics (CPU, memory, GC)

### Custom Instrumentation
- Custom spans with `ActivitySource`
- Span tags for metadata
- Span events for timeline markers
- Error tracking with status codes
- Nested span hierarchy

### Example Custom Spans

The sample app includes custom spans in:
- `/api/users/{id}` - Multi-step user processing with validation
- `/api/slow` - Simulated multi-step operation

View these in Jaeger to see:
- Nested span relationships
- Tags (user.id, operation.type, validation.result)
- Events (timeline markers)
- Error states (for invalid inputs)

## 🧪 Testing

Run the unit test suite:

```cmd
cd dotnet-sample\OtelSampleApp.Tests
dotnet test
```

The test suite includes:
- 10 integration tests covering all endpoints
- Tests with OpenTelemetry instrumentation active
- Concurrent request testing
- Error scenario testing

See [dotnet-sample/OtelSampleApp.Tests/README.md](dotnet-sample/OtelSampleApp.Tests/README.md) for details.

## 💰 Cost Estimation

See [AWS_COST_ESTIMATE.txt](AWS_COST_ESTIMATE.txt) for:
- Monthly cost breakdown (~$175-210 for dev setup)
- Cost optimization strategies
- Resource scaling recommendations

## 📁 Project Structure

```
.
├── dotnet-sample/
│   ├── OtelSampleApp/           # .NET web application
│   └── OtelSampleApp.Tests/     # xUnit test suite
├── kubernetes/
│   ├── helm-values.template.yaml          # Helm chart template
│   ├── sample-app-deployment.template.yaml # K8s deployment template
│   └── otel-collector-deployment.yaml     # Collector manifest
├── aws-config.template.cmd      # AWS configuration template
├── docker-compose.yml           # Local environment
├── otel-collector-config.yaml   # Local collector config
├── QUICKSTART.md                # 5-minute setup guide
├── SETUP.md                     # Configuration instructions
└── aws_instructions.txt         # Detailed AWS deployment guide
```

## 🔒 Security

**Never commit these files** (already in `.gitignore`):
- `aws-config.cmd` - Contains AWS account ID and region
- `kubernetes/helm-values.yaml` - Contains IAM role ARN
- `kubernetes/sample-app-deployment.yaml` - Contains ECR image URL
- `trust-policy.json` - Contains OIDC provider details

Always use the `.template` versions as reference and create your own configuration files.

## 📚 Additional Resources

- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [AWS X-Ray Developer Guide](https://docs.aws.amazon.com/xray/)
- [Jaeger Documentation](https://www.jaegertracing.io/docs/)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)

## 🛠️ Troubleshooting

### Local Issues
- **Connection refused:** Ensure Docker Desktop is running
- **Port conflicts:** Check if ports 5000, 4317, 4318, 16686 are available

### AWS Issues
- **LoadBalancer not provisioning:** Check VPC subnet tags (see `tag-subnets.cmd`)
- **IAM role issues:** Verify OIDC provider and trust policy
- **Image pull errors:** Check ECR authentication and image URL

See [aws_instructions.txt](aws_instructions.txt) for detailed troubleshooting.

## 🤝 Contributing

This is a template project. Feel free to:
- Fork and customize for your needs
- Add additional exporters or processors
- Enhance the sample application
- Share improvements

## 📄 License

This project is provided as-is for educational and development purposes.
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords",
        "cloudwatch:PutMetricData",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```

Create the IAM policy:
```cmd
aws iam create-policy ^
  --policy-name OtelCollectorPolicy ^
  --policy-document file://otel-collector-policy.json
```

2. **Create IAM Role with IRSA:**

```cmd
eksctl create iamserviceaccount ^
  --name otel-collector-sa ^
  --namespace observability ^
  --cluster your-cluster-name ^
  --attach-policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/OtelCollectorPolicy ^
  --approve
```

3. **Update the IAM role ARN** in:
   - `kubernetes/helm-values.yaml`
   - `kubernetes/otel-collector-deployment.yaml`

### Deployment Options

#### Option 1: Using Helm (Recommended)

1. **Add OpenTelemetry Helm repository:**
   ```cmd
   D:\setup\dev\helm\windows-amd64\helm.exe repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
   D:\setup\dev\helm\windows-amd64\helm.exe repo update
   ```

2. **Create observability namespace:**
   ```cmd
   kubectl create namespace observability
   ```

3. **Install OpenTelemetry Collector:**
   ```cmd
   D:\setup\dev\helm\windows-amd64\helm.exe install opentelemetry-collector ^
     open-telemetry/opentelemetry-collector ^
     -f kubernetes/helm-values.yaml ^
     -n observability
   ```

4. **Build and push Docker image for sample app:**
   ```cmd
   cd dotnet-sample\OtelSampleApp
   docker build -t your-registry/otel-sample-app:latest .
   docker push your-registry/otel-sample-app:latest
   ```

5. **Update image in `kubernetes/sample-app-deployment.yaml`** with your registry

6. **Deploy sample application:**
   ```cmd
   kubectl apply -f kubernetes/sample-app-deployment.yaml
   ```

#### Option 2: Using kubectl with manifests

1. **Create namespace and deploy collector:**
   ```cmd
   kubectl apply -f kubernetes/otel-collector-deployment.yaml
   ```

2. **Deploy sample application:**
   ```cmd
   kubectl apply -f kubernetes/sample-app-deployment.yaml
   ```

### Verify Deployment

```cmd
# Check collector pods
kubectl get pods -n observability

# Check collector logs
kubectl logs -n observability -l app=otel-collector

# Check sample app
kubectl get pods -l app=otel-sample-app
kubectl get svc otel-sample-app

# Get LoadBalancer URL
kubectl get svc otel-sample-app -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
```

### View Telemetry in AWS

- **X-Ray Console**: https://console.aws.amazon.com/xray/
- **CloudWatch Logs**: https://console.aws.amazon.com/cloudwatch/
- **CloudWatch Metrics**: Navigate to custom namespace "OpenTelemetry/App"

## 🧪 Testing the Application

### Sample Endpoints

```cmd
# Health check
curl http://your-app-url/health

# Basic endpoint
curl http://your-app-url/

# User API with external call
curl http://your-app-url/api/users/1

# Slow endpoint (2s delay)
curl http://your-app-url/api/slow

# Error endpoint (for testing error traces)
curl http://your-app-url/api/error
```

### Load Testing Script

Create `test-load.cmd`:
```cmd
@echo off
for /L %%i in (1,1,100) do (
    curl -s http://localhost:5000/api/users/%%i > nul
    echo Request %%i completed
)
```

Run it to generate traces:
```cmd
test-load.cmd
```

## 📊 Observability Features

The sample application includes:

- ✅ **Distributed Tracing**: All HTTP requests are traced
- ✅ **Metrics**: Runtime, HTTP request/response metrics
- ✅ **Logging**: Structured logs with trace correlation
- ✅ **Custom Attributes**: Service name, version, environment
- ✅ **Error Tracking**: Exceptions are captured in traces

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | `http://localhost:4317` |
| `OTEL_SERVICE_NAME` | Service identifier | `otel-sample-app` |
| `OTEL_RESOURCE_ATTRIBUTES` | Additional attributes | `deployment.environment=local` |

### Collector Configuration

- **Local**: `otel-collector-config.yaml`
- **Kubernetes**: `otel-collector-config-k8s.yaml` or `kubernetes/helm-values.yaml`

## 📚 Project Structure

```
OpenTelemetry/
├── docker-compose.yml              # Local Docker setup
├── otel-collector-config.yaml      # Local collector config
├── otel-collector-config-k8s.yaml  # K8s collector config
├── dotnet-sample/
│   └── OtelSampleApp/
│       ├── OtelSampleApp.csproj    # .NET project file
│       ├── Program.cs              # Application with OTel instrumentation
│       ├── Dockerfile              # Container image
│       └── appsettings.json        # App configuration
└── kubernetes/
    ├── helm-values.yaml            # Helm chart values
    ├── otel-collector-deployment.yaml  # Collector K8s manifest
    └── sample-app-deployment.yaml  # Sample app K8s manifest
```

## 🐛 Troubleshooting

### Local Issues

**App can't connect to collector:**
```cmd
# Check collector is running
docker ps | findstr otel-collector

# Check collector logs
docker logs otel-collector
```

**No traces in Jaeger:**
- Ensure all containers are on the same network
- Check collector logs for export errors
- Verify endpoint configuration in the app

### Kubernetes Issues

**Collector pods not starting:**
```cmd
kubectl describe pod -n observability -l app=otel-collector
```

**IRSA not working (AWS permissions errors):**
- Verify IAM role ARN in ServiceAccount
- Check OIDC provider is configured on EKS cluster
- Verify IAM policy permissions

**Sample app can't reach collector:**
```cmd
# Test from app pod
kubectl exec -it <app-pod-name> -- curl http://otel-collector.observability.svc.cluster.local:4317
```

## 📖 Additional Resources

- [OpenTelemetry .NET Documentation](https://opentelemetry.io/docs/instrumentation/net/)
- [OpenTelemetry Collector Documentation](https://opentelemetry.io/docs/collector/)
- [AWS Distro for OpenTelemetry](https://aws-otel.github.io/)
- [Jaeger Documentation](https://www.jaegertracing.io/docs/)

## 🔄 Cleanup

### Local
```cmd
docker-compose down -v
```

### Kubernetes
```cmd
# Using Helm
D:\setup\dev\helm\windows-amd64\helm.exe uninstall opentelemetry-collector -n observability
kubectl delete -f kubernetes/sample-app-deployment.yaml

# Using kubectl
kubectl delete -f kubernetes/otel-collector-deployment.yaml
kubectl delete -f kubernetes/sample-app-deployment.yaml
```
