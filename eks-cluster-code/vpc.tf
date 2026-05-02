# vpc.tf

# 1. Define the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# 2. Define a local variable for the cluster name so we can reuse it
locals {
  cluster_name = "upscale-fintech-cluster"
}

# 3. Call the Official AWS VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "fintech-eks-vpc"
  cidr = "10.0.0.0/16"

  # EKS requires at least 2 Availability Zones for High Availability
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  # Standard enterprise requirement: Private nodes need internet access to download Docker images
  enable_nat_gateway = true
  single_nat_gateway = true

  # 🛑 CRITICAL EKS TAGS: Public Subnets 
  # These tags tell the Kubernetes Cloud Controller where to place public Load Balancers
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  # 🛑 CRITICAL EKS TAGS: Private Subnets
  # These tags tell Kubernetes where to place internal-only Load Balancers
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}
