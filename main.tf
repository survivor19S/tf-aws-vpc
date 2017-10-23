
#--------------------------------------------------------------
# AWS VPC
#--------------------------------------------------------------
resource "aws_vpc" "mod" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
  tags = "${merge(var.tags, map("Name", "${var.name}"))}"
}

resource "aws_internet_gateway" "mod" {
  vpc_id = "${aws_vpc.mod.id}"
  tags = "${merge(var.tags, map("Name", "${var.name}-igw"))}"
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.mod.id}"
}
