# AWS Kubernetes Hello World App - Complete Guide

This project demonstrates how to deploy a C# .NET 8 "Hello World" application to Kubernetes on AWS EC2 using the **cheapest possible option**. The app can also run locally with Docker.

## 📋 Table of Contents
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Quick Start - Local Development](#quick-start---local-development)
- [AWS Deployment (Cheapest Option)](#aws-deployment-cheapest-option)
- [Step-by-Step Learning Guide](#step-by-step-learning-guide)
- [Cost Optimization Tips](#cost-optimization-tips)
- [Troubleshooting](#troubleshooting)

## 📁 Project Structure
```
AWS/
├── HelloWorldApp/              # .NET 8 Web API
│   ├── Program.cs              # Main application code
│   ├── HelloWorldApp.csproj    # Project file
│   └── appsettings.json        # Configuration
├── k8s/                        # Kubernetes manifests
│   ├── deployment.yaml         # Deployment configuration
│   ├── service.yaml            # Service (LoadBalancer)
│   ├── configmap.yaml          # Configuration map
│   └── hpa.yaml                # Auto-scaling config
├── scripts/                    # Windows command scripts
│   ├── build.cmd               # Build .NET app
│   ├── run-local.cmd           # Run without Docker
│   ├── docker-run-local.cmd    # Build & run with Docker
│   ├── docker-stop.cmd         # Stop Docker container
│   ├── push-to-ecr.cmd         # Push to AWS ECR
│   ├── deploy-k8s.cmd          # Deploy to Kubernetes
│   ├── k8s-status.cmd          # Check deployment status
│   └── k8s-delete.cmd          # Clean up resources
├── Dockerfile                  # Multi-stage Docker build
└── README.md                   # This file
```

## 🔧 Prerequisites

### Required Software (Windows Installation)

#### 1. .NET 8 SDK
- Download the Windows x64 installer from [.NET 8 Downloads](https://dotnet.microsoft.com/download/dotnet/8.0)
- Run the installer and follow the wizard
- Verify installation: Open Command Prompt and run:
  ```cmd
  dotnet --version
  ```

#### 2. Docker Desktop for Windows
- Download from [Docker Desktop](https://www.docker.com/products/docker-desktop)
- **Requirements**: Windows 10/11 64-bit with WSL 2
- Install and enable WSL 2 backend during setup
- After installation, ensure Docker is running (system tray icon)
- Verify installation:
  ```cmd
  docker --version
  docker ps
  ```

#### 3. AWS CLI v2 for Windows
- Download the MSI installer from [AWS CLI](https://aws.amazon.com/cli/)
- Run the installer (default installation path: `C:\Program Files\Amazon\AWSCLIV2\`)
- **Important**: Close and reopen Command Prompt after installation
- Verify installation:
  ```cmd
  aws --version
  ```

#### 4. kubectl for Windows
- **Option A: Using Chocolatey** (easiest)
  ```cmd
  choco install kubernetes-cli
  ```

- **Option B: Manual Installation**
  1. Download kubectl.exe from [Kubernetes Release](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)
  2. Create folder: `C:\kubectl`
  3. Place `kubectl.exe` in that folder
  4. Add to PATH:
     - Search "Environment Variables" in Windows
     - Edit "Path" in System Variables
     - Add: `C:\kubectl`
     - Click OK and restart Command Prompt

- Verify installation:
  ```cmd
  kubectl version --client
  ```

#### 5. OpenSSH Client (for EC2 access)
- **Windows 10/11**: OpenSSH is pre-installed
- Verify by running:
  ```cmd
  ssh -V
  ```
- If not available, install via:
  ```cmd
  # Run PowerShell as Administrator
  Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
  ```

#### 6. Git for Windows (optional but recommended)
- Download from [Git SCM](https://git-scm.com/)
- Install with default options
- This also installs Git Bash (useful for Unix-like commands)

### AWS Account Setup

#### Step 1: Create AWS Account
1. Go to [aws.amazon.com](https://aws.amazon.com) and click "Create an AWS Account"
2. Follow the registration process (requires credit card)
3. Complete identity verification

#### Step 2: Create IAM User and Access Keys
1. Sign in to AWS Console → Navigate to **IAM** service
2. Click **Users** → **Create user**
3. Enter username (e.g., `kubernetes-admin`)
4. Click **Next** → Attach policies:
   - `AmazonEC2FullAccess`
   - `AmazonECRFullAccess`
   - `AmazonEKSClusterPolicy` (if using EKS)
5. Click **Create user**
6. Select the user → **Security credentials** tab
7. Under "Access keys" → **Create access key**
8. Select use case: **Command Line Interface (CLI)**
9. Click **Next** → **Create access key**
10. **IMPORTANT**: Download or copy both:
    - Access Key ID
    - Secret Access Key (only shown once!)

#### Step 3: Configure AWS CLI on Windows
1. Open **Command Prompt** (or PowerShell)
2. Run the configuration command:
   ```cmd
   aws configure
   ```
3. Enter your credentials when prompted:
   ```
   AWS Access Key ID [None]: YOUR_ACCESS_KEY_ID
   AWS Secret Access Key [None]: YOUR_SECRET_ACCESS_KEY
   Default region name [None]: us-east-1
   Default output format [None]: json
   ```

4. Verify configuration:
   ```cmd
   aws sts get-caller-identity
   ```
   You should see your account information in JSON format.

5. **Configuration files location** (for reference):
   - Credentials: `C:\Users\YOUR_USERNAME\.aws\credentials`
   - Config: `C:\Users\YOUR_USERNAME\.aws\config`

## 🚀 Quick Start - Local Development

### Option 1: Run Without Docker
```cmd
cd d:\dev\TestProjects\AWS
scripts\run-local.cmd
```
Access at: `http://localhost:5000`

### Option 2: Run With Docker
```cmd
cd d:\dev\TestProjects\AWS
scripts\docker-run-local.cmd
```
Access at: `http://localhost:8080`

### Test the API
Open your browser or use curl:
- **Hello endpoint**: `http://localhost:8080/`
- **Health check**: `http://localhost:8080/health`
- **Swagger UI**: `http://localhost:8080/swagger`

### Stop Docker Container
```cmd
scripts\docker-stop.cmd
```

## ☁️ AWS Deployment (Cheapest Option)

### Cost-Effective Strategy
For the **absolute cheapest** Kubernetes on AWS, we'll use:

**Option A: K3s on Single EC2 Instance** (Recommended for Learning)
- **Instance**: t3.micro or t4g.micro (ARM)
- **Cost**: ~$7-8/month with free tier
- **Pros**: Simple, cheap, full control
- **Cons**: Single point of failure, not production-ready

**Option B: EKS with Fargate Spot** (For Production-like)
- **Cost**: EKS control plane ($73/month) + Fargate Spot (variable)
- **Pros**: Managed, scalable, serverless
- **Cons**: More expensive

### Setup: Option A - K3s on EC2 (Cheapest)

#### Step 1: Launch EC2 Instance
1. Go to AWS Console → EC2 → Launch Instance
2. Choose:
   - **AMI**: Ubuntu 22.04 LTS
   - **Instance type**: t3.micro (or t4g.micro for ARM)
   - **Storage**: 20 GB gp3
   - **Security Group**: 
     - SSH (22) from your IP
     - HTTP (80) from anywhere (0.0.0.0/0)
     - HTTPS (443) from anywhere (0.0.0.0/0)
     - Custom TCP (6443) from your IP (Kubernetes API)
3. Create or select a key pair
4. Launch instance

#### Step 2: Connect to EC2 Instance (Windows)

**Important**: When you created the EC2 instance, AWS provided a `.pem` key file. You need to:

1. **Download and save the key file**:
   - Save it to a secure location, e.g., `C:\Users\YOUR_USERNAME\.ssh\aws-key.pem`

2. **Set proper permissions** (important for Windows):
   ```cmd
   # Open Command Prompt and navigate to the key location
   cd C:\Users\YOUR_USERNAME\.ssh
   
   # Remove inheritance and set permissions (run these commands)
   icacls aws-key.pem /inheritance:r
   icacls aws-key.pem /grant:r "%USERNAME%:R"
   ```

3. **Connect using SSH**:
   ```cmd
   ssh -i C:\Users\YOUR_USERNAME\.ssh\aws-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
   ```

   **Alternative**: If you encounter issues, use Git Bash (installed with Git):
   ```bash
   ssh -i ~/.ssh/aws-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
   ```

4. **First-time connection**: Type `yes` when prompted about authenticity

**Troubleshooting**:
- If you get "permission denied": Check key file permissions
- If you get "connection refused": Verify Security Group allows SSH (port 22) from your IP
- Get your public IP: Visit https://whatismyipaddress.com/

#### Step 3: Install K3s (Lightweight Kubernetes)

> **📝 Important**: These commands run **on the EC2 Ubuntu instance**, not on your Windows machine!  
> You should still be connected via SSH from Step 2. Your terminal prompt should show `ubuntu@ip-xxx-xxx-xxx-xxx`.

**Run these commands in your SSH session** (you're now on the Ubuntu server):

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Get this instance's public IP (important for certificate)
curl -s http://169.254.169.254/latest/meta-data/public-ipv4

# Install K3s with public IP in TLS certificate (replace YOUR_PUBLIC_IP)
# This allows kubectl to connect from your Windows machine
curl -sfL https://get.k3s.io | sh -s - --tls-san 13.57.56.10

# Example: curl -sfL https://get.k3s.io | sh -s - --tls-san 13.57.56.10

# Wait for K3s to be ready (should show "Ready" status)
sudo k3s kubectl get nodes

# Get kubeconfig (copy this entire output for next step)
sudo cat /etc/rancher/k3s/k3s.yaml
```

**What you're doing**: Installing Kubernetes (K3s) on your Ubuntu EC2 server using Linux commands via your SSH connection from Windows.

#### Step 4: Configure Local kubectl on Windows

1. **Get the kubeconfig from EC2**:
   ```bash
   # While connected to EC2 via SSH
   sudo cat /etc/rancher/k3s/k3s.yaml
   ```

2. **Copy the entire output** (Ctrl+C)

3. **Create kubectl config directory on Windows**:
   ```cmd
   # Open Command Prompt on your Windows machine
   mkdir %USERPROFILE%\.kube
   ```

4. **Create/edit the config file**:
   - **Option A: Using Notepad**
     ```cmd
     notepad %USERPROFILE%\.kube\config
     ```
     Paste the content, modify (see step 5), and save

   - **Option B: Using PowerShell**
     ```powershell
     # Run PowerShell
     New-Item -ItemType Directory -Force -Path $env:USERPROFILE\.kube
     notepad $env:USERPROFILE\.kube\config
     ```

5. **Modify the config file**:
   Find this line:
   ```yaml
   server: https://127.0.0.1:6443
   ```
   Change it to:
   ```yaml
   server: https://YOUR_EC2_PUBLIC_IP:6443
   ```
   Replace `YOUR_EC2_PUBLIC_IP` with your actual EC2 public IP address

6. **Verify connection**:
   ```cmd
   kubectl get nodes
   ```
   You should see your K3s node listed

**Troubleshooting**:
- **"Unable to connect"**: Check EC2 Security Group allows port 6443 from your IP
- **TLS certificate error**: See detailed solution in Troubleshooting section below
- **"certificate signed by unknown authority"**: Add `insecure-skip-tls-verify: true` under the cluster section (for testing only)
- **View current config**: `kubectl config view`

**Example config file structure**:
```yaml
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: LS0tLS...
    server: https://13.57.56.10:6443
    insecure-skip-tls-verify: true  # Add this line if you get TLS errors
  name: default
contexts:
- context:
    cluster: default
    user: default
  name: default
current-context: default
users:
- name: default
  user:
    client-certificate-data: LS0tLS...
    client-key-data: LS0tLS...
```

#### Step 5: Create ECR Repository
```cmd
aws ecr create-repository --repository-name helloworld-app --region us-east-1
```

#### Step 6: Build and Push Image

**First, get your AWS Account ID**:

- **Option A: Using AWS CLI** (easiest)
  ```cmd
  aws sts get-caller-identity --query Account --output text
  ```

- **Option B: From AWS Console**
  - Sign in to AWS Console
  - Click your account name in top-right corner
  - Your 12-digit Account ID is shown in the dropdown

1. **Edit the push script**:
   - Open `scripts\push-to-ecr.cmd` in Notepad or VS Code:
     ```cmd
     notepad scripts\push-to-ecr.cmd
     ```
   - Find and replace:
     - `YOUR_AWS_ACCOUNT_ID` with your actual 12-digit AWS account ID
     - `AWS_REGION=us-east-1` (change if you're using a different region)
   - Save the file

2. Build Docker image locally:
   ```cmd
   docker build -t helloworld-app:latest .
   ```

3. Push to ECR:
   ```cmd
   scripts\push-to-ecr.cmd
   ```

4. Copy the Image URI from the output

#### Step 7: Update Kubernetes Deployment

1. **Open the deployment file**:
   ```cmd
   notepad k8s\deployment.yaml
   ```
   Or use VS Code:
   ```cmd
   code k8s\deployment.yaml
   ```

2. **Find the image line** (around line 19):
   ```yaml
   image: YOUR_DOCKER_IMAGE:latest
   ```

3. **Replace with your ECR image URI**:
   ```yaml
   image: YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/helloworld-app:latest
   ```
   Example:
   ```yaml
   image: 123456789012.dkr.ecr.us-east-1.amazonaws.com/helloworld-app:latest
   ```

4. **Save the file** (Ctrl+S)

**Tip**: The complete ECR image URI is shown in the output of `scripts\push-to-ecr.cmd`

#### Step 8: Deploy to Kubernetes
```cmd
scripts\deploy-k8s.cmd
```

#### Step 9: Access Your Application
```cmd
# Get the service details
kubectl get services

# For K3s, get the NodePort
kubectl get service helloworld-service -o jsonpath='{.spec.ports[0].nodePort}'
```

Access your app at: `http://YOUR_EC2_PUBLIC_IP:NODE_PORT`

### Setup: Option B - Amazon EKS (Alternative)

This option costs more (~$73/month minimum) but is more production-ready.

#### Step 1: Create EKS Cluster

**Prerequisites**: Install Chocolatey (Windows package manager) if not already installed:
1. Open **PowerShell as Administrator**
2. Run:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```
3. Close and reopen PowerShell/Command Prompt

**Install eksctl**:
```cmd
# Run Command Prompt as Administrator
choco install eksctl

# Create cluster (takes 15-20 minutes)
eksctl create cluster ^
  --name helloworld-cluster ^
  --region us-east-1 ^
  --nodegroup-name linux-nodes ^
  --node-type t3.micro ^
  --nodes 2 ^
  --nodes-min 1 ^
  --nodes-max 3 ^
  --managed
```

#### Step 2: Configure kubectl
```cmd
aws eks update-kubeconfig --name helloworld-cluster --region us-east-1
```

#### Step 3-8: Same as Option A
Follow steps 5-9 from Option A (ECR and deployment steps are identical)

## 📚 Step-by-Step Learning Guide

### Module 1: Understanding the .NET Application
**Goal**: Learn ASP.NET Core Minimal APIs

1. Open `HelloWorldApp\Program.cs`
2. Key concepts:
   - **WebApplication.CreateBuilder()**: Sets up the web server
   - **MapGet()**: Creates HTTP GET endpoints
   - **Swagger**: Auto-generates API documentation
   - **Health checks**: For Kubernetes monitoring

**Try this**: Add a new endpoint
```csharp
app.MapGet("/time", () => DateTime.UtcNow.ToString());
```

### Module 2: Docker Containerization
**Goal**: Understand multi-stage Docker builds

1. Open `Dockerfile`
2. Three stages:
   - **Build**: Compile the .NET app
   - **Publish**: Create optimized runtime files
   - **Final**: Minimal runtime image (~200MB)

**Try this**: Build and inspect image
```cmd
docker build -t helloworld-app:latest .
docker images helloworld-app
docker inspect helloworld-app:latest
```

### Module 3: Kubernetes Concepts
**Goal**: Learn core Kubernetes resources

#### 3.1 Deployment (`k8s\deployment.yaml`)
- Manages **replicas** (multiple copies of your app)
- Defines **resource limits** (CPU/memory)
- Configures **health probes** (liveness/readiness)

**Key fields**:
- `replicas: 2` - Runs 2 copies of the app
- `resources` - Prevents resource hogging
- `livenessProbe` - Restarts unhealthy pods
- `readinessProbe` - Controls traffic routing

#### 3.2 Service (`k8s\service.yaml`)
- Exposes your app to the internet
- **LoadBalancer** type creates an AWS ELB
- Routes traffic to healthy pods

#### 3.3 ConfigMap (`k8s\configmap.yaml`)
- Stores configuration data
- Separates config from code
- Can be updated without rebuilding image

#### 3.4 HPA (`k8s\hpa.yaml`)
- Auto-scales based on CPU usage
- Adds pods when CPU > 70%
- Min 1 pod, Max 5 pods

**Try this**: Experiment with replicas
```cmd
# Scale to 3 pods
kubectl scale deployment helloworld-deployment --replicas=3

# Watch pods being created
kubectl get pods -w

# Check HPA status
kubectl get hpa
```

### Module 4: AWS Integration
**Goal**: Understand AWS services used

#### ECR (Elastic Container Registry)
- Docker image storage in AWS
- Private registry for your organization
- Integrates with IAM for security

#### EC2 (Elastic Compute Cloud)
- Virtual servers in the cloud
- Runs your Kubernetes nodes
- **t3.micro**: 2 vCPU, 1GB RAM, ~$7/month

#### ELB (Elastic Load Balancer)
- Automatically created by Kubernetes Service
- Distributes traffic across pods
- Provides a stable DNS name

### Module 5: Monitoring and Debugging

**View logs**:
```cmd
kubectl logs deployment/helloworld-deployment
kubectl logs -f POD_NAME  # Follow logs
```

**Execute commands in pod**:
```cmd
kubectl exec -it POD_NAME -- /bin/bash
```

**Describe resources**:
```cmd
kubectl describe deployment helloworld-deployment
kubectl describe pod POD_NAME
```

**Events**:
```cmd
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Module 6: Making Changes

**Update the application**:
1. Edit `HelloWorldApp\Program.cs`
2. Build new Docker image with a tag:
   ```cmd
   docker build -t helloworld-app:v2 .
   ```
3. Push to ECR with new tag
4. Update `k8s\deployment.yaml` with new image tag
5. Apply changes:
   ```cmd
   kubectl apply -f k8s\deployment.yaml
   ```
6. Watch rolling update:
   ```cmd
   kubectl rollout status deployment/helloworld-deployment
   ```

**Rollback if needed**:
```cmd
kubectl rollout undo deployment/helloworld-deployment
```

## 💰 Cost Optimization Tips

### For K3s on EC2
1. **Use t4g instances** (ARM) - 20% cheaper than t3
2. **Use Spot Instances** - Up to 90% discount (but can be terminated)
3. **Use gp3 storage** - Cheaper than gp2
4. **Stop instance when not in use** - No compute charges when stopped
5. **Set up CloudWatch alerts** - Monitor unexpected usage

### For EKS
1. **Use Fargate Spot** - Cheaper than regular Fargate
2. **Right-size node instances** - Start with t3.micro
3. **Use Cluster Autoscaler** - Scale down unused nodes
4. **Delete test resources** - Always clean up after testing
5. **Use AWS Free Tier** - 750 hours/month of t3.micro for 12 months

### General
1. **Delete unused ECR images** - Old images cost storage
2. **Use single AZ** (for testing) - Multi-AZ costs more
3. **Monitor with AWS Cost Explorer** - Track daily spending
4. **Set up billing alerts** - Get notified at thresholds

## 🔍 Troubleshooting

### Windows-Specific Issues

#### Issue: "'docker' is not recognized as internal or external command"
**Solution**: 
1. Ensure Docker Desktop is running (check system tray)
2. Restart Command Prompt after Docker Desktop installation
3. Verify installation: `docker --version`

#### Issue: "'aws' is not recognized as internal or external command"
**Solution**:
1. Restart Command Prompt after AWS CLI installation
2. Verify PATH includes: `C:\Program Files\Amazon\AWSCLIV2\`
3. Check: `echo %PATH%`

#### Issue: "The security token included in the request is invalid" or AWS authentication errors
**Solution**: Your AWS credentials are not configured or are invalid.

1. **Verify current configuration**:
   ```cmd
   aws sts get-caller-identity
   ```
   If this fails, your credentials need to be set up.

2. **Reconfigure AWS CLI**:
   ```cmd
   aws configure
   ```
   Enter:
   - AWS Access Key ID (from IAM user)
   - AWS Secret Access Key (from IAM user)
   - Default region: `us-east-1`
   - Output format: `json`

3. **If you don't have access keys**:
   - Go to AWS Console → IAM → Users
   - Select your user → Security credentials tab
   - Click "Create access key"
   - Select "Command Line Interface (CLI)"
   - Download/copy both Access Key ID and Secret Key
   - Run `aws configure` with these credentials

4. **Verify it works**:
   ```cmd
   aws sts get-caller-identity
   aws ecr describe-repositories --region us-east-1
   ```

#### Issue: "User is not authorized to perform: ecr:CreateRepository" or other permission denied errors
**Solution**: Your IAM user lacks necessary permissions.

1. **Go to AWS Console** → IAM → Users
2. **Select your user** (e.g., `dev`)
3. Click **Add permissions** → **Attach policies directly**
4. **Search and select** the required policy:
   - For ECR: `AmazonEC2ContainerRegistryFullAccess`
   - For EC2: `AmazonEC2FullAccess`
   - For EKS: `AmazonEKSClusterPolicy`*-+
   +--
5. Click **Add permissions**
6. Try the command again

**Note**: For production, use more restrictive policies. For learning, full access policies are fine.

#### Issue: "'kubectl' is not recognized as internal or external command"
**Solution**:
1. Verify kubectl is installed: Check `C:\kubectl\kubectl.exe` exists
2. Add to PATH (see Prerequisites section)
3. Restart Command Prompt
4. Or install via Chocolatey: `choco install kubernetes-cli`

#### Issue: SSH connection fails with "WARNING: UNPROTECTED PRIVATE KEY FILE!"
**Solution**: Fix key file permissions on Windows:
```cmd
cd C:\Users\YOUR_USERNAME\.ssh
icacls aws-key.pem /inheritance:r
icacls aws-key.pem /grant:r "%USERNAME%:R"
```

#### Issue: kubectl cannot connect - "Unable to connect to the server"
**Solution**:
1. Check Security Group allows port 6443 from your current IP
2. Get your IP: Visit https://whatismyipaddress.com/
3. Update EC2 Security Group inbound rules
4. Verify config file: `type %USERPROFILE%\.kube\config`
5. Check EC2 public IP hasn't changed (restart changes the IP)

#### Issue: TLS certificate error "x509: certificate is valid for ... not YOUR_PUBLIC_IP"
**This is the most common issue!** K3s certificate doesn't include your public IP.

**Quick Fix** (for learning/testing):
1. Open your kubectl config file:
   ```cmd
   notepad %USERPROFILE%\.kube\config
   ```
2. Find the `clusters:` section
3. **Remove or comment out** the `certificate-authority-data` line
4. Add `insecure-skip-tls-verify: true` (same indentation as `server:`):
   ```yaml
   clusters:
   - cluster:
       # certificate-authority-data: LS0tLS...  <- Delete or comment out
       server: https://13.57.56.10:6443
       insecure-skip-tls-verify: true  <- Add this
     name: default
   ```
5. Save and try again:
   ```cmd
   kubectl get nodes
   ```

**Note**: You cannot have both `certificate-authority-data` and `insecure-skip-tls-verify: true` at the same time.

**Proper Fix** (recommended):
1. SSH back into your EC2 instance
2. Uninstall K3s:
   ```bash
   sudo /usr/local/bin/k3s-uninstall.sh
   ```
3. Reinstall with your public IP:
   ```bash
   # Get your public IP
   PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
   echo $PUBLIC_IP
   
   # Install K3s with public IP in certificate
   curl -sfL https://get.k3s.io | sh -s - --tls-san $PUBLIC_IP
   ```
4. Get the new kubeconfig and update your Windows config file again

#### Issue: Line ending issues in scripts (.cmd files)
**Solution**:
- If scripts fail, ensure they have Windows line endings (CRLF)
- In VS Code: Click "LF" in status bar → Select "CRLF"
- Or use: `notepad script-name.cmd` to edit

### General Issues

### Issue: Docker build fails
**Solution**: 
1. Ensure you're in the project root directory:
   ```cmd
   cd /d d:\dev\TestProjects\AWS
   dir
   ```
2. Verify Dockerfile exists in current directory
3. Check Docker Desktop is running

### Issue: Cannot connect to Kubernetes
**Solution**: 
```cmd
kubectl config get-contexts
kubectl config use-context YOUR_CONTEXT
```

### Issue: Pods not starting
**Solution**: Check pod logs
```cmd
kubectl get pods
kubectl logs POD_NAME
kubectl describe pod POD_NAME
```

### Issue: Image pull error
**Solution**: 
1. Verify ECR permissions
2. Check image URI in deployment.yaml
3. Ensure EC2 instance has ECR access (IAM role)

### Issue: Service has no external IP
**Solution**:
- For K3s: Use NodePort instead of LoadBalancer
- Edit `k8s\service.yaml`:
  ```yaml
  type: NodePort
  ```

### Issue: Cannot access app from browser
**Solution**:
1. Check security group allows port 80
2. Verify service is running: `kubectl get svc`
3. Check pod logs for errors
4. Test from EC2 instance: `curl http://localhost:8080`

## 📖 Learning Resources

### Official Documentation
- [.NET Documentation](https://docs.microsoft.com/dotnet/)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)

### Tutorials
- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [AWS EKS Workshop](https://www.eksworkshop.com/)
- [Docker for Beginners](https://docker-curriculum.com/)

### Tools
- [K9s](https://k9scli.io/) - Terminal UI for Kubernetes
- [Lens](https://k8slens.dev/) - Kubernetes IDE
- [AWS CLI Cheat Sheet](https://docs.aws.amazon.com/cli/latest/reference/)

## 🎯 Next Steps

1. **Add a database** - Deploy PostgreSQL or MongoDB
2. **Implement CI/CD** - Use GitHub Actions or AWS CodePipeline
3. **Add monitoring** - Prometheus + Grafana
4. **Implement logging** - ELK stack or CloudWatch Logs
5. **Add authentication** - OAuth2/OIDC
6. **Use Ingress** - NGINX Ingress for better routing
7. **Implement TLS** - Let's Encrypt certificates

## 🛡️ Security Best Practices

1. **Use secrets** - Never hardcode credentials
2. **Scan images** - Use `docker scan` or Trivy
3. **Update regularly** - Keep dependencies current
4. **Use least privilege** - Minimal IAM permissions
5. **Enable network policies** - Restrict pod communication

## 🧹 Cleanup

To avoid ongoing charges:

```cmd
# Delete Kubernetes resources
scripts\k8s-delete.cmd

# For EKS, delete the cluster
eksctl delete cluster --name helloworld-cluster --region us-east-1

# For EC2, terminate the instance
aws ec2 terminate-instances --instance-ids YOUR_INSTANCE_ID

# Delete ECR repository
aws ecr delete-repository --repository-name helloworld-app --force --region us-east-1
```

## 📝 License

This is a learning project - free to use and modify.

## 🤝 Contributing

Feel free to fork, modify, and improve!

---

**Happy Learning! 🚀**
