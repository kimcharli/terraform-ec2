terraform {
}

variable "aws_region" {
  default = "us-east-2"
}

//// AMI
variable "aws-ami-choice" {
  default = "ubuntu"
}

variable "aws-ami" {
  type = map(object({
    owners = list(string)
    name-filter = list(string)
    user = string
  }))

  default = {
    ubuntu = {
      owners = ["099720109477"] # Canonical
      name-filter = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
      user = "ubuntu"
    }
    centos = {
      owners = ["679593333241"]
      name-filter = ["CentOS Linux 7 x86_64 HVM EBS *"]
      user = "centos"
    }
    amazon-ecs = {
      owners = ["591542846629"] # AWS
      name-filter = ["*amazon-ecs-optimized"]
      user = "cloud_user"
    }
  }

}


//// VPC
variable "vpc_name" {
  default = "kafka-vpc1"
}

variable "vpc_net" {
  default = "10.0.0.0/16"
}

variable "vpc_subnet_public" {
  default = "10.0.10.0/24"
}

variable "vpc_subnet_private" {
  default = "10.0.20.0/24"
}

//variable "masters_ips" {
//  type = list(string)
//  default = [ "10.0.20.11", "10.0.20.12", "10.0.20.13"]
//}
//
//variable "nodes_ips" {
//  type = list(string)
//  default = [ "10.0.20.21", "10.0.20.22", "10.0.20.23"]
//}

//variable "node_ips" {
//  type = object({
//    masters = list(string)
//    nodes = list(string)
//  })
//  default = {
//    masters = [ "10.0.20.11", "10.0.20.12", "10.0.20.13"]
//    nodes = [ "10.0.20.21", "10.0.20.22", "10.0.20.23"]
//  }
//}

variable "instance_type" {
  description = "Flavor of image"
  default = "c4.xlarge"
}

variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "ckim-mbp"
}

variable "instance-count" {
  default = 3
}

variable "node_ips" {
  type = list(string)
  default = [ "10.0.20.11", "10.0.20.12", "10.0.20.13"]
}