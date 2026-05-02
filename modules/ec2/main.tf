# 1. DYNAMIC AMI LOOKUP (Internal to the module)
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

# 2. SECURITY GROUP (Tightly coupled to the server)
resource "aws_security_group" "this" {
  name        = "${var.project_name}-app-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = var.vpc_id # Passed in from the root


  # 🔓 PUBLIC ACCESS
  # We allow SSH (22) and HTTP (80) from anywhere (0.0.0.0/0).
  # TODO: In production, SSH should be restricted to the company VPN IP only.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins UI Access
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In production, restrict this to your IP!
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

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

# 3. EC2 INSTANCE
resource "aws_instance" "this" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  key_name = "fintech-key-2026"

  subnet_id              = var.subnet_id # Passed in from the root
  vpc_security_group_ids = [aws_security_group.this.id]

  tags = {
    Name    = "${var.project_name}-app-server"
    Project = var.project_name
  }
}

# 4. NOTIFICATION (Local Execution)
resource "null_resource" "status_echo" {
  # This trigger ensures the echo runs every time the server ID changes
  triggers = {
    server_id = aws_instance.this.id
  }

  provisioner "local-exec" {
    command = "echo '✅ SERVER IS READY! IP Address: ${aws_instance.this.public_ip}'"
  }
}
