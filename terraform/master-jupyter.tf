resource "aws_network_interface" "lanmaster" {
  subnet_id   = "${aws_subnet.main_subnet_hpc.id}"
  private_ips = ["172.31.0.100"]
  security_groups = [aws_security_group.SG_hpc.id]

  tags = {
    Name = "ni-${var.cliente}"
    Cliente = var.cliente
  }
}

resource "aws_instance" "master" {
	ami           = var.slurm_template_ami
	instance_type = "t3.large"
	depends_on = [aws_instance.nodes]

	key_name  = aws_key_pair.kp.key_name
	iam_instance_profile = "LabInstanceProfile"
  network_interface {
     network_interface_id = aws_network_interface.lanmaster.id
     device_index = 0
  }

	user_data = <<-EOF
		#!/bin/bash
		set -e
		echo slurmmaster > /etc/hostname
		hostname slurmmaster

		mkdir -p /shared/software

		# Obtenemos ip y nombe de nodos
		aws --region us-east-1 ec2 describe-instances \
			--filter "Name=subnet-id,Values=[${aws_subnet.main_subnet_hpc.id}]" "Name=tag:Name,Values=slurm*" \
			--query "Reservations[].Instances[]" |\
			jq -r '.[] | "\(.PrivateIpAddress) \(.Tags[] | select(.Key=="Name") | .Value)"' > /shared/hosts.txt

		# Actualizar hots
		cat /shared/hosts.txt >> /etc/hosts

		# Exportar NFS 
		chown nobody:nogroup /shared -R
		chmod 777 /shared -R
		echo "/shared ${aws_subnet.main_subnet_hpc.cidr_block}(rw,sync,no_subtree_check)" >> /etc/exports
		exportfs -a

		# Descargamos los ejemplos
		wget -c http://www.numberworld.org/y-cruncher/y-cruncher%20v0.7.10.9513-static.tar.xz -O - |\
				tar -C /shared/software -Jx && mv "/shared/software/y-cruncher v0.7.10.9513-static" /shared/software/pi &

		cat << 'EJEMPLO' > /shared/software/job1CPU-pi.sl
		#!/bin/bash
		#SBATCH -J PI-1CPU
		#SBATCH --time=01:00:00         # Walltime
		#SBATCH --mem-per-cpu=1         # memory/cpu
		#SBATCH --ntasks=1      # MPI processes
		#SBATCH --output=1cpuslurm-%j.out

		/shared/software/pi/y-cruncher skip-warnings bench 100m
		EJEMPLO

		cat << 'EJEMPLO' > /shared/software/job4CPU-pi.sl
		#!/bin/bash
		#SBATCH -J PI-4CPU
		#SBATCH --time=01:00:00         # Walltime
		#SBATCH --mem-per-cpu=1         # memory/cpu
		#SBATCH --ntasks=4      # MPI processes
		#SBATCH --output=4cpuslurm-%j.out

		/shared/software/pi/y-cruncher skip-warnings bench 100m
		EJEMPLO


		service munge start
		service slurmctld start
		jupyter lab --no-browser --allow-root --ip=0.0.0.0 --NotebookApp.token='' --NotebookApp.password='' --notebook-dir=/shared/  --preferred-dir /shared/
	EOF

	tags = {
        Name = "slurmmaster"
        Cliente = var.cliente
  	}
}

