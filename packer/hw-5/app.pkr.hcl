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
  provisioner "file" {
    source = "scripts/fetch-envs.sh"
    destination = "~/fetch-ssm-params.sh"
  }
  provisioner "file" {
    source = "scripts/backup_db.sh"
    destination = "~/backup_db.sh"
  }
  provisioner "shell" {
    inline = [
      "sudo mv ~/fetch-ssm-params.sh /usr/local/bin/fetch-ssm-params.sh",
      "sudo chmod +x /usr/local/bin/fetch-ssm-params.sh"
    ]
  }
  provisioner "shell" {
    inline = [
      "sudo mv ~/backup_db.sh /usr/local/bin/backup_db.sh",
      "sudo chmod +x /usr/local/bin/backup_db.sh",
      "echo '00 01   * * *   root /usr/local/bin/backup_db.sh' > cronjob",
      "sudo mv cronjob /etc/cron.d/backup_db"
    ]
  }
  provisioner "shell" {
    script = "scripts/app.sh"
  }
}

