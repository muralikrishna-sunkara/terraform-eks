#!/bin/bash

# ==========================================
# EKS LoadBalancer Troubleshooting Script
# ==========================================

CLUSTER_NAME="my-eks-cluster"
REGION="us-east-1"
NAMESPACE="demo"
SERVICE_NAME="test-app-lb"

echo "=========================================="
echo "Step 1: Check Service Status"
echo "=========================================="
kubectl get svc -n $NAMESPACE
kubectl describe svc $SERVICE_NAME -n $NAMESPACE

echo ""
echo "=========================================="
echo "Step 2: Check Pod Status"
echo "=========================================="
kubectl get pods -n $NAMESPACE -o wide
kubectl describe deployment test-app -n $NAMESPACE

echo ""
echo "=========================================="
echo "Step 3: Test Pod Connectivity"
echo "=========================================="
POD_NAME=$(kubectl get pods -n $NAMESPACE -l app=test-app -o jsonpath='{.items[0].metadata.name}')
echo "Testing pod: $POD_NAME"
kubectl exec -it $POD_NAME -n $NAMESPACE -- curl -s http://localhost:80 | head -20

echo ""
echo "=========================================="
echo "Step 4: Check Node Security Groups"
echo "=========================================="
# Get the security group IDs for the nodes
aws ec2 describe-instances \
  --filters "Name=tag:eks:nodegroup-name,Values=$CLUSTER_NAME-*" \
  --region $REGION \
  --query 'Reservations[*].Instances[*].[InstanceId,SecurityGroups[*].GroupId]' \
  --output text

echo ""
echo "=========================================="
echo "Step 5: Check LoadBalancer Details"
echo "=========================================="
LB_NAME=$(kubectl get svc $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' | cut -d'-' -f1)
aws elbv2 describe-load-balancers --region $REGION --query "LoadBalancers[?contains(DNSName, '${LB_NAME}')]" --output json

echo ""
echo "=========================================="
echo "Step 6: Check Target Groups"
echo "=========================================="
aws elbv2 describe-target-groups --region $REGION --query "TargetGroups[?contains(TargetGroupName, '${CLUSTER_NAME}')]" --output json

echo ""
echo "=========================================="
echo "Step 7: Test Direct Pod Access"
echo "=========================================="
kubectl run -n $NAMESPACE -it --image=curlimages/curl curl-test --restart=Never -- \
  curl -v http://$SERVICE_NAME:80/

# Cleanup
kubectl delete pod -n $NAMESPACE curl-test --ignore-not-found
