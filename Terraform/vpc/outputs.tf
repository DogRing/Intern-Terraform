output "vpc_id" {
  value = aws_vpc.main.id
}

output "cidr_block" {
  value = var.vpc_cidr_block
}

output "public_subnet_id" {
  value = aws_subnet.public.*.id
}

output "private_subnet_id" {
  value = aws_subnet.private.*.id
}

output "db_private_subnet_id" {
  value = aws_subnet.private-db.*.id
}

output "inner-cidr" {
  value = aws_vpc.main.cidr_block
}

output "availability_zones" {
  value = var.availability_zones
}
