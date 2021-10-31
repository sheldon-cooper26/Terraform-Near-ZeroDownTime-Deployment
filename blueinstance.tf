provider "aws" {
  region = "us-west-2"
  profile = "default"

}

locals {
  subnets = ["${aws_subnet.terraform-blue-green.*.id}"]
}

resource "aws_key_pair" "terraform-blue-green" {
  key_name   = "terraform-blue-green-v${var.infrastructure_version}"
  public_key = "${file(var.public_key_path)}"
}


resource "aws_instance" "terraform-blue-green" {
  count                  = 2
  ami                    = "ami-042d8ea311b4d1651"
  instance_type          = "t2.micro"
  subnet_id              = element(aws_subnet.terraform-blue-green.*.id,count.index)
  vpc_security_group_ids = ["${aws_security_group.terraform-blue-green.id}"]
  key_name               = "${aws_key_pair.terraform-blue-green.key_name}"
  user_data = templatefile("${path.module}/init-script.sh", {
    file_content = "<h1 style='background-color:#1c87c9;'>version 1.0 - #${count.index}</h1>"
  })

 # tags {
 #   Name                  = "Terraform Blue/Green ${count.index + 1} (v${var.infrastructure_version})"
  #  InfrastructureVersion = "${var.infrastructure_version}"
 # }
}

output "instance_public_ips" {
  value = "${aws_instance.terraform-blue-green.*.public_ip}"
}




