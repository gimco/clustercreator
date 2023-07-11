
resource "aws_instance" "nodes" {
  ami           = var.slurm_template_ami
  instance_type = "t3.large"
  count         = var.nodes_count

  subnet_id = aws_subnet.main_subnet_hpc.id
  vpc_security_group_ids = [aws_security_group.SG_hpc.id]
  key_name  = aws_key_pair.kp.key_name

  user_data = <<-EOF
    #!/bin/bash
    set -e

    echo slurmnode${count.index + 1} > /etc/hostname
    hostname slurmnode${count.index + 1}

    # Esperar hasta que el servidor NFS esté activo
    while ! nc -z 172.31.0.100 2049 &> /dev/null
    do
      printf "%c" "."
    done
    sleep 3

    # Montar NFS
    mkdir -p /shared
    echo "172.31.0.100:/shared /shared nfs defaults 0 0" >> /etc/fstab
    mount -a

    cat /shared/hosts.txt >> /etc/hosts

    service munge start
    service slurmd start
  EOF

  tags = {
        Name = "slurmnode${count.index + 1}"
    }
}

