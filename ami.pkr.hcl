packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "source_ami" {
  type    = string
  default = "ami-0662f4965dfc70aca"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "s3_bucket" {
  type = string
}

variable "db_url" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "upload_path" {
  type = string
}

source "amazon-ebs" "mysite_ami" {
  region                      = var.aws_region
  source_ami                  = var.source_ami
  instance_type               = var.instance_type
  ssh_username                = "ubuntu"
  ami_name                    = "mysite-app-{{timestamp}}"
  associate_public_ip_address = true
  iam_instance_profile        = "mysiteRole"

  tags = {
    Name = "mysite-packer-ami"
  }
}

build {
  sources = ["source.amazon-ebs.mysite_ami"]

  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt install -y openjdk-17-jdk unzip curl net-tools",
      "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o '/tmp/awscliv2.zip'",
      "unzip /tmp/awscliv2.zip -d /tmp",
      "sudo /tmp/aws/install",

      "sudo mkdir -p /home/ubuntu/myapp",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/myapp",
      "sudo aws s3 cp s3://${var.s3_bucket}/mysite.jar /home/ubuntu/myapp/mysite.jar",
      "sudo chown ubuntu:ubuntu /home/ubuntu/myapp/mysite.jar",

      "echo '[Unit]' | sudo tee /etc/systemd/system/mysite.service",
      "echo 'Description=Spring Boot App' | sudo tee -a /etc/systemd/system/mysite.service",
      "echo 'After=network.target' | sudo tee -a /etc/systemd/system/mysite.service",

      "echo '[Service]' | sudo tee -a /etc/systemd/system/mysite.service",
      "echo 'User=ubuntu' | sudo tee -a /etc/systemd/system/mysite.service",
      "echo 'WorkingDirectory=/home/ubuntu/myapp' | sudo tee -a /etc/systemd/system/mysite.service",
      "echo \"Environment=SPRING_DATASOURCE_URL=${var.db_url}\" | sudo tee -a /etc/systemd/system/mysite.service",
      "echo \"Environment=SPRING_DATASOURCE_USERNAME=${var.db_username}\" | sudo tee -a /etc/systemd/system/mysite.service",
      "echo \"Environment=SPRING_DATASOURCE_PASSWORD=${var.db_password}\" | sudo tee -a /etc/systemd/system/mysite.service",
      "echo \"Environment=UPLOAD_PATH=${var.upload_path}\" | sudo tee -a /etc/systemd/system/mysite.service",
      "echo 'ExecStart=/usr/bin/java -jar /home/ubuntu/myapp/mysite.jar > /home/ubuntu/myapp/app.log 2>&1' | sudo tee -a /etc/systemd/system/mysite.service",

      "echo 'Restart=always' | sudo tee -a /etc/systemd/system/mysite.service",
      "echo 'RestartSec=5' | sudo tee -a /etc/systemd/system/mysite.service",

      "echo '[Install]' | sudo tee -a /etc/systemd/system/mysite.service",
      "echo 'WantedBy=multi-user.target' | sudo tee -a /etc/systemd/system/mysite.service",

      "sudo systemctl daemon-reload",
      "sudo systemctl enable mysite"
    ]
  }
}
