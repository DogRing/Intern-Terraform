output "cluster-dns" {
  value = aws_instance.main.private_ip
}

output "db_user" {
  value = "testuser"
}

output "db_pw" {
  value = "test1234"
}
