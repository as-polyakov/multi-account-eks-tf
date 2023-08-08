# main.tf

provider "aws" {
  assume_role {
    role_arn     = "arn:aws:iam::${var.aws_account_id}:role/apolyakov-cross-account-eks"
    #role_arn     = "arn:aws:iam::${var.aws_account_id}:role/jenkins"
    session_name = "terraform"
  }
  region = var.region
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_subnet" "this" {
  for_each = toset(data.aws_subnets.this.ids)
  id       = each.value
}

module "eks_cluster" {
  source  = "github.com/datarobot/ci-tf-modules-aws-eks-cluster?ref=CI-1397"
  name                                  = var.cluster_name
  cluster_version                       = var.cluster_version
  vpc_id                                = var.vpc_id
  cluster_iam_role_name                 = var.cluster_iam_role_name
  default_group_create_endpoint_rules   = false
  subnets                               = []

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "19.16.0"  # Use the latest version of the AWS EKS module
  name = "node-group"

  cluster_name      = module.eks_cluster.cluster_name
  subnet_ids = [for subnet in data.aws_subnet.this : subnet.id if subnet.availability_zone != "us-east-1e"]
  instance_types     = [var.node_type]
  desired_size = 1
  max_size      = 5
  min_size      = 1
}

output "cluster_id" {
  value = module.eks_cluster.cluster_id
}
