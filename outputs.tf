output "public_ips" {
  value = "${aws_instance.bastion.public_ip}"
}

output "master_ips" {
  value = "${aws_instance.k8s-master.*.private_ip}"
}

output "node_ips" {
  value = "${aws_instance.k8s-node.*.private_ip}"
}

output "aws_ami_ids" {
  value = "${data.aws_ami.default.name}"
}

