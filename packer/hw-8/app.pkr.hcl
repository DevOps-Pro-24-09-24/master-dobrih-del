source "amazon-ebs" "debian-app" {
  ami_name      = "hw8-linux-app-{{timestamp}}"
  instance_type = var.instance_type
  region        = var.region
  source_ami    = var.base_ami
  tags = {
    "env" : "test",
    "DZ" : "hw8",
    "part" : "app",
    "OS" : "debian-12-amd64",
    "BuiltBy" : "Packer"
  }
  ssh_username = "admin"
}
build {
  name = "hw8-linux-app"
  sources = [
    "source.amazon-ebs.debian-app"
  ]
  provisioner "ansible" {
    playbook_file = "../../ansible/hw-8/app_install.yml"
    groups = ["app_group"]
    extra_arguments = [
      "--extra-vars",
      <<EOF
{
  "mysql_user": "flask_user",
  "mysql_pass": "rfvbnmkijuhgfdsdfgvb",
  "mysql_db": "flask_db0",
  "app_dir": "/usr/apps/flask-alb-app",
  "virtual_env_dir": "/usr/venvs/flask-alb-app",
  "venv_dir": "/usr/venvs/flask-alb-app",
  "requirements_url": "https://raw.githubusercontent.com/saaverdo/flask-alb-app/refs/heads/orm/requirements.txt",
  "repo_url": "https://github.com/DevOps-Pro-24-09-24/examples.git",
  "db_host_ip": ""
}
EOF

    ]
  }
}
