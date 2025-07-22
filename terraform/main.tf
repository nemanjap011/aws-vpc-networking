########################
# Networking
########################

resource "aws_vpc" "cloudops" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "cloudops-network-vpc"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.cloudops.id

  tags = merge(var.tags, {
    Name = "cloudops-igw"
  })
}

# Subnets
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.cloudops.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.region}${var.az}"
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "cloudops-public-subnet-a"
    Tier = "public"
  })
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.cloudops.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.region}${var.az}"

  tags = merge(var.tags, {
    Name = "cloudops-private-subnet-a"
    Tier = "private"
  })
}

# Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.cloudops.id

  tags = merge(var.tags, {
    Name = "cloudops-public-rt"
  })
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = merge(var.tags, { Name = "cloudops-nat-eip" })
}

resource "aws_nat_gateway" "natgw" {
  subnet_id     = aws_subnet.public_a.id
  allocation_id = aws_eip.nat.id

  tags = merge(var.tags, {
    Name = "cloudops-natgw-a"
  })

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.cloudops.id

  tags = merge(var.tags, {
    Name = "cloudops-private-rt"
  })
}

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

########################
# Security Groups
########################

# Bastion SG
resource "aws_security_group" "bastion_sg" {
  name        = "cloudops-bastion-sg"
  description = "Allow SSH from admin IP"
  vpc_id      = aws_vpc.cloudops.id

  ingress {
    description      = "SSH from admin"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.admin_ip]
    ipv6_cidr_blocks = []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "cloudops-bastion-sg" })
}

# Private instance SG
resource "aws_security_group" "private_sg" {
  name        = "cloudops-private-sg"
  description = "Allow SSH only from bastion"
  vpc_id      = aws_vpc.cloudops.id

  ingress {
    description = "SSH from bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "cloudops-private-sg" })
}

########################
# EC2 Instances
########################

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Bastion / Jump host
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = var.key_pair_name

  tags = merge(var.tags, { Name = "jump-host-public" })
}

# Private app server
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_a.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = var.key_pair_name

  tags = merge(var.tags, { Name = "app-server-private" })
}
