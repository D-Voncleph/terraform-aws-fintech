variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
}

variable "subnet_id" {
  description = "The Subnet ID where the instance will be launched"
  type        = string
}

variable "instance_type" {
  description = "The size of the instance"
  type        = string
  default     = "t3.micro"
}

variable "project_name" {
  description = "The project name for tagging"
  type        = string
}
