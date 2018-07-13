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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["193.93.77.27/32"]
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

  # provisioner "remote-exec" {
  #   inline = [
  # "sudo amazon-linux-extras install -y nginx1.12",
  # "sudo service nginx start",
  # "sudo systemctl enable nginx",
  # }
}

#  55  sudo ./easyrsa init-pki
#  56  ls
#  57  ls pki/
#  58  sudo ls pki/
#  59  sudo ./easyrsa build-ca
#  60  sudo ./easyrsa gen-dh
#  61  sudo ./easyrsa gen-req server nopass
#  62  sudo ./easyrsa sign-req --help
#  63  sudo ./easyrsa --help
#  64  sudo ./easyrsa help gen-req
#  65  sudo ./easyrsa sign-req server server
#  66  ./easyrsa gen-req client nopass
#  67  ls
#  68  ls pki/
#  69  ls -la pki
#  70  sudo ls -la pki
#  71  sudo ls -la pki/private
#  72  ./easyrsa gen-req client nopass
#  73  ./easyrsa gen-req --help
#  74  ./easyrsa help
#  75  ./easyrsa gen-req client nopass
#  76  sudo ./easyrsa gen-req client nopass
#  77  sudo ./easyrsa sign-req client client
#  78  cd ..
#  79  ls
#  80  rm -rf easy-rsa/
#  81  sudo rm -rf easy-rsa/
#  82  sudo mkdir easy-rsa
#  83  cd easy-rsa/
#  84  ls
#  85  sudo ./easyrsa init-pki
#  86  ls
#  87  sudo cp -Rv /usr/share/easy-rsa/3.0.3/* .
#  88  ls
#  89  sudo ./easyrsa init-pki
#  90  sudo ./easyrsa build-ca
#  91  sudo ./easyrsa gen-dh
#  92  sudo ./easyrsa gen-req server nopass
#  93  sudo ./easyrsa sign-req server server
#  94  ./easyrsa gen-req client nopass
#  95  sudo ./easyrsa gen-req client nopass
#  96  sudo ./easyrsa sign-req client client
#  97  cd /etc/openvpn
#  98  openvpn --genkey --secret pfs.key
#  99  sudo openvpn --genkey --secret pfs.key
# 100  ls
# 101  sudo nano server.conf
# 102  sudo service openvpn start
# 103  ls
# 104  systemctl start openvpn@server.service
# 105  sudo systemctl start openvpn@server.service
# 106  sudo service openvpn status
# 107  ps aux | grep openvpn
# 108  nano server.sh
# 109  ls
# 110  nano server.sh
# 111  sudo nano server.sh
# 112  cat server.conf
# 113  sudo chkconfig openvpn on
# 114  sudo systemctl status openvpn@server.service
# 115  cd /etc/openvpn/
# 116  ls
# 117  cat server.sh
# 118  mkdir keys
# 119  sudo su -
# 120  exit
# 121  cd /etc/openvpn/
# 122  ls
# 123  openssl x509 -subject -issuer -noout -in
# 124  cd keys

output "ip" {
  value = "${aws_instance.web.public_ip}"
}

output "dns" {
  value = "${aws_instance.web.public_dns}"
}
