variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}

variable "aws_amis" {
  default = {
    "eu-west-1" = "ami-0ce71448843cb18a1"
    "eu-west-2" = "ami-00a1270ce1e007c27"
  }
}