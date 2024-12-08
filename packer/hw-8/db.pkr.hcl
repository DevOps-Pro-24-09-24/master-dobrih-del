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
source "amazon-ebs" "debian" {
  ami_name      = "hw5-linux-db-{{timestamp}}"
  instance_type = "${var.instance_type}"
  region        = "${var.region}"
  // ssh_key_pair  = "test"
  source_ami    = var.base_ami
  tags = {
    "env" : "test",
    "DZ" : "hw5",
    "OS" : "debian-12-amd64",
    "part" : "db",
    "BuiltBy" : "Packer"
  }
  ssh_username = "admin"
}
build {
  name = "hw5-linux-db"
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

