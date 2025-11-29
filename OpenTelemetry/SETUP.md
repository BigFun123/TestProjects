# Setup Instructions

This repository contains a complete OpenTelemetry setup that can be tested locally and deployed to AWS EKS.

## Initial Configuration

Before using this project, you need to configure your AWS settings:

### 1. Create AWS Configuration

```bash
# Copy the template file
copy aws-config.template.cmd aws-config.cmd
```

Edit `aws-config.cmd` and fill in your values:
- `AWS_ACCOUNT_ID` - Your AWS account ID
- `AWS_REGION` - Your AWS region (e.g., us-east-1)
- `EKS_CLUSTER_NAME` - Your desired EKS cluster name
- `EKS_OIDC_ID` - Your EKS OIDC provider ID (obtained during cluster creation)
- `HELM_PATH` - Path to your Helm executable (or just use "helm" if it's in PATH)

### 2. Create Kubernetes Configuration Files

```bash
# Copy template files
copy kubernetes\helm-values.template.yaml kubernetes\helm-values.yaml
copy kubernetes\sample-app-deployment.template.yaml kubernetes\sample-app-deployment.yaml
copy trust-policy.template.json trust-policy.json
```

Edit these files and replace placeholders:
- `YOUR_ACCOUNT_ID` → Your AWS account ID
- `YOUR_REGION` → Your AWS region
- `YOUR_OIDC_ID` → Your EKS OIDC provider ID

### 3. Update Subnet IDs (for AWS deployment)

Edit `tag-subnets.cmd` and replace the example subnet IDs with your VPC subnet IDs.

## Local Testing

Once configured, you can test locally:

```bash
# Start local environment with Docker Compose
start-local.cmd

# Test the application
curl http://localhost:5000/
curl http://localhost:5000/api/users/1

# View traces in Jaeger
# Open browser: http://localhost:16686

# Stop local environment
stop-local.cmd
```

## AWS Deployment

See `aws_instructions.txt` for detailed deployment instructions.

## Important Files

### Configuration Files (NOT committed to git)
- `aws-config.cmd` - Contains your AWS credentials and settings
- `kubernetes/helm-values.yaml` - Helm chart values with your account ID
- `kubernetes/sample-app-deployment.yaml` - K8s deployment with your ECR image
- `trust-policy.json` - IAM trust policy with your OIDC provider

### Template Files (committed to git)
- `aws-config.template.cmd` - Template for AWS configuration
- `kubernetes/helm-values.template.yaml` - Template for Helm values
- `kubernetes/sample-app-deployment.template.yaml` - Template for K8s deployment
- `trust-policy.template.json` - Template for IAM trust policy

## Security Notes

⚠️ **Never commit these files to git:**
- `aws-config.cmd`
- `trust-policy.json`
- `kubernetes/helm-values.yaml`
- `kubernetes/sample-app-deployment.yaml`

These files contain your AWS account ID, region, and cluster information. They are already added to `.gitignore`.

## Running Tests

```bash
# Run unit tests
cd dotnet-sample\OtelSampleApp.Tests
dotnet test
```

## Cleanup

```bash
# Delete only Kubernetes resources
cleanup-k8s-only.cmd

# Delete all AWS resources (including EKS cluster)
cleanup-aws.cmd
```

## Support

For issues or questions, please refer to:
- `README.md` - Project overview and architecture
- `aws_instructions.txt` - Detailed AWS deployment guide
- `AWS_COST_ESTIMATE.txt` - Cost analysis and optimization tips
