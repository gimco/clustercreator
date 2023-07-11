variable "prefix" {
  description = "Prefix of the name of the created resources"
  type        = string
  default     = "my"
}

variable "region" {
  description = "The selected AWS region for the VPC"
  type        = string
  default     = "us-east-1"
}

variable "vpc-cidr" {
  description = "The address range of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 Instance type"
  type        = string
  default     = "t3a.large"
}
