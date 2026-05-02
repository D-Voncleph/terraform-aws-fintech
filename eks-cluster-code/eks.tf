# eks.tf

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  # 1. Cluster Setup
  cluster_name    = local.cluster_name
  cluster_version = "1.30"
  
  # Allow your local machine to communicate with the API Server
  cluster_endpoint_public_access  = true

  # 2. Network Integration
  # This wires the cluster directly into the VPC we built yesterday
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # 3. Worker Node Configuration (The Data Plane)
  # This completely replaces the need to manually build Auto Scaling Groups and IAM Node Roles
  eks_managed_node_groups = {
    standard_workers = {
      # Scale constraints
      min_size     = 1
      max_size     = 3
      desired_size = 2

      # Compute resources
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  # 4. Cluster Access
  # Gives the Terraform runner admin access to the cluster automatically
  enable_cluster_creator_admin_permissions = true
}
