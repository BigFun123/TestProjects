@echo off
REM Deploy to Kubernetes cluster
echo ===================================
echo Deploy to Kubernetes
echo ===================================

echo.
echo Applying ConfigMap...
kubectl apply -f k8s\configmap.yaml

echo.
echo Applying Deployment...
kubectl apply -f k8s\deployment.yaml

echo.
echo Applying Service...
kubectl apply -f k8s\service.yaml

echo.
echo Applying HPA (Horizontal Pod Autoscaler)...
kubectl apply -f k8s\hpa.yaml

echo.
echo ===================================
echo Deployment complete!
echo ===================================

echo.
echo Checking deployment status...
kubectl get deployments
kubectl get pods
kubectl get services

echo.
echo To get the LoadBalancer URL:
echo kubectl get service helloworld-service
