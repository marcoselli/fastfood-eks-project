provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "FastFood"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}