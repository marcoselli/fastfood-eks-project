# FastFood EKS Project

This project implements a Kubernetes infrastructure on Amazon EKS for the FastFood application, using CloudFormation for provisioning and Kustomize for Kubernetes manifest management.

## Deployment Instructions

### 1. Apply CloudFormation

```bash
cd fastfood-eks-project/infrastructure/cloudformation
aws cloudformation create-stack \
  --stack-name fastfood-eks-stack \
  --template-body file://fastfood-eks-cluster.yaml \
  --capabilities CAPABILITY_NAMED_IAM
```

### 2. Wait for stack creation to complete

```bash
aws cloudformation describe-stacks --stack-name fastfood-eks-stack --query "Stacks[0].StackStatus"
```

Wait until the status is `CREATE_COMPLETE`.

### 3. Get the cluster name

Retrieve the cluster name from the stack outputs:

```bash
aws cloudformation describe-stacks --stack-name fastfood-eks-stack --query "Stacks[0].Outputs[?OutputKey=='ClusterName'].OutputValue" --output text
```

### 4. Configure kubectl to access the cluster

Use the aws eks update-kubeconfig command to configure access:

```bash
aws eks update-kubeconfig --name fastfood-eks-cluster --region us-east-1
```

### 5. Verify cluster connection

Confirm that you can communicate with the cluster:

```bash
kubectl get nodes
```

### 6. Apply Kubernetes manifests

Now you can apply your Kubernetes manifests. First, navigate to the directory where your YAML files are:

```bash
cd fastfood-eks-project/kubernetes/base
kubectl apply -k .  # If using kustomize
```

### 7. Verify application status

```bash
# Check pods
kubectl get pods -n fastfood

# Check services
kubectl get svc -n fastfood

# Check deployments
kubectl get deployments -n fastfood

# Check HPA
kubectl get hpa -n fastfood
```

## Architecture

This project uses the following components:

- **Amazon EKS**: For container orchestration
- **CloudFormation**: For infrastructure provisioning
- **Kubernetes**: For containerized application management
- **Kustomize**: For Kubernetes configuration management

## Project Structure

```
fastfood-eks-project/
├── infrastructure/
│   ├── cloudformation/
│   │   └── fastfood-eks-cluster.yaml
│   └── terraform/
│       └── ...
├── kubernetes/
│   ├── base/
│   │   ├── namespace/
│   │   ├── storage/
│   │   ├── database/
│   │   ├── application/
│   │   ├── config/
│   │   └── kustomization.yaml
│   └── overlays/
│       ├── development/
│       ├── staging/
│       └── production/
└── README.md
```

## Support

For more information or support, please refer to the internal documentation or contact the DevOps team.
