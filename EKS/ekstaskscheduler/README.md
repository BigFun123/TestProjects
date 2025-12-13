# EKS Task Scheduler

A .NET 8 application that schedules API calls to a "Hello World" endpoint. This project includes both the scheduler service and the web API, with support for local Docker testing and EKS deployment via Kubernetes CronJob.

## Project Structure

```
EKS/
├── ekswebapi/              # Simple Web API with hello endpoint
│   ├── Program.cs
│   ├── Controllers/
│   │   └── HelloController.cs
│   ├── Dockerfile
│   └── ekswebapi.csproj
│
└── ekstaskscheduler/       # Scheduler service that calls the API
    ├── Program.cs
    ├── ApiSchedulerService.cs
    ├── Dockerfile
    ├── docker-compose.yml
    ├── k8s-cronjob.yaml
    └── ekstaskscheduler.csproj
```

## Local Testing with Docker

### Prerequisites
- Docker Desktop installed and running
- Docker Compose installed

### Run Locally

1. Navigate to the scheduler directory:
```cmd
cd d:\dev\TestProjects\EKS\ekstaskscheduler
```

2. Build and run both services:
```cmd
docker-compose up --build
```

3. The API will be available at `http://localhost:5000/api/hello`

4. The scheduler will run once and call the API endpoint, then exit.

5. To test the scheduler again:
```cmd
docker-compose up ekstaskscheduler
```

6. To stop all services:
```cmd
docker-compose down
```

### Testing the API Manually

Test the API endpoint directly:
```cmd
curl http://localhost:5000/api/hello
```

Expected response:
```json
{
  "message": "Hello World!",
  "timestamp": "2024-12-13T10:30:00.000Z"
}
```

## Deploying to EKS

### Prerequisites
- AWS CLI configured
- kubectl installed and configured for your EKS cluster
- ECR repository created for both images
- Docker logged into ECR

### Build and Push Images

1. Login to ECR:
```cmd
aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.<your-region>.amazonaws.com
```

2. Build and push the Web API:
```cmd
cd d:\dev\TestProjects\EKS\ekswebapi
docker build -t ekswebapi .
docker tag ekswebapi:latest <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/ekswebapi:latest
docker push <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/ekswebapi:latest
```

3. Build and push the Scheduler:
```cmd
cd d:\dev\TestProjects\EKS\ekstaskscheduler
docker build -t ekstaskscheduler .
docker tag ekstaskscheduler:latest <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/ekstaskscheduler:latest
docker push <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/ekstaskscheduler:latest
```

### Deploy to Kubernetes

1. Update the image references in `k8s-cronjob.yaml`:
   - Replace `<YOUR_ECR_REPO>` with your ECR repository URL
   - Example: `123456789012.dkr.ecr.us-east-1.amazonaws.com`

2. Apply the Kubernetes manifests:
```cmd
kubectl apply -f k8s-cronjob.yaml
```

3. Verify the deployment:
```cmd
kubectl get pods -n eks-scheduler
kubectl get cronjob -n eks-scheduler
kubectl get service -n eks-scheduler
```

### CronJob Schedule

The CronJob is configured to run every 5 minutes by default. To change the schedule, edit the `schedule` field in `k8s-cronjob.yaml`:

```yaml
schedule: "*/5 * * * *"  # Every 5 minutes
```

Common schedule examples:
- `*/5 * * * *` - Every 5 minutes
- `0 * * * *` - Every hour at minute 0
- `0 0 * * *` - Every day at midnight
- `0 */6 * * *` - Every 6 hours
- `0 9 * * 1-5` - 9 AM Monday through Friday

### Monitoring

View CronJob history:
```cmd
kubectl get jobs -n eks-scheduler
```

View scheduler logs:
```cmd
kubectl logs -n eks-scheduler -l app=api-scheduler
```

View API logs:
```cmd
kubectl logs -n eks-scheduler -l app=ekswebapi
```

Manually trigger a job (for testing):
```cmd
kubectl create job --from=cronjob/api-scheduler-cronjob manual-test -n eks-scheduler
```

### Cleanup

Remove all resources:
```cmd
kubectl delete namespace eks-scheduler
```

## Configuration

### Scheduler Configuration

The scheduler can be configured via environment variables:

- `ApiSettings__BaseUrl` - Base URL of the API (default: `http://localhost:5000`)
- `ApiSettings__Endpoint` - API endpoint path (default: `/api/hello`)

### Kubernetes Resources

The CronJob is configured with the following resource limits:

**Scheduler:**
- Requests: 50m CPU, 64Mi memory
- Limits: 200m CPU, 128Mi memory

**Web API:**
- Requests: 100m CPU, 128Mi memory
- Limits: 500m CPU, 256Mi memory

Adjust these values in `k8s-cronjob.yaml` based on your workload requirements.

## Troubleshooting

### Scheduler not calling API

1. Check if the API pod is running:
```cmd
kubectl get pods -n eks-scheduler
```

2. Check scheduler logs for errors:
```cmd
kubectl logs -n eks-scheduler -l app=api-scheduler --tail=50
```

3. Verify the API service is accessible:
```cmd
kubectl run -it --rm debug --image=busybox --restart=Never -n eks-scheduler -- wget -O- http://ekswebapi-service/api/hello
```

### CronJob not running

1. Check CronJob status:
```cmd
kubectl describe cronjob api-scheduler-cronjob -n eks-scheduler
```

2. Verify the schedule is correct and in UTC timezone

3. Check for suspended jobs:
```cmd
kubectl get cronjob -n eks-scheduler -o yaml
```

## Development

To modify the scheduler behavior:

1. Edit `ApiSchedulerService.cs` for business logic
2. Edit `appsettings.json` for configuration defaults
3. Rebuild and redeploy using the steps above

## License

This is a sample project for demonstration purposes.
