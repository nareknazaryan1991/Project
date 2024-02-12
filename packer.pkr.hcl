packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "postgres_root_user" {}

variable "postgres_root_pass" {}

source "amazon-ebs" "ubuntu" {
  ami_name      = "ec2-db"
  instance_type = "t2.micro"
  region        = "us-west-1"
  profile       = "412999873787"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  tags = {
    Name = "ec2-db"
  }
  ssh_username = "ubuntu"
}

build {
  name = "ec2-db"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "ansible" {
    playbook_file = "./ansible/db-setup.yml"
    user          = "ubuntu"
    use_proxy     = "false"
    extra_arguments = [
      "--extra-vars", "ssh_extra_args='-oHostKeyAlgorithms=ssh-rsa'",
      "--extra-vars", "postgres_root_user='${var.postgres_root_user}'",
      "--extra-vars", "postgres_root_pass='${var.postgres_root_pass}'",
    "-vvv"]
  }
}  
