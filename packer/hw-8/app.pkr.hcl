packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
variable "base_ami" { type = string }
variable "instance_type" { type = string }
variable "region" { type = string }
// owners 136693071363 --filters "Name=name,Values=debian-12-amd64-*" "Name=architecture,Values=x86_64"
source "amazon-ebs" "debian" {
  ami_name      = "hw5-linux-app-{{timestamp}}"
  instance_type = "${var.instance_type}"
  region        = "${var.region}"
  source_ami    = var.base_ami
  tags = {
    "env" : "test",
    "DZ" : "hw5",
    "part" : "app",
    "OS" : "debian-12-amd64",
    "BuiltBy" : "Packer"
  }
  ssh_username = "admin"
}
build {
  name = "hw5-linux-app"
  sources = [
    "source.amazon-ebs.debian"
  ]

"provisioners": [
  {
    "type": "ansible",
    "playbook_file": "../../ansible/hw-8/app_install.yml",
    "extra_arguments": [
      "--extra-vars", "mysql_user={{user `db_user`}} mysql_pass={{user `db_pass`}} mysql_db={{user `db_name`}}"
    ]
  }
]

}

