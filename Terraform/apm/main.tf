resource "aws_instance" "main" {
  ami                    = var.instance_AMI
  instance_type          = var.instance_type
  key_name               = var.key-pair
  vpc_security_group_ids = [aws_security_group.main.id]
  iam_instance_profile   = var.instance_IAM

  subnet_id = var.public_subnet_id[random_integer.subnet.result - 1]
  root_block_device {
    volume_size = 16
  }
  user_data = file("${path.module}/user_data.sh")
  tags      = { Name = "${var.prefix}-apm" }
}

resource "random_integer" "subnet" {
  min = 1
  max = length(var.public_subnet_id)
}

resource "aws_security_group" "main" {
  name        = "${var.prefix}-apm"
  vpc_id      = var.vpc_id
  description = "${var.prefix}-apm-server"
  tags        = { Name = "${var.prefix}-apm" }
}

resource "aws_security_group_rule" "ingress_vpc" {
  type              = "ingress"
  protocol          = "-1"
  cidr_blocks       = [var.vpc_cidr, "211.34.57.0/24"]
  security_group_id = aws_security_group.main.id
  from_port         = 0
  to_port           = 0
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.main.id
}

resource "aws_route53_record" "main" {
  zone_id = var.route53_zone_id
  name    = "${var.domain_name}.${var.route53_zone_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.main.public_ip]
}
