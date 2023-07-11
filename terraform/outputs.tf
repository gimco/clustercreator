output "master_public_ip" {
  value = [aws_instance.master.*.public_ip]
}