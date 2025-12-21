# HelloEKS

A simple C# console application that sends HTTP requests on a timer, designed for deployment to Amazon EKS (Elastic Kubernetes Service).

## Features

- Sends HTTP GET requests on a configurable timer
- Configurable target URL and interval via environment variables
- Logs request status, duration, and response details
- Graceful shutdown handling
- Containerized with Docker
- Ready for EKS deployment

## Prerequisites

- [.NET 8.0 SDK](https://dotnet.microsoft.com/download)
- [Docker](https://www.docker.com/get-started)
- [AWS CLI](https://aws.amazon.com/cli/) configured with credentials
- [kubectl](https://kubernetes.io/docs/tasks/tools/) configured for your EKS cluster
- Amazon EKS cluster created and configured

## Environment Variables

- `TARGET_URL` - The URL to send HTTP requests to (default: `https://httpbin.org/get`)
- `INTERVAL_SECONDS` - Time in seconds between requests (default: `30`)

## Local Development

### Run Locally
```cmd
dotnet run
```

### Build Docker Image
```cmd
build.cmd
```

## AWS EKS Deployment

### 1. Create ECR Repository (First Time Only)
```cmd
create-ecr-repo.cmd us-east-1 hello-eks
```

### 2. Build, Push, and Deploy (All-in-One)
```cmd
build-push-deploy.cmd 123456789012 us-east-1 hello-eks
```

Replace:
- `123456789012` with your AWS account ID
- `us-east-1` with your AWS region
- `hello-eks` with your repository name (optional, defaults to hello-eks)

### Or Run Steps Individually

#### Build Docker Image
```cmd
build.cmd
```

#### Push to Amazon ECR
```cmd
push-to-ecr.cmd 123456789012 us-east-1 hello-eks
```

#### Deploy to EKS
```cmd
deploy-to-eks.cmd 123456789012 us-east-1 hello-eks
```

## Management Commands

### View Logs
```cmd
logs.cmd
```

### Check Status
```cmd
status.cmd
```

### Delete Deployment
```cmd
delete-deployment.cmd
```

## Command Reference

### build.cmd
**Purpose:** Build the Docker image locally  
**Usage:** `build.cmd`  
**What it does:**
- Builds a Docker image from the Dockerfile
- Tags the image as `hello-eks:latest`
- Reports success or failure

**Prerequisites:** Docker Desktop running

---

### create-ecr-repo.cmd
**Purpose:** Create an Amazon ECR repository to store Docker images  
**Usage:** `create-ecr-repo.cmd <aws-region> [repository-name]`  
**Example:** `create-ecr-repo.cmd us-east-1 hello-eks`  
**What it does:**
- Creates a new ECR repository in the specified AWS region
- Enables image scanning on push for security
- Reports if the repository already exists

**Prerequisites:** AWS CLI configured with appropriate IAM permissions

**Parameters:**
- `aws-region` (required) - AWS region where the repository will be created
- `repository-name` (optional) - Name of the repository (defaults to "hello-eks")

---

### push-to-ecr.cmd
**Purpose:** Push the Docker image to Amazon ECR  
**Usage:** `push-to-ecr.cmd <aws-account-id> <aws-region> [repository-name]`  
**Example:** `push-to-ecr.cmd 123456789012 us-east-1 hello-eks`  
**What it does:**
1. Authenticates Docker with Amazon ECR using AWS CLI
2. Tags the local `hello-eks:latest` image with the ECR repository URI
3. Pushes the tagged image to ECR
4. Displays the full image URI for deployment

**Prerequisites:** 
- Docker image built locally (`build.cmd`)
- ECR repository created (`create-ecr-repo.cmd`)
- AWS CLI configured

**Parameters:**
- `aws-account-id` (required) - Your 12-digit AWS account ID
- `aws-region` (required) - AWS region where ECR repository exists
- `repository-name` (optional) - ECR repository name (defaults to "hello-eks")

---

### deploy-to-eks.cmd
**Purpose:** Deploy the application to an Amazon EKS cluster  
**Usage:** `deploy-to-eks.cmd <aws-account-id> <aws-region> [repository-name]`  
**Example:** `deploy-to-eks.cmd 123456789012 us-east-1 hello-eks`  
**What it does:**
1. Creates a temporary deployment file with the correct ECR image URI
2. Applies the Kubernetes deployment using `kubectl apply`
3. Creates pods running the HelloEKS container in your EKS cluster
4. Cleans up the temporary file

**Prerequisites:**
- Image pushed to ECR (`push-to-ecr.cmd`)
- kubectl configured for your EKS cluster
- EKS cluster running and accessible

**Parameters:**
- `aws-account-id` (required) - Your 12-digit AWS account ID
- `aws-region` (required) - AWS region where ECR repository exists
- `repository-name` (optional) - ECR repository name (defaults to "hello-eks")

---

### build-push-deploy.cmd
**Purpose:** Complete automation - build, push, and deploy in one command  
**Usage:** `build-push-deploy.cmd <aws-account-id> <aws-region> [repository-name]`  
**Example:** `build-push-deploy.cmd 123456789012 us-east-1 hello-eks`  
**What it does:**
1. Runs `build.cmd` to build the Docker image
2. Runs `push-to-ecr.cmd` to push to Amazon ECR
3. Runs `deploy-to-eks.cmd` to deploy to EKS
4. Provides a complete deployment pipeline in a single command

**Prerequisites:** All prerequisites from the individual commands above

**Parameters:**
- `aws-account-id` (required) - Your 12-digit AWS account ID
- `aws-region` (required) - AWS region for ECR and EKS
- `repository-name` (optional) - Repository name (defaults to "hello-eks")

**Use Case:** Ideal for rapid iteration during development or CI/CD pipelines

---

### logs.cmd
**Purpose:** Stream logs from running HelloEKS pods  
**Usage:** `logs.cmd`  
**What it does:**
- Uses `kubectl logs` to stream real-time logs from all pods with label `app=hello-eks`
- Shows the last 50 log lines initially, then streams new logs
- Press Ctrl+C to stop streaming

**Prerequisites:** kubectl configured for your EKS cluster with running pods

**Output:** Shows HTTP request logs including status codes, durations, and timestamps

---

### status.cmd
**Purpose:** Check the status of the HelloEKS deployment and pods  
**Usage:** `status.cmd`  
**What it does:**
- Shows deployment status (replicas, availability)
- Lists all pods with their status (Running, Pending, etc.)
- Displays detailed pod information including events and conditions

**Prerequisites:** kubectl configured for your EKS cluster

**Use Case:** Troubleshooting deployment issues or verifying successful deployment

---

### delete-deployment.cmd
**Purpose:** Remove the HelloEKS deployment from the EKS cluster  
**Usage:** `delete-deployment.cmd`  
**What it does:**
- Deletes the Kubernetes deployment using the deployment.yaml file
- Removes all associated pods
- Frees up cluster resources

**Prerequisites:** kubectl configured for your EKS cluster

**Note:** This does NOT delete the Docker image from ECR

## Kubernetes Configuration

The application is deployed as a Kubernetes Deployment with:
- 1 replica (configurable in [deployment.yaml](deployment.yaml))
- Resource limits: 128Mi memory, 200m CPU
- Resource requests: 64Mi memory, 100m CPU

## Customization

Edit [deployment.yaml](deployment.yaml) to customize:
- Number of replicas
- Environment variables (TARGET_URL, INTERVAL_SECONDS)
- Resource limits
- Other Kubernetes settings

## Project Structure

```
HelloEKS/
├── Program.cs              # Main application code
├── HelloEKS.csproj         # C# project file
├── Dockerfile              # Multi-stage Docker build
├── deployment.yaml         # Kubernetes deployment manifest
├── build.cmd               # Build Docker image
├── create-ecr-repo.cmd     # Create ECR repository
├── push-to-ecr.cmd         # Push image to ECR
├── deploy-to-eks.cmd       # Deploy to EKS cluster
├── build-push-deploy.cmd   # Complete workflow
├── logs.cmd                # View pod logs
├── status.cmd              # Check deployment status
├── delete-deployment.cmd   # Remove deployment
└── README.md               # This file
```

## Troubleshooting

### Authentication Issues
Ensure AWS CLI is configured:
```cmd
aws configure
```

### kubectl Not Connected
Update kubeconfig for your EKS cluster:
```cmd
aws eks update-kubeconfig --name your-cluster-name --region us-east-1
```

### View Pod Events
```cmd
kubectl describe pods -l app=hello-eks
```

### View Container Logs
```cmd
kubectl logs -l app=hello-eks --tail=100
```
