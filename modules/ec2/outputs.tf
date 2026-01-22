output "server_public_ip" {
  description = "The public IP of the web server"
  value       = aws_instance.this.public_ip
}

output "server_id" {
  value = aws_instance.this.id
}
