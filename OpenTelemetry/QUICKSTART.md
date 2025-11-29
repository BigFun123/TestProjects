# Quick Start Guide

## For GitHub Users

If you cloned this repository from GitHub, follow these steps:

### Prerequisites
- Docker Desktop (for local testing)
- .NET 8.0 SDK
- AWS CLI (for AWS deployment)
- kubectl (for AWS deployment)
- Helm 3.x (for AWS deployment)

### Local Setup (5 minutes)

1. **Start Docker Desktop**

2. **Run the local environment:**
   ```bash
   start-local.cmd
   ```

3. **Test the application:**
   ```bash
   curl http://localhost:5000/
   curl http://localhost:5000/api/users/1
   ```

4. **View traces in Jaeger:**
   - Open browser: http://localhost:16686
   - Select service: `otel-sample-app`
   - Click "Find Traces"

5. **Stop when done:**
   ```bash
   stop-local.cmd
   ```

### AWS Deployment Setup

If you want to deploy to AWS:

1. **Configure AWS settings:**
   ```bash
   copy aws-config.template.cmd aws-config.cmd
   notepad aws-config.cmd
   ```
   Fill in your AWS account ID, region, and cluster name.

2. **Configure Kubernetes files:**
   ```bash
   copy kubernetes\helm-values.template.yaml kubernetes\helm-values.yaml
   copy kubernetes\sample-app-deployment.template.yaml kubernetes\sample-app-deployment.yaml
   notepad kubernetes\helm-values.yaml
   notepad kubernetes\sample-app-deployment.yaml
   ```
   Replace `YOUR_ACCOUNT_ID` and `YOUR_REGION` with your values.

3. **Follow detailed AWS instructions:**
   See `aws_instructions.txt` for complete deployment steps.

### What's Included

- ✅ .NET 8.0 sample application with OpenTelemetry instrumentation
- ✅ Custom spans with tags, events, and error tracking
- ✅ Local Docker Compose environment with Jaeger
- ✅ AWS EKS deployment manifests
- ✅ OpenTelemetry Collector with X-Ray and CloudWatch exporters
- ✅ Comprehensive unit tests (xUnit)
- ✅ Cost estimation and optimization guide

### Need Help?

- **Local testing issues:** Check `README.md`
- **AWS deployment:** See `aws_instructions.txt`
- **Cost concerns:** Read `AWS_COST_ESTIMATE.txt`
- **Configuration help:** See `SETUP.md`

### Important Security Note

⚠️ Never commit these files if you modify them:
- `aws-config.cmd` (contains your AWS account info)
- `kubernetes/helm-values.yaml` (contains account ID)
- `kubernetes/sample-app-deployment.yaml` (contains account ID)

These are already in `.gitignore` to protect your information.
