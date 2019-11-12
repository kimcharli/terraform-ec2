////////
provider "aws" {
  region = "${var.aws_region}"
}

//////// AMI
data "aws_ami" "default" {
  most_recent = true
  owners = ["099720109477"] # Canonical

  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

//data "aws_ami" "latest_ecs" {
//  most_recent = true
//  owners = ["591542846629"] # AWS
//
//  filter {
//      name   = "name"
//      values = ["*amazon-ecs-optimized"]
//  }
//
//  filter {
//      name   = "virtualization-type"
//      values = ["hvm"]
//  }
//}

//data "aws_ami" "centos" {
//owners      = ["679593333241"]
//most_recent = true
//
//  filter {
//      name   = "name"
//      values = ["CentOS Linux 7 x86_64 HVM EBS *"]
//  }
//
//  filter {
//      name   = "architecture"
//      values = ["x86_64"]
//  }
//
//  filter {
//      name   = "root-device-type"
//      values = ["ebs"]
//  }
//}


//////// VPC
resource "aws_vpc" "default" {
  cidr_block       = "${var.k8s_vpc_net}"

  tags {
    Name = "vpc-${var.vpc_name}"
  }
}

data "aws_availability_zones" "azs" {}

resource "aws_subnet" "default" {
  vpc_id     = "${aws_vpc.default.id}"
  cidr_block = "${var.k8s_vpc_subnet}"
  availability_zone = "${data.aws_availability_zones.azs.names[0]}"

  tags {
    Name = "subnet-${var.vpc_name}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id     = "${aws_vpc.default.id}"

  tags {
    Name = "igw-${var.vpc_name}"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}


//////// SG
resource "aws_security_group" "bastion" {
  name        = "bastion-${var.vpc_name}"
  description = "Bastion ingress traffic"
  vpc_id = "${aws_vpc.default.id}"
}

data "http" "ip" {
  url = "http://icanhazip.com"
}

resource "aws_security_group_rule" "bastion-ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = "${aws_security_group.bastion.id}"
  cidr_blocks = [ "${chomp(data.http.ip.body)}/32"]
}

resource "aws_security_group_rule" "bastion-vpc" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.bastion.id}"
  cidr_blocks = ["${var.k8s_vpc_net}"]
}

resource "aws_security_group_rule" "bastion-vpc-egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.bastion.id}"
  cidr_blocks = ["${var.k8s_vpc_net}"]
}



resource "aws_security_group" "k8s-master" {
  name        = "master-${var.vpc_name}"
  description = "Master ingress traffic"
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_security_group_rule" "k8s-vpc" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.k8s-master.id}"
  cidr_blocks = ["${var.k8s_vpc_net}"]
}

resource "aws_security_group_rule" "k8s-master-egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.k8s-master.id}"
  cidr_blocks = ["${var.k8s_vpc_net}"]
}



//////// EC2
resource "aws_instance" "bastion" {
  ami = "${data.aws_ami.default.id}"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.default.id}"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
  associate_public_ip_address = "true"

  tags {
    Name = "k8s-bastion-${var.vpc_name}"
  }
}



resource "aws_instance" "k8s-master" {
  ami = "${data.aws_ami.default.id}"
  instance_type = "${var.k8s_instance_type}"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.default.id}"
  vpc_security_group_ids = ["${aws_security_group.k8s-master.id}"]

  tags {
    Name = "k8s-master-${var.vpc_name}"
  }

}


resource "aws_instance" "k8s-node" {
  count = 2
  ami = "${data.aws_ami.default.id}"
  instance_type = "${var.k8s_instance_type}"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.default.id}"
  vpc_security_group_ids = ["${aws_security_group.k8s-master.id}"]

  tags {
    Name = "k8s-node-${count.index}-${var.vpc_name}"
  }

}


