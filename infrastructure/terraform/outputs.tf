output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_endpoint" {
  description = "The endpoint for Kubernetes API server"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.arn
}

output "node_group_id" {
  description = "The ID of the EKS node group"
  value       = aws_eks_node_group.eks_node_group.id
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.fastfood_vpc.id
}

output "public_subnets" {
  description = "The IDs of the public subnets"
  value       = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

output "private_subnets" {
  description = "The IDs of the private subnets"
  value       = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.eks_cluster.name} --region ${var.region}"
}

output "node_group_instance_role" {
  description = "The IAM role for the Node Group instances"
  value       = aws_iam_role.eks_node_role.arn
}