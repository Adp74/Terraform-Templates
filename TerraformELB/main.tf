# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

#VPC
resource "aws_vpc" "vpc_default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc_tf_test"
  }
}

resource "aws_subnet" "tf_test_subnet" {
  vpc_id                  = "${aws_vpc.vpc_default.id}"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf_test_subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc_default.id}"

  tags = {
    Name = "tf_test_ig"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.vpc_default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "aws_route_table_terr"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.tf_test_subnet.id}"
  route_table_id = "${aws_route_table.r.id}"
}

#INSTANCE SECURITY GROUP
resource "aws_security_group" "sg_default" {
  name        = "instance_sg"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.vpc_default.id}"

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

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our elb security group to access
# the ELB over HTTP
resource "aws_security_group" "sg_elb" {
  name        = "elb_sg"
  description = "Used in the terraform"

  vpc_id = "${aws_vpc.vpc_default.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

  # ensure the VPC has an Internet gateway or this step will fail
  depends_on = ["aws_internet_gateway.gw"]
}

#ELB

resource "aws_elb" "myElb" {
  name = "example-elb"

  # The same availability zone as our instance
  subnets = ["${aws_subnet.tf_test_subnet.id}"]

  security_groups = ["${aws_security_group.sg_elb.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

   listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 443
    lb_protocol       = "https"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  # The instance is registered automatically

 # instances                   = ["${aws_instance.web.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
}

resource "aws_lb_cookie_stickiness_policy" "default_stick" {
  name                     = "lbpolicy"
  load_balancer            = "${aws_elb.myElb.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}
/*
resource "aws_instance" "web" {
  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair you've created and downloaded
  # from the AWS console.
  #
  # https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#KeyPairs:
  #
  key_name = "${var.key_name}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.sg_default.id}"]
  subnet_id              = "${aws_subnet.tf_test_subnet.id}"
  user_data              = "${file("userdata.sh")}"

  #Instance tags

  tags = {
    Name = "instance_elb-example"
  }
}*/

#LAUNCH CONFIGURATION
data "aws_ami" "linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["linux-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["743562285063"] # Canonical
}

resource "aws_launch_configuration" "as_conf" {
  name          = "web_config"
  image_id      = "${data.aws_ami.linux.id}"
  instance_type = "t2.micro"
}

#AUTO SCALING GROUP
resource "aws_autoscaling_group" "ASG" {
  name                      = "ASG-terraform-test"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.as_conf.name}"
  vpc_zone_identifier       = ["${aws_subnet.tf_test_subnet.id}"]
  load_balancers            = ["${aws_elb.myElb.name}"]
  tag {
    key                 = "name"
    value               = "EC2_"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "name"
    value               = "ASG_"
    propagate_at_launch = false
  }
}