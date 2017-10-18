#The provider here is aws but it can be other provider
provider "aws" {
    region = "eu-west-1"
}
# Create a URBAN VPC Irlanda to launch our instances into 
resource "aws_vpc" "urban-project" {
    enable_dns_support      = "true"
    enable_dns_hostnames    = "true"
    cidr_block              = "172.52.0.0/16"
    tags {
        Name =              "urban-project"
    }
}
#PUBLIC SUBNET ON VPC FO URBAN PROYECT  
resource "aws_subnet" "urban-project-public-0" {
    vpc_id =                    "${aws_vpc.urban-project.id}"
    cidr_block =                "172.52.1.0/24"
    availability_zone =         "eu-west-1b"
    map_public_ip_on_launch =   "true"
    tags {
        Name =                 "urban-project-public-0"
    }
}
#PRIVATE SUBNET ON VPC FOR URBAN PROJECT 
resource "aws_subnet" "urban-project-private-0" {
    vpc_id =                    "${aws_vpc.urban-project.id}"
    cidr_block =                "172.52.10.0/24"
    availability_zone =         "eu-west-1a"
    map_public_ip_on_launch =   "true"
    tags {
        Name =                 "urban-project-private-0"
    }
}
#INTERNET GATEWAY FOR PUBLIC SUBNET
resource "aws_internet_gateway" "urban-project-igw" {
    vpc_id =                    "${aws_vpc.urban-project.id}"
    tags {
        Name =                  "urban-project-igw"
    }
}
#NAT GATEWAY FOR CONNECT SUBNET PRIVATE WITH INTERNET
resource "aws_nat_gateway" "urban-project-nat" {
    allocation_id =             "${aws_eip.urban-project-nat-eip.id}"
    subnet_id =                 "${aws_subnet.urban-project-public-0.id}"
    depends_on =                ["aws_internet_gateway.urban-project-igw"]
}
#ASSIGN EIP FOR NAT GATEWAY
resource "aws_eip" "urban-project-nat-eip" {
    vpc =                       "true"
    depends_on =                ["aws_internet_gateway.urban-project-igw"]
    
}
#ROUTE TABLE FOR PUBLIC SUBNET
resource "aws_route_table" "urban-project-public-rt" {
    vpc_id =                       "${aws_vpc.urban-project.id}"
    tags {
        Name = "urban-project-public-rt"
    }
}
#ROUTE TABLE FOR PRIVATE SUBNET
resource "aws_route_table" "urban-project-private-rt" {
    vpc_id =                       "${aws_vpc.urban-project.id}"
    tags {
        Name = "urban-project-private-rt"
    }
}
#ROUTE FOR PUBLIC SUBNET
resource "aws_route" "urban-project-public-route" {
    route_table_id =                "${aws_route_table.urban-project-public-rt.id}"
    destination_cidr_block =        "0.0.0.0/0"
    gateway_id =                    "${aws_internet_gateway.urban-project-igw.id }"
}
#ROUTE FOR PRIVATE SUBNET
resource "aws_route" "urban-project-private-route" {
    route_table_id =                "${aws_route_table.urban-project-private-rt.id}"
    destination_cidr_block =        "0.0.0.0/0"
    nat_gateway_id =                "${aws_nat_gateway.urban-project-nat.id}"
}
#ROUTE TABLE ASSOCIATION FOR PUBLIC SUBNET
resource "aws_route_table_association" "urban-project-public-rta" {
    subnet_id =                     "${aws_subnet.urban-project-public-0.id}"
    route_table_id =                "${aws_route_table.urban-project-public-rt.id}"
}
#ROUTE TABLE ASSOCIATION FOR PRIVATE SUBNET
resource "aws_route_table_association" "urban-project-private-rta" {
    subnet_id =                     "${aws_subnet.urban-project-private-0.id}"
    route_table_id =                "${aws_route_table.urban-project-private-rt.id}"
}
