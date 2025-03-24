terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["./credentials"]
  default_tags {
    tags = {
      Environment = "Dev"
      Course      = "CSSE6400"
      StudentID   = "s4744008"
    }
  }
}

data "aws_ami" "latest" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "hextris-server" {
  ami           = data.aws_ami.latest.id
  instance_type = "t2.micro"
  key_name      = "vockey"
  user_data     = file("./ serve-hextris.sh")

  security_groups = [aws_security_group.hextris-server.name]

  tags = {
    Name = "hextris"
  }
}

resource "aws_security_group" "hextris-server" {
  name        = "hextris-server"
  description = "Hextris HTTP and SSH access"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.hextris-server.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.hextris-server.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "TCP"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.hextris-server.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

output "hextris-url" {
  value = aws_instance.hextris-server.public_ip

}
