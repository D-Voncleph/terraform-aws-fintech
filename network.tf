# 1. THE VPC (The Land)
resource "aws_vpc" "fintech_vpc" {
  cidr_block           = "10.0.0.0/16" # Holds 65,536 IPs
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "FinTech-VPC"
    Project = var.project_name
  }
}

# 2. THE INTERNET GATEWAY (The Front Door)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.fintech_vpc.id

  tags = {
    Name    = "FinTech-IGW"
    Project = var.project_name
  }
}

# 3. PUBLIC SUBNET (For the Web Server)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.fintech_vpc.id
  cidr_block              = "10.0.1.0/24" # 10.0.1.x
  map_public_ip_on_launch = true          # Auto-assign public IP
  availability_zone       = "${var.aws_region}a" # e.g., eu-north-1a

  tags = {
    Name    = "FinTech-Public-Subnet"
    Project = var.project_name
  }
}

# 4. PRIVATE SUBNET (For Future Database)
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.fintech_vpc.id
  cidr_block        = "10.0.2.0/24" # 10.0.2.x
  availability_zone = "${var.aws_region}a" # Keep in same AZ for low latency

  tags = {
    Name    = "FinTech-Private-Subnet"
    Project = var.project_name
  }
}

# 5. PUBLIC ROUTE TABLE (The Directions)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.fintech_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "FinTech-Public-RT"
    Project = var.project_name
  }
}

# 6. ASSOCIATION (Linking Subnet to Route Table)
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}
