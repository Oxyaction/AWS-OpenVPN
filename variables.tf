variable "access_key" {}

variable "secret_key" {}

variable "key_name" {
  default = "default"
}

variable "ssh_ips" {
  type    = "list"
  default = []
}

variable "public_key_path" {}

variable "region" {
  default = "us-east-1"
}
