terraform {
}

variable "aws_region" {
  default = "us-west-2"
}

variable "vpc_name" {
  default = "k8s-vpc1"
}

variable "k8s_vpc_net" {
  default = "10.0.0.0/16"
}

variable "k8s_vpc_subnet_public" {
  default = "10.0.10.0/24"
}

variable "k8s_vpc_subnet_private" {
  default = "10.0.20.0/24"
}


variable "k8s_ami_name" {
  default = "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-arm64-server-20191021*"
}

variable "k8s_instance_type" {
  description = "Flavor of image"
  default = "c4.xlarge"
}

variable "ec2_user" {
  default = "ubuntu"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "ckim-mbp"
}


