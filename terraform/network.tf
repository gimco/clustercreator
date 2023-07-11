resource "aws_security_group" "SG_hpc"{
	vpc_id = aws_vpc.main_vpc_hpc.id

	egress {
		from_port = 0
		to_port = 0
		protocol = -1
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress{
		description = "Permit ping"
		from_port = -1
		to_port = -1
		protocol = "icmp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress{
		description =" permit http"
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks =["0.0.0.0/0"]
	}

	ingress{
		description =" permit slurm"
		from_port = 6817
		to_port = 6819
		protocol = "tcp"
		cidr_blocks =["0.0.0.0/0"]
	}

	ingress{
		description =" nfs storage"
		from_port = 2049
		to_port = 2049
		protocol = "tcp"
		cidr_blocks =["0.0.0.0/0"]
	}

	ingress{
		description ="jupiter"
		from_port = 8888
		to_port = 8888
		protocol = "tcp"
		cidr_blocks =["0.0.0.0/0"]
	}


	ingress{
		description ="permit ssh"
		from_port=22
		to_port=22
		protocol="tcp"
		cidr_blocks=["0.0.0.0/0"]
	}
	tags = {
		Name = "HPC rules"
		
	}



}

