provider "aws" {
  region = "${var.aws_region}"
}

#AMI
data "aws_ami" "linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["linux*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["743562285063"] # Canonical
}

#SECURITY GROUP
resource "aws_security_group" "sg1" {
  name        = "instance_sg"
  description = "Used in the terraform"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#INSTANCE
resource "aws_instance" "myInstance" {
  ami             = "${data.aws_ami.linux.id}"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.sg1.id}"]
  associate_public_ip_address = true

  tags = {
    Name = "test-instance"
  }
}