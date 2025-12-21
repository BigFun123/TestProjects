# HelloTask

A C# console application that runs as a scheduled Amazon ECS task every hour using EventBridge (CloudWatch Events).

## Overview

This project demonstrates how to:
- Build a containerized C# application
- Push it to Amazon ECR (Elastic Container Registry)
- Run it as a scheduled Fargate task on Amazon ECS
- Use EventBridge to trigger the task every hour

## Prerequisites

- [.NET 8.0 SDK](https://dotnet.microsoft.com/download)
- [Docker](https://www.docker.com/get-started)
- [AWS CLI](https://aws.amazon.com/cli/) configured with credentials
- AWS Account with permissions for ECS, ECR, EventBridge, IAM, and CloudWatch Logs

## Quick Start

Run the numbered scripts in order:

```cmd
1-build-image.cmd
2-create-ecr-repo.cmd us-east-1
3-push-to-ecr.cmd 123456789012 us-east-1
4-create-ecs-cluster.cmd us-east-1
5-create-task-role.cmd us-east-1
6-register-task-definition.cmd 123456789012 us-east-1
7-create-eventbridge-rule.cmd us-east-1
8-create-ecs-target.cmd 123456789012 us-east-1 subnet-xxx subnet-yyy sg-zzz
9-verify-setup.cmd us-east-1
```

Replace:
- `123456789012` with your AWS account ID
- `us-east-1` with your AWS region
- `subnet-xxx`, `subnet-yyy`, `sg-zzz` with your VPC subnet and security group IDs

## Step-by-Step Setup

### Step 1: Build Docker Image
```cmd
1-build-image.cmd
```
Builds the Docker image locally and tags it as `hello-task:latest`.

**What it does:**
- Compiles the C# application
- Creates a containerized version ready for deployment

---

### Step 2: Create ECR Repository
```cmd
2-create-ecr-repo.cmd <aws-region> [repository-name]
```
Creates an Amazon ECR repository to store the Docker image.

**Example:**
```cmd
2-create-ecr-repo.cmd us-east-1 hello-task
```

**What it does:**
- Creates a private container registry in AWS
- Enables image scanning for security vulnerabilities

---

### Step 3: Push to ECR
```cmd
3-push-to-ecr.cmd <aws-account-id> <aws-region> [repository-name]
```
Authenticates with ECR and pushes the Docker image.

**Example:**
```cmd
3-push-to-ecr.cmd 123456789012 us-east-1 hello-task
```

**What it does:**
1. Authenticates Docker with Amazon ECR
2. Tags the image with the ECR repository URI
3. Pushes the image to ECR
4. Displays the image URI for later steps

---

### Step 4: Create ECS Cluster
```cmd
4-create-ecs-cluster.cmd <aws-region> [cluster-name]
```
Creates an Amazon ECS cluster for running the scheduled tasks.

**Example:**
```cmd
4-create-ecs-cluster.cmd us-east-1 hello-task-cluster
```

**What it does:**
- Creates a Fargate-enabled ECS cluster
- Configures capacity providers for cost optimization

---

### Step 5: Create Task Execution Role
```cmd
5-create-task-role.cmd <aws-region>
```
Creates the IAM role that allows ECS to pull images and write logs.

**Example:**
```cmd
5-create-task-role.cmd us-east-1
```

**What it does:**
- Creates `ecsTaskExecutionRole` IAM role
- Attaches the `AmazonECSTaskExecutionRolePolicy`
- Allows ECS to pull from ECR and write to CloudWatch Logs

---

### Step 6: Register Task Definition
```cmd
6-register-task-definition.cmd <aws-account-id> <aws-region> [repository-name]
```
Registers the ECS task definition that describes how to run the container.

**Example:**
```cmd
6-register-task-definition.cmd 123456789012 us-east-1 hello-task
```

**What it does:**
- Defines container configuration (CPU, memory, environment)
- Specifies the ECR image to use
- Configures CloudWatch Logs

---

### Step 7: Create EventBridge Rule
```cmd
7-create-eventbridge-rule.cmd <aws-region> [rule-name]
```
Creates the schedule that triggers the task every hour.

**Example:**
```cmd
7-create-eventbridge-rule.cmd us-east-1 hello-task-hourly
```

**What it does:**
- Creates an EventBridge rule with cron expression: `cron(0 * * * ? *)`
- Runs at minute 0 of every hour (e.g., 1:00, 2:00, 3:00, etc.)

**Schedule Format:**
- Current: Every hour at minute 0
- To change: Edit the cron expression in the script
  - Every 30 minutes: `cron(0,30 * * * ? *)`
  - Every day at 2 AM: `cron(0 2 * * ? *)`
  - Every Monday at 9 AM: `cron(0 9 ? * MON *)`

---

### Step 8: Add ECS Target
```cmd
8-create-ecs-target.cmd <aws-account-id> <aws-region> <subnet-id-1> <subnet-id-2> <security-group-id>
```
Connects the EventBridge rule to the ECS task.

**Example:**
```cmd
8-create-ecs-target.cmd 123456789012 us-east-1 subnet-abc123 subnet-def456 sg-xyz789
```

**What it does:**
- Links the schedule to the ECS task
- Configures network settings (VPC, subnets, security groups)
- Activates the scheduled task

**Finding Network IDs:**
Run the helper script to find your VPC subnet and security group IDs:
```cmd
get-subnet-ids.cmd us-east-1
```

---

### Step 9: Verify Setup
```cmd
9-verify-setup.cmd <aws-region>
```
Verifies that all components are properly configured.

**Example:**
```cmd
9-verify-setup.cmd us-east-1
```

**What it does:**
- Checks EventBridge rule status
- Verifies ECS cluster and task definition
- Confirms target configuration
- Provides next steps and useful commands

---

## Helper Scripts

### Get Subnet IDs
```cmd
get-subnet-ids.cmd <aws-region>
```
Finds your default VPC subnet and security group IDs needed for step 8.

---

### Run Task Manually
```cmd
run-task-now.cmd <aws-region> <subnet-id-1> <subnet-id-2> <security-group-id>
```
Runs the ECS task immediately for testing without waiting for the schedule.

**Example:**
```cmd
run-task-now.cmd us-east-1 subnet-abc123 subnet-def456 sg-xyz789
```

---

### View Logs
```cmd
view-logs.cmd <aws-region>
```
Displays recent CloudWatch Logs from the scheduled task executions.

**Example:**
```cmd
view-logs.cmd us-east-1
```

---

### Cleanup
```cmd
cleanup.cmd <aws-region>
```
**WARNING:** Deletes all resources created by this project.

**Example:**
```cmd
cleanup.cmd us-east-1
```

---

## Configuration Files

### task-definition.json
Defines the ECS task configuration:
- CPU and memory allocation
- Container image reference
- Environment variables
- CloudWatch Logs configuration

### task-execution-assume-role-policy.json
IAM trust policy that allows ECS to assume the execution role.

### ecs-target.json
EventBridge target configuration:
- ECS cluster and task definition
- Network configuration (VPC, subnets, security groups)
- Launch type (Fargate)

## Environment Variables

Configure in [task-definition.json](task-definition.json):

- `TASK_NAME` - Name identifier for the task (default: "HelloTask")
- `TARGET_URL` - URL for HTTP requests (default: "https://httpbin.org/get")

## Monitoring

### View Logs
CloudWatch Logs group: `/ecs/hello-task`

```cmd
view-logs.cmd us-east-1
```

### Check Task Executions
```cmd
aws ecs list-tasks --cluster hello-task-cluster --region us-east-1
```

### View EventBridge Rule
```cmd
aws events describe-rule --name hello-task-hourly --region us-east-1
```

### Disable Schedule (Temporarily)
```cmd
aws events disable-rule --name hello-task-hourly --region us-east-1
```

### Enable Schedule
```cmd
aws events enable-rule --name hello-task-hourly --region us-east-1
```

## Cost Optimization

- **Fargate Spot**: Task definition uses Fargate Spot for potential cost savings
- **Right-sizing**: Current allocation is 256 CPU / 512 MB memory. Adjust in [task-definition.json](task-definition.json) if needed
- **Scheduling**: Runs every hour. Adjust the cron expression in step 7 to reduce frequency

## Troubleshooting

### Task Not Running
1. Verify setup: `9-verify-setup.cmd us-east-1`
2. Check EventBridge rule is enabled
3. Verify network configuration (subnets, security groups)
4. Check IAM role permissions

### Can't See Logs
1. Wait a few minutes after task execution
2. Verify CloudWatch Logs group exists: `/ecs/hello-task`
3. Check task execution role has CloudWatch Logs permissions

### Network Errors
1. Ensure security group allows outbound HTTPS traffic
2. Verify subnets have internet access (NAT Gateway or public subnets with public IP enabled)
3. Check the task definition has `AssignPublicIp: ENABLED`

### Task Fails Immediately
1. View logs: `view-logs.cmd us-east-1`
2. Check container image exists in ECR
3. Verify environment variables in task definition
4. Test locally: `docker run hello-task:latest`

## Project Structure

```
HelloTask/
├── Program.cs                              # C# application code
├── HelloTask.csproj                        # .NET project file
├── Dockerfile                              # Container build instructions
├── task-definition.json                    # ECS task configuration
├── task-execution-assume-role-policy.json  # IAM trust policy
├── ecs-target.json                         # EventBridge target config
├── 1-build-image.cmd                       # Build Docker image
├── 2-create-ecr-repo.cmd                   # Create ECR repository
├── 3-push-to-ecr.cmd                       # Push to ECR
├── 4-create-ecs-cluster.cmd                # Create ECS cluster
├── 5-create-task-role.cmd                  # Create IAM role
├── 6-register-task-definition.cmd          # Register task
├── 7-create-eventbridge-rule.cmd           # Create schedule
├── 8-create-ecs-target.cmd                 # Link schedule to task
├── 9-verify-setup.cmd                      # Verify configuration
├── get-subnet-ids.cmd                      # Helper: Find network IDs
├── run-task-now.cmd                        # Helper: Manual execution
├── view-logs.cmd                           # Helper: View logs
├── cleanup.cmd                             # Helper: Delete resources
├── description.txt                         # Project description
└── README.md                               # This file
```

## AWS Resources Created

1. **ECR Repository**: `hello-task`
2. **ECS Cluster**: `hello-task-cluster`
3. **ECS Task Definition**: `hello-task`
4. **IAM Role**: `ecsTaskExecutionRole`
5. **EventBridge Rule**: `hello-task-hourly`
6. **CloudWatch Log Group**: `/ecs/hello-task`

## Additional Resources

- [Amazon ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [EventBridge Cron Expressions](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-cron-expressions.html)
- [AWS Fargate Pricing](https://aws.amazon.com/fargate/pricing/)
- [ECS Task Definitions](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html)
