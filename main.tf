provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------
# 1. NETWORK MODULE
# ---------------------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  availability_zone   = "${var.aws_region}a"
  project_name        = var.project_name
}

# ---------------------------------------------------------
# 2. COMPUTE MODULE
# ---------------------------------------------------------
module "server" {
  source = "./modules/ec2"

  # We pass data FROM the VPC module INTO the EC2 module
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_id

  instance_type = var.instance_type
  project_name  = var.project_name
}

# ---------------------------------------------------------
# 3. STORAGE (Keeping S3 separate for now)
# ---------------------------------------------------------
resource "aws_s3_bucket" "product_images" {
  bucket        = "voncleph-ecommerce-product-images"
  force_destroy = true

  tags = {
    Name    = "FinTech Product Images"
    Project = var.project_name
  }
}

