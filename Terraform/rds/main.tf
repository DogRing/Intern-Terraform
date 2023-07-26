resource "aws_instance" "main" {
  ami                    = var.instance_AMI
  instance_type          = var.instance_type
  key_name               = var.key-pair
  vpc_security_group_ids = [var.vpc_security_group_id]

  subnet_id = var.private_subnets_id[random_integer.subnet.result - 1]
  tags      = { Name = "${var.prefix}-mysql" }
}

resource "random_integer" "subnet" {
  min = 1
  max = length(var.private_subnets_id)
}
