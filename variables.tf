
variable "region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}


variable "vpc_id" {
  description = "VPC where cluster should be created"
  type        = string
}

variable "node_type" {
  description = "The EC2 instance type for the EKS worker nodes."
  type        = string
}

variable "aws_account_id" {
  description = "The AWS account ID where the resources will be created."
  type        = string
}

variable "cluster_iam_role_name" {
  description = "IAM role name for the cluster."
  type        = string
}
variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
}



