# main.tf

provider "aws" {
  assume_role {
    #role_arn     = "arn:aws:iam::${var.aws_account_id}:role/apolyakov-cross-account-eks"
    role_arn     = "arn:aws:iam::${var.aws_account_id}:role/jenkins"
    session_name = "terraform"
  }
  region = var.region
}

data "aws_subnets" "vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"  # Use the latest version of the AWS EKS module

  cluster_name = var.cluster_name
  subnet_ids      = "${data.aws_subnets.vpc_subnets.ids}"
  vpc_id       = var.vpc_id # Replace with your actual VPC ID

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "19.16.0"  # Use the latest version of the AWS EKS module

  cluster_name      = var.cluster_name
  subnet_ids      = "${data.aws_subnets.vpc_subnets.ids}"
  instance_types     = [var.node_type]
  desired_size = 1
  max_size      = 5
  min_size      = 1
}

output "cluster_id" {
  value = module.eks_cluster.cluster_id
}
