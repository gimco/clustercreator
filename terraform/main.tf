resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  count                   = min(3,length(data.aws_availability_zones.available.names))
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-subnet-public-${data.aws_availability_zones.available.names[count.index]}"
    Tier = "public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.prefix}-public-rtb"
    Tier = "public"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}

resource "aws_security_group" "web" {
  name        = "web_sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Web security group."
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-web-sg"
  }
}


data "aws_ami" "amazon_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_security_group" "instance-sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "instance" {
  ami                    = data.aws_ami.amazon_ami.id
  instance_type          = var.instance_type
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.instance-sg.id]

}




