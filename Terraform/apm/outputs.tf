output "apm-private-ip" {
  description = "for ecs containers"
  value       = aws_instance.main.private_ip
}
