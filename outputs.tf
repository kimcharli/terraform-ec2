output "public_ips" {
  value = "${aws_instance.bastion.public_ip}"
}


output "aws_ami_ids" {
  value = "${data.aws_ami.default.name}"
}