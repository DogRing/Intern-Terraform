resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags                 = { Name = "${var.prefix}-VPC" }
}

resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.prefix}-IGW" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  count             = length(var.cidr_for_public)
  cidr_block        = var.cidr_for_public[count.index]
  availability_zone = var.availability_zones[count.index]
  tags              = { Name = "${var.prefix}-pb-sn-${count.index + 1}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Naem = "${var.prefix}-pb-rt" }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main-igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.cidr_for_public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id

  count             = length(var.cidr_for_private)
  cidr_block        = var.cidr_for_private[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]
  tags              = { Name = "${var.prefix}-pv-sn-${count.index + 1}" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  count = length(var.cidr_for_private)
  tags  = { Name = "${var.prefix}-pv-rt-${count.index + 1}" }
}

resource "aws_route" "private" {
  count = length(var.cidr_for_private)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-private[count.index % length(var.availability_zones)].id
}

resource "aws_route_table_association" "private" {
  count = length(var.cidr_for_private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_eip" "nat-eip" {
  count = length(var.availability_zones)
  vpc   = true
  tags  = { Name = "${var.prefix}-pb-ip-${count.index + 1}" }
}

resource "aws_nat_gateway" "nat-private" {
  depends_on = [aws_internet_gateway.main-igw]

  count         = length(var.availability_zones)
  allocation_id = aws_eip.nat-eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = { Name = "${var.prefix}-ngw-${count.index + 1}" }
}

resource "aws_subnet" "private-db" {
  vpc_id = aws_vpc.main.id

  count             = length(var.cidr_for_db_private)
  cidr_block        = var.cidr_for_db_private[count.index]
  availability_zone = var.availability_zones[count.index]
  tags              = { Name = "${var.prefix}-db-pv-sn-${count.index + 1}" }
}
