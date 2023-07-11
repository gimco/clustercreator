provider "aws" {
	region = var.AWS_REGION
}

resource "aws_vpc" "main_vpc_hpc"{
	cidr_block = "172.31.0.0/16"
	enable_dns_support = "true"
	enable_dns_hostnames = "true"
	instance_tenancy = "default"

	tags = {
		Name = "main_vpc_hpc"	
	}
}

resource "aws_internet_gateway" "main_internet_gateway"{
	vpc_id = aws_vpc.main_vpc_hpc.id

	tags = { 
		Name="main_internet_gateway"		
	}
}

resource "aws_subnet" "main_subnet_hpc" {
	vpc_id = aws_vpc.main_vpc_hpc.id
	cidr_block = "172.31.0.0/24"
	availability_zone = "us-east-1a"
	map_public_ip_on_launch = "true"

	tags = {
		Name="main_subnet_hpc"		
	}
}

resource "aws_route_table" "Custom_Main_Route_Table"{
	vpc_id = aws_vpc.main_vpc_hpc.id

	route{
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.main_internet_gateway.id
	}
	tags = {
		Name="Custon_Main_Route_Table"
	}
}

resource "aws_route_table_association" "hpc-route"{
	subnet_id = aws_subnet.main_subnet_hpc.id
	route_table_id = aws_route_table.Custom_Main_Route_Table.id
}

resource "tls_private_key" "pk" {
  algorithm     = "RSA"
  rsa_bits      = 4096
}

resource "aws_key_pair" "kp" {
  key_name      = "hpc-key"
  public_key    = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" {
    command = <<-EOT
      echo "${tls_private_key.pk.private_key_pem}" > hpc-key.pem
    EOT
  }
}
