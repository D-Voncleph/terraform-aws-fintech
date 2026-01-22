output "server_public_ip" {
  description = "The public IP address of the application server"
  value       = module.server.server_public_ip
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket used for product images" # <--- Added this
  value       = aws_s3_bucket.product_images.id
}
