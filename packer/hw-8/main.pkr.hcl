packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/ansible"
    }
  }
}
variable "base_ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "region" {
  type = string
}