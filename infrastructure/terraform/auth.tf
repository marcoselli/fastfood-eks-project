# Obter as informações do usuário AWS atual
data "aws_caller_identity" "current" {}

# Provider Kubernetes para interagir com o cluster EKS
provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks_cluster.name]
    command     = "aws"
  }
}

# Atualizar o ConfigMap aws-auth existente com mapeamento de usuários
resource "kubernetes_config_map_v1_data" "aws_auth_users" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  # Adicionar o usuário atual ao ConfigMap existente
  data = {
    mapUsers = yamlencode([
      {
        userarn  = data.aws_caller_identity.current.arn
        username = "terraform-user"
        groups   = ["system:masters"]
      }
    ])
  }

  # Importante: não sobrescrever os roles que já existem no ConfigMap
  force = false

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.eks_node_group
  ]
}