# ---------------------------------------------------------
# 1. PROVIDER
# ---------------------------------------------------------
provider "aws" {
  region = "eu-north-1" # Stockholm
}

# ---------------------------------------------------------
# 2. STORAGE (S3 Bucket - From last week)
# ---------------------------------------------------------
resource "aws_s3_bucket" "product_images" {
  bucket        = "voncleph-ecommerce-product-images"
  force_destroy = true

  tags = {
    Name        = "FinTech Product Images"
    Environment = "Dev"
    Project     = "FinTech-IaC"
  }
}

# ---------------------------------------------------------
# 3. DATA SOURCES (Dynamic Lookups)
# ---------------------------------------------------------
# Fetch the latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ---------------------------------------------------------
# 4. NETWORK SECURITY (Firewall)
# ---------------------------------------------------------
resource "aws_security_group" "app_sg" {
  name        = "fintech-app-sg"
  description = "Allow HTTP and SSH traffic"

  # Allow SSH (for management)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP (for the Frontend)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------------------------------------
# 5. COMPUTE (EC2 Instance)
# ---------------------------------------------------------
resource "aws_instance" "app_server" {
  # Reference the Data Source
  ami           = data.aws_ami.ubuntu.id
  
  # Use t3.micro for eu-north-1 (Stockholm)
  instance_type = "t3.micro"

  # Reference the Security Group
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name    = "FinTech-App-Server"
    Project = "FinTech-IaC"
  }
}
