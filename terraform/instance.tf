provider "aws" {
  region = "ap-south-1"
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "vagrant_demo" {
  ami           = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = "t2.micro"
  key_name      = "MY_KEY"

  connection {
    user        = "ec2-user"
    private_key = "${file("${var.PRIVATE_KEY_PATH}")}"
  }

  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "file" {
    source      = "../ansible"
    destination = "/tmp/ansible"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "sudo /tmp/script.sh"
    ]
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.vagrant_demo.public_ip} > ../ansible/hosts"
  }
}

resource "null_resource" "ansible" {
  triggers {
    key = "${uuid()}"
  }

  connection {
    user        = "ec2-user"
    private_key = "${file("${var.PRIVATE_KEY_PATH}")}"
    host = "${aws_instance.vagrant_demo.public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/ansible/playbook.yml",
      "sudo ansible-playbook /tmp/ansible/playbook.yml",
    ]
  }
}

module "security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "myTerraformGroup"
  description = "Security group for terraform module usage with EC2 instance"
  vpc_id      = "${data.aws_vpc.default.id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

output "ip" {
  value = "${aws_instance.vagrant_demo.public_ip}"
}
