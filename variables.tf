variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "eu-north-1" # Stockholm
}

variable "instance_type" {
  description = "EC2 instance type (e.g., t3.micro, t3.medium)"
  type        = string
  default     = "t3.micro"
}

variable "project_name" {
  description = "The name of the project, used for tagging"
  type        = string
  default     = "FinTech-IaC"
}
