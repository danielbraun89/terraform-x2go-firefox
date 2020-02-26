provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "scratch" {
  ami             = "ami-0ac05733838eabc06"
  instance_type   = "t3a.medium"
  key_name        = "id_rsa"
  security_groups = ["all-open"]
  user_data       = "${file("setup.sh")}"

  tags = {
    Name = "scratch"
  }
}

output "instance_ip_addr" {
  value = aws_instance.scratch.public_ip
}
