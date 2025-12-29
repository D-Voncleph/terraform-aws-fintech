# 1. PROVIDER
provider "aws" {
  region = var.aws_region  # <--- CHANGED
}

# 2. STORAGE
resource "aws_s3_bucket" "product_images" {
  bucket        = "voncleph-ecommerce-product-images"
  force_destroy = true

  tags = {
    Name    = "FinTech Product Images"
    Environment = "Dev"
    Project = var.project_name # <--- CHANGED
  }
}

# 3. DATA SOURCE (Keep this dynamic!)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 4. SECURITY GROUP
resource "aws_security_group" "app_sg" {
  name        = "fintech-app-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.fintech_vpc.id  # <--- NEW LINE: Link to custom VPC

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. COMPUTE
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type      # <--- CHANGED
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name    = "FinTech-App-Server"
    Project = var.project_name           # <--- CHANGED
  }
}
