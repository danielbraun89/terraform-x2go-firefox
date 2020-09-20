provider "aws" {
  region = "us-east-1"
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUj8DJozIkBytRiG7OKwMGD9sEOxdxghCWLZs3P0h3qbe7WzHCuSnpFeyPCslkAj9dMlHzzjy8XXQg7tKBZFwZx0Kp5LjSuEspzqH/HprvH1fx5yW1ZFA6DUIjuavUQMYQCjxOtQljHXQmTTT7/fDC9VxiQuI+SJ7qfsSGvdx2FNEGaqftbwrTtVL55tgp7GrG0mZqmQu4X1iTje51kKWGT9cA6rwjvBpJa+CDQ3cB4r9hRcp7uDo/jEIuLW9BzayfoLWH+E8jfivEKFLIgGCY9kDr7t1zvygIc5COZxSJpYSrl9YXCo2q9TkrPXkeoyxxHAtOV4oktLEr1nSoXc7N ubuntu"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh"
  vpc_id      = aws_default_vpc.default.id

 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "allow_daniel" {
  name        = "allow_daniel"
  description = "Allow All traffic from daniel ip"
  vpc_id      = aws_default_vpc.default.id

   ingress{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["79.182.173.166/32"]
  }

  tags = {
    Name = "allow_daniel"
  }
}

resource "aws_security_group" "allow_all_outbound" {
  name        = "allow_all_outbound"
  description = "Allow All outbound"
  vpc_id      = aws_default_vpc.default.id

 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all_outbound"
  }
}

resource "aws_instance" "scratch" {
  ami             = "ami-0dba2cb6798deb6d8"   # ubuntu 20.04
  instance_type   = "t2.micro"   # free tier eligible
  vpc_security_group_ids = [aws_security_group.allow_daniel.id, aws_security_group.allow_all_outbound.id, aws_security_group.allow_ssh.id]
  user_data       = "${file("setup.sh")}"
  key_name         = "deployer-key"
  tags = {
    Name = "scratch"
  }
}

output "instance_ip_addr" {
  value = aws_instance.scratch.public_ip
}
