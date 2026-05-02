# Terraform EKS Module: Code Breakdown and Architecture

This document serves as the Upscale DV internal playbook for understanding the official AWS EKS Terraform module (`terraform-aws-modules/eks/aws`).

By utilizing this module, we abstract the immense complexity of writing raw CloudFormation, IAM policy documents, and Auto Scaling Groups into a single, declarative block of Infrastructure as Code (IaC).

---

## The Core Module Configuration

Below is the standard EKS module block used for our cloud deployments, followed by a line-by-line architectural breakdown.

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    standard_workers = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  enable_cluster_creator_admin_permissions = true
}
```

---

## Architectural Breakdown

### 1. Source and Versioning

- **`source`**: Instructs Terraform to download the pre-packaged code directly from the official HashiCorp Terraform Registry.
- **`version`**: Pins the module to major version 20 to prevent breaking changes during future `terraform init` or `apply` executions.

### 2. Cluster Configuration (The Control Plane)

- **`cluster_name` & `cluster_version`**: Defines the physical name of the cluster in AWS and pins the Kubernetes API version (e.g., `1.30`).
- **`cluster_endpoint_public_access = true`**: Critical for remote management. This allows external DevOps engineers (or CI/CD pipelines like GitHub Actions) to communicate with the Kubernetes API server across the public internet.

  > **Note:** The actual Worker Nodes remain isolated in private subnets; only the API endpoint is public.

### 3. Network Integration

- **`vpc_id` & `subnet_ids`**: Dynamically links the EKS cluster to the outputs of our VPC module. By specifically passing `module.vpc.private_subnets`, we enforce strict security architecture, ensuring all physical EC2 instances are hidden from direct public internet access.

### 4. Managed Node Groups (The Data Plane)

This block entirely replaces the need to manually code AWS Auto Scaling Groups (ASGs) and Launch Templates.

- **`min_size`, `max_size`, `desired_size`**: Defines the scaling constraints for the Worker Nodes. The cluster will boot with 2 nodes but is permitted to scale up to 3 during high traffic.
- **`instance_types`**: Specifies the compute hardware (e.g., `t3.medium`).
- **`capacity_type`**: Set to `ON_DEMAND` for standard reliability. For cost-optimization on non-critical workloads, this can be changed to `SPOT`.
- **Invisible Action**: Behind the scenes, defining this block automatically generates the highly complex "Worker Node IAM Role" required for the EC2 instances to communicate with the EKS Control Plane.

### 5. Access Management

- **`enable_cluster_creator_admin_permissions = true`**: Automatically maps the AWS IAM user/role that runs `terraform apply` to the `system:masters` group inside Kubernetes. Without this, the cluster would be built, but the provisioning engineer would be locked out of the API.
