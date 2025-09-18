# -----------------------------
# Data
# -----------------------------
data "aws_availability_zones" "available" {}

# -----------------------------
# VPC
# -----------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { 
    Name = "${var.project}-vpc" 
  }
}

# -----------------------------
# Internet Gateway
# -----------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = { 
    Name = "${var.project}-igw" 
  }
}

# -----------------------------
# Subnets
# -----------------------------
resource "aws_subnet" "public" {
  for_each = toset(range(length(var.public_subnet_cidrs)))
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidrs[each.key]
  availability_zone = length(var.availability_zones) > 0 ? var.availability_zones[each.key] : data.aws_availability_zones.available.names[each.key]
  map_public_ip_on_launch = true

  tags = { 
    Name = "${var.project}-public-${each.key}"
  }
}

resource "aws_subnet" "private" {
  for_each = toset(range(length(var.private_subnet_cidrs)))
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[each.key]
  availability_zone = length(var.availability_zones) > 0 ? var.availability_zones[each.key] : data.aws_availability_zones.available.names[each.key]
  map_public_ip_on_launch = false

  tags = { 
    Name = "${var.project}-private-${each.key}" 
  }
}

# -----------------------------
# NAT Gateway
# -----------------------------
resource "aws_eip" "nat" {
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.project}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["0"].id
  depends_on    = [aws_internet_gateway.igw]

  tags = { 
    Name = "${var.project}-nat"
  }
}

# -----------------------------
# Route Tables
# -----------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route { 
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project}-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  for_each      = aws_subnet.public
  subnet_id     = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route { 
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id 
  }

  tags = { 
    Name = "${var.project}-private-rt" 
  }
}

resource "aws_route_table_association" "private_assoc" {
  for_each      = aws_subnet.private
  subnet_id     = each.value.id
  route_table_id = aws_route_table.private.id
}
