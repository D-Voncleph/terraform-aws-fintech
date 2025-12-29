output "s3_bucket_name" {
  description = "The name of the S3 bucket created"
  value       = aws_s3_bucket.product_images.id
}

output "server_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}
