output "address" {
  value = "${aws_instance.myInstance.public_ip}"
}