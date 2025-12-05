# 1. Define the Provider
provider "aws" {
  region = "eu-north-1"
}

# 2. Define the S3 Bucket Resource
resource "aws_s3_bucket" "product_images" {
  # The bucket name must be globally unique
  bucket = "voncleph-ecommerce-product-images"

  # Tags help organize resources in the AWS console
  tags = {
    Name        = "FinTech Product Images"
    Environment = "Dev"
    Project     = "FinTech-IaC"
  }
}
