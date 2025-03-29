# FastFood EKS Project

This project implements a Kubernetes infrastructure on Amazon EKS for the FastFood application, using Terraform for provisioning and Kustomize for Kubernetes manifest management.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Deployment Instructions

### 1. Initialize Terraform

```bash
cd infrastructure/terraform
terraform init
```

### 2. Review and Customize Configuration (Optional)

Review the configuration in `terraform.tfvars`:

```bash
# Example: Customize the environment or other parameters
vi terraform.tfvars
```

### 3. Plan Your Infrastructure

```bash
terraform plan
```

### 4. Apply Terraform Configuration

```bash
terraform apply
```

Review the changes and confirm by typing `yes`.

### 5. Configure kubectl to Access the Cluster

After Terraform completes, it will output the command to configure kubectl:

```bash
# The output will provide a command similar to:
aws eks update-kubeconfig --name fastfood-eks-cluster --region us-east-1
```

### 6. Verify Cluster Connection

Confirm that you can communicate with the cluster:

```bash
kubectl get nodes
```

### 7. Apply Kubernetes Manifests

Navigate to the kubernetes directory and apply the manifests using Kustomize:

```bash
cd ../../kubernetes/base
kubectl apply -k .
```

### 8. Verify Application Status

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

## Accessing the Application

The FastFood API is exposed as a NodePort service. To access it:

```bash
# Get the NodePort of the service
kubectl get svc fastfood-api-service -n fastfood

# For local testing, you can use port-forwarding:
kubectl port-forward service/fastfood-api-service 8080:80 -n fastfood
```

Then access the API at http://localhost:8080

## Architecture

This project uses the following components:

- **Amazon EKS**: For container orchestration
- **Terraform**: For infrastructure as code
- **VPC**: Custom VPC with public and private subnets
- **IAM Roles**: Properly configured for EKS and node groups
- **EBS CSI Driver**: For persistent volume support
- **Kubernetes**: For containerized application management
- **Kustomize**: For Kubernetes configuration management

## Terraform Resources

The infrastructure includes:

- VPC with public and private subnets
- Internet Gateway and NAT Gateway
- EKS Cluster with appropriate IAM roles
- Node groups for running containers
- Security groups for cluster and nodes
- EBS CSI Driver add-on for persistent storage

## Project Structure

```
fastfood-eks-project/
├── infrastructure/
│   └── terraform/
│       ├── main.tf            # Main Terraform configuration
│       ├── variables.tf       # Variable definitions
│       ├── outputs.tf         # Output values
│       ├── terraform.tfvars   # Variable values
│       └── auth.tf            # IAM configuration for EKS access
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

## Cleanup

To destroy the infrastructure when no longer needed:

```bash
cd infrastructure/terraform
terraform destroy
```

## Troubleshooting

### Common Issues

1. **EKS Authentication Issues**:
   ```bash
   # Update kubeconfig
   aws eks update-kubeconfig --name fastfood-eks-cluster --region us-east-1
   ```

2. **Persistent Volume Claims Stuck in Pending**:
   ```bash
   # Check if the EBS CSI Driver is properly installed
   kubectl get pods -n kube-system | grep ebs
   ```

3. **Database Connection Issues**:
   ```bash
   # Check if MySQL service is running
   kubectl get pods -n fastfood -l app=mysql
   kubectl logs -n fastfood -l app=mysql
   ```

## Support

For more information or support, please refer to the internal documentation or contact the DevOps team.