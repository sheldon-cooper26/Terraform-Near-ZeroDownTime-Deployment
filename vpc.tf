locals {
  subnet_count       = 2
  availability_zones = ["us-west-2a", "us-west-2b"]
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "terraform-blue-green" {
  count                   = "${local.subnet_count}"
  vpc_id                  = "${aws_vpc.default.id}"
  availability_zone       = "${element(local.availability_zones, count.index)}"
  cidr_block              = "10.0.${local.subnet_count * (var.infrastructure_version - 1) + count.index + 1}.0/24"
  map_public_ip_on_launch = true
#  tags {
 #   Name = "${element(local.availability_zones, count.index)} (v${var.infrastructure_version})"
 # }
}

