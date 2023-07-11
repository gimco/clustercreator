variable "AWS_REGION" {
	default = "us-east-1"
}

variable "nodes_count" {
  default = "2"
}

variable "slurm_template_ami" {
	default = "ami-083f9de3a7dec6189"
}

variable "cliente" {
  type = string
}