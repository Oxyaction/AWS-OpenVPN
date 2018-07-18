provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name      = "main"
    Initiator = "terraform"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.main.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "web" {
  name        = "web"
  description = "Allow all http traffic from everywhere and ssh from work"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.ssh_ips}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "web" {
  connection = {
    user = "ec2-user"
  }

  instance_type          = "t2.micro"
  ami                    = "ami-b70554c8"
  key_name               = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.web.id}"]
  subnet_id              = "${aws_subnet.public.id}"

  tags = {
    Type    = "VPN"
    Managed = "Terraform"
  }
}

output "ip" {
  value = "${aws_instance.web.public_ip}"
}

output "dns" {
  value = "${aws_instance.web.public_dns}"
}
